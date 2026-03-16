#!/usr/bin/env python
 
import os
import re
import subprocess
import glob
import argparse
import sys
 
TEAM_EMAILS = [
    "karthikachandrika.gopu@vaaluka.com"
]
 
# ============================================================
# COMMAND LINE ARGUMENTS
# ============================================================
 
parser = argparse.ArgumentParser()
parser.add_argument("-no_mail", action="store_true", help="Disable regression email notification")
parser.add_argument("-test", type=str, help="Run single test case")
parser.add_argument("-dir", type=str, help="Run all tests inside directory")
parser.add_argument("-all", action="store_true", help="Run all tests")
 
args = parser.parse_args()
 
TEST_DIR = args.dir
 
# Determine regression type for reporting in email
if args.test:
    regression_type = "Single Test : %s" % args.test
elif TEST_DIR == "axi_tests":
    regression_type = "Directory Regression : AXI Tests"
elif TEST_DIR == "axi_interconnect_tests":
    regression_type = "Directory Regression : AXI Interconnect Tests"
elif TEST_DIR == "dma_tests":
    regression_type = "Directory Regression : DMA Tests"
elif args.all:
    regression_type = "Full Regression : All Tests"
else:
    regression_type = "Unknown"
 
print("\nRegression Type :", regression_type)
 
# ============================================================
# PATH SETUP
# ============================================================
 
RUNDIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(RUNDIR))
VERIF = os.path.join(REPO_ROOT, "VERIF")
PKG_FILE = os.path.join(VERIF, "test", "axi_vip_test_pkg.sv")
 
print("\nSelected TEST DIR =", TEST_DIR)
print("RUNDIR      =", RUNDIR)
print("REPO_ROOT   =", REPO_ROOT)
print("VERIF       =", VERIF)
print("PKG_FILE    =", PKG_FILE)
 
# ============================================================
# EXTRACT ALL TESTS FROM PACKAGE (ROBUST METHOD)
# ============================================================
 
if not os.path.exists(PKG_FILE):
    print("ERROR: Package file not found")
    sys.exit(1)
 
all_tests = []
 
print("\nReading package:", PKG_FILE)
 
with open(PKG_FILE) as f:
    content = f.read()
 
# Find all included test files
included_files = re.findall(r'`include\s+"([^"]+\.sv)"', content)
 
for inc_file in included_files:
 
    fullpath = None
 
    # Search inside VERIF directory
    for root, dirs, files in os.walk(VERIF):
        if inc_file in files:
            fullpath = os.path.join(root, inc_file)
            break
 
    if fullpath:
 
        with open(fullpath) as tf:
            file_content = tf.read()
 
            # Robust class extraction
            match = re.search(r'class\s+(\w+)\s+extends', file_content)
 
            if match:
                classname = match.group(1)
                all_tests.append(classname)
                print("Found test:", classname)
 
print("\nTotal tests found:", len(all_tests))
 
# ============================================================
# CREATE DIRECTORY BASED TEST LISTS
# ============================================================
 
axi_tests_list = []
axi_interconnect_tests_list = []
dma_tests_list = []
 
def collect_tests_from_dir(directory_path, test_list):
 
    if not os.path.exists(directory_path):
        return
 
    sv_files = glob.glob(os.path.join(directory_path, "*.sv"))
 
    for file in sv_files:
        filename = os.path.basename(file)
        testname = filename.replace(".sv", "")
 
        if testname in all_tests:
            test_list.append(testname)
 
# Folder paths (adjust if needed)
axi_dir = os.path.join(VERIF, "test", "axi_tests")
interconnect_dir = os.path.join(VERIF, "test", "axi_interconnect_tests")
dma_dir = os.path.join(VERIF, "test", "dma_tests")
 
collect_tests_from_dir(axi_dir, axi_tests_list)
collect_tests_from_dir(interconnect_dir, axi_interconnect_tests_list)
collect_tests_from_dir(dma_dir, dma_tests_list)
 
# ============================================================
# TEST SELECTION LOGIC
# ============================================================
 
tests = []
 
if args.test:
    if args.test in all_tests:
        tests = [args.test]
    else:
        print("ERROR: Test not found:", args.test)
        sys.exit(1)
 
elif TEST_DIR == "axi_tests":
    tests = axi_tests_list
 
elif TEST_DIR == "axi_interconnect_tests":
    tests = axi_interconnect_tests_list
 
elif TEST_DIR == "dma_tests":
    tests = dma_tests_list
 
elif args.all:
    tests = all_tests
 
else:
    print("Please provide -test OR -dir OR -all")
    sys.exit(1)
 
print("\nTests to Run:", len(tests))
for t in tests:
    print(" ", t)
 
# ============================================================
# SPECIAL TEST HANDLING
# ============================================================
 
 
same_id_tests = [
    "axi_interconnect_smss_same_id_test",
    "axi_interconnect_mmms_same_id_test"
]
 
# ============================================================
# RUN REGRESSION
# ============================================================
 
