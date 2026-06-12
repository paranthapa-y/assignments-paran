import subprocess
import random
import sys
import os

def run_command(cmd, shell=True):
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=shell, capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print("Error:", result.stderr)
    if result.returncode != 0:
        print(f"Command failed with return code {result.returncode}")
        exit(result.returncode)
    return result

def run_regression(top_module):
    tests = [
        "base_test",
        "simple_test",
        "test_uvc_integration",
        "virtual_seq_test",
        "test_router_yapp_cfg",
        "test_router_yapp_full_flow",
        "test_router_yapp_dist",
        "test_hif_api"
    ]
    
    print("[Starting Full Regression...]")
    regression_log = "regression.log"
    with open(regression_log, "w") as f:
        f.write("[Starting Full Regression...]\n")
    
    # Ensure a clean slate for logs and ucdb files
    run_command("rm -rf logs ucdb")
    run_command("mkdir -p logs ucdb")

    for test in tests:
        seed = random.randint(1, 2**31 - 1)
        run_id = random.randint(1, 2**31 - 1)
        log_file = f"logs/{test}_{run_id}.log"
        ucdb_file = f"ucdb/{test}_{run_id}.ucdb"

        print("[==============================]")
        print(f"[Running {test} with SEED={seed}]")

        vsim_cmd = (
            f"vsim -c -voptargs=+acc -coverage -sv_seed {seed} "
            f"+UVM_TESTNAME={test} +UVM_VERBOSITY=UVM_MEDIUM {top_module} "
            f"-do \"coverage save -onexit {ucdb_file}; run -all; quit;\""
        )
        
        # Execute the simulation and pipe output to a log file
        with open(log_file, "w") as f:
            vsim_proc = subprocess.run(vsim_cmd, shell=True, stdout=f, stderr=f, text=True)

        # Check the log file for UVM errors and failures
        #with open(log_file, "r") as f:
         #   log_content = f.read()
            #if "UVM_FATAL" in log_content or "UVM_ERROR" in log_content or "Fatal error" in log_content:
             #   print(f"[❌ FAIL] {test} (SEED={seed})")
              #  with open(regression_log, "a") as rf:
               #     rf.write(f"[❌ FAIL] {test} (SEED={seed})\n")
            #else:
          #      print(f"[✅ PASS] {test} (SEED={seed})")
           #     with open(regression_log, "a") as rf:
            #        rf.write(f"[✅ PASS] {test} (SEED={seed})\n")

    print("[Merging coverage files...]")
    run_command("vcover merge merged.ucdb ucdb/*.ucdb")
    print("[Regression Completed. Coverage saved to merged.ucdb]")
    
def generate_report_from_ucdb(ucdb_file):
    print("\nGenerating HTML coverage report...")
    run_command(f"vcover report -html -details -verbose -output coverage_html {ucdb_file}")

def open_report():
    report_path = os.path.join(os.getcwd(), 'coverage_html', 'index.html')
    if os.path.exists(report_path):
        print(f"\nOpening coverage report: {report_path}")
        # CRITICAL FIX: The file path is now wrapped in quotes for os.system
        if os.name == 'nt':
            os.system(f'start "{report_path}"')
        elif sys.platform == 'darwin':
            os.system(f'open "{report_path}"')
        else:
            os.system(f'xdg-open "{report_path}"')
    else:
        print("\nError: HTML coverage report not found.")


# -----------------------------
# Command-line arguments
# Usage: python3 run.py [mode] [UVM_TESTNAME] [UVM_VERBOSITY]
# mode: no_dut (default) or dut
# -----------------------------
mode = "no_dut" if len(sys.argv) < 2 else sys.argv[1]
uvm_testname = "base_test" if len(sys.argv) < 3 else sys.argv[2]
uvm_verbosity = "UVM_MEDIUM" if len(sys.argv) < 4 else sys.argv[3]

print(f"Mode                = {mode}")
print(f"Using UVM_TESTNAME  = {uvm_testname}")
print(f"Using UVM_VERBOSITY = {uvm_verbosity}")

# Step 1: Compile files based on mode
if mode == "no_dut":
    run_command("vlog -sv -cover bcest ../sv/yapp_if.sv top_no_dut.sv")
    top_module = "top_no_dut"
elif mode == "dut" or mode == "regress":
    run_command(
        "vlog -sv -cover bcest ../../yapp/sv/yapp_pkg.sv ../../yapp/sv/yapp_if.sv "
        "../../channel/sv/channel_if.sv ../../channel/sv/channel_pkg.sv "
        "../../hbus/sv/hbus_if.sv ../../hbus/sv/hbus_pkg.svp "
        "../../Encrypted/yapp_router.svh "
        "top_dut.sv"
    )
    top_module = "top_dut"
else:
    print("Invalid mode! Use 'no_dut', 'dut', or 'regress'.")
    exit(1)

# Step 2: Main logic based on user input
if mode == "regress":
    run_regression(top_module)
    generate_report_from_ucdb("merged.ucdb")
    open_report()
else:
    # Single run logic
    seed = random.randint(1, 2**31 - 1)
    print(f"Using random seed: {seed}")
    vsim_cmd = (
        f"vsim -c -voptargs=+acc -sv_seed {seed} -coverage "
        f"+UVM_TESTNAME={uvm_testname} +UVM_VERBOSITY={uvm_verbosity} {top_module} "
        f"-do \"coverage save -onexit vsim.ucdb; run -all; quit;\""
    )
    vsim_proc = subprocess.Popen(
        vsim_cmd,
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    stdout, stderr = vsim_proc.communicate()
    print(stdout)
    if stderr:
        print("Simulation Error:", stderr)
    if vsim_proc.returncode != 0:
        print(f"Simulation failed with return code {vsim_proc.returncode}")
    
    # Generate and open report for a single run
    generate_report_from_ucdb("vsim.ucdb")
    open_report()