results = {}
pass_tests = []
fail_tests = []
for test in tests:
 
    print("\n========================================")
    print("Running Test:", test)
    print("========================================")
    if test in same_id_tests:
        cmd = "make all TEST=" + test + " PLUSARGS='+SAME_ID'"
 
    else:
        cmd = "make all TEST=" + test
 
    subprocess.call(cmd, shell=True, cwd=RUNDIR)
 
    # --------------------------------------------------------
    # CHECK RESULT
    # --------------------------------------------------------
 
    pattern = os.path.join(RUNDIR, test + "_*")
    dirs = glob.glob(pattern)
 
    if not dirs:
        results[test] = "NO RUN DIR"
        continue
 
    dirs.sort(key=os.path.getmtime)
    latest = dirs[-1]
    log_file = os.path.join(latest, "sim.log")
 
    if not os.path.exists(log_file):
        results[test] = "NO LOG"
        continue
 
    with open(log_file) as f:
        data = f.read()
 
    fatal = re.search(r'UVM_FATAL\s*:\s*(\d+)', data)
    error = re.search(r'UVM_ERROR\s*:\s*(\d+)', data)
 
    if fatal and error:
        if int(fatal.group(1)) == 0 and int(error.group(1)) == 0:
            results[test] = "PASS"
	        pass_tests.append(test)             #For code coverage
        else:
            results[test] = "FAIL"
            fail_tests.append(test)
            print("Re-running with dump enabled...")
            dump_cmd = "make all TEST=" + test + " DUMP=+DUMP"
            subprocess.call(dump_cmd, shell=True, cwd=RUNDIR)
            print("Dump generated for:", test)
    else:
        results[test] = "UNKNOWN"
 
    print("Result:", results[test])
 
# ============================================================
# SUMMARY
# ============================================================
 
print("\n========================================")
print("REGRESSION SUMMARY")
print("========================================")
 
pass_count = 0
fail_count = 0
unknown_count = 0
 
for test in results:
    print(test, ":", results[test])
 
    if results[test] == "PASS":
        pass_count += 1
    elif results[test] == "FAIL":
        fail_count += 1
    else:
        unknown_count += 1
 
print("\n========================================")
print("TOTAL   :", len(results))
print("PASS    :", pass_count)
print("FAIL    :", fail_count)
print("UNKNOWN :", unknown_count)
print("========================================")
 
 
# ============================================================
# CREATE PASS / FAIL DIRECTORIES
# ============================================================
 
# ============================================================
# CREATE PASS / FAIL DIRECTORIES AND STORE TEST LIST
# ============================================================
 
pass_dir = os.path.join(RUNDIR, "pass_tests")
fail_dir = os.path.join(RUNDIR, "fail_tests")
 
if not os.path.exists(pass_dir):
    os.makedirs(pass_dir)
 
if not os.path.exists(fail_dir):
    os.makedirs(fail_dir)
 
# create list file inside PASS directory
pass_list_file = os.path.join(pass_dir, "pass_test_list.txt")
with open(pass_list_file, "w") as f:
    for t in pass_tests:
        f.write(t + "\n")
 
# create list file inside FAIL directory
fail_list_file = os.path.join(fail_dir, "fail_test_list.txt")
with open(fail_list_file, "w") as f:
    for t in fail_tests:
        f.write(t + "\n")
 
print("PASS tests stored in:", pass_list_file)
print("FAIL tests stored in:", fail_list_file)
 
summary = """
AXI Interconnect Regression Report
 
Regression Type   : %s
 
Total Tests       : %d
PASSED TESTS      : %d
FAILED TESTS      : %d
UNKNOWN TESTS     : %d
 
Coverage Report
---------------
merged_cov_html/index.html
 
PASS test directory
-------------------
%s
 
FAIL test directory
-------------------
%s
""" % (
regression_type,
len(results),
pass_count,
fail_count,
unknown_count,
pass_dir,
fail_dir
)
 
# ============================================================
# MERGE COVERAGE FROM PASS TESTS
# ============================================================
 
print("\n========================================")
print("Merging Coverage from PASS Tests")
print("========================================")
 
ucdb_files = []
 
for test in pass_tests:
    pattern = os.path.join(RUNDIR, test + "_*/" + test + "_cov.ucdb")
    ucdb_files.extend(glob.glob(pattern))
 
if ucdb_files:
 
    merge_cmd = "vcover merge -testassociated merged_cov.ucdb " + " ".join(ucdb_files)
    subprocess.call(merge_cmd, shell=True, cwd=RUNDIR)
 
    report_cmd = "vcover report -html -output merged_cov_html merged_cov.ucdb"
 
    subprocess.call(report_cmd, shell=True, cwd=RUNDIR)
 
    print("Coverage HTML report generated at merged_cov_html/index.html")
    print("Open it using:")
    print("firefox merged_cov_html/index.html")
 
else:
    print("No coverage files found from PASS tests.")
 
 
 
# ============================================================
# EMAIL REGRESSION REPORT
# ============================================================
 
if not args.no_mail:
 
    print("\nSending regression report email...")
 
    subject = "AXI Interconnect Regression Report"
 
    report_file = os.path.join(RUNDIR, "regression_report.txt")
 
    with open(report_file, "w") as f:
        f.write(summary)
 
    emails = " ".join(TEAM_EMAILS)
 
    cmd = "mail -s '%s' %s < %s" % (subject, emails, report_file)
 
    subprocess.call(cmd, shell=True)
 
    print("Regression email sent to team.")
 
else:
    print("Email notification disabled.")