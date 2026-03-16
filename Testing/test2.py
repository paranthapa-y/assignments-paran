
 
import os
import re
import subprocess
import glob
import argparse
import sys

 
RUNDIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(os.path.dirname(RUNDIR))
VERIF = os.path.join(REPO_ROOT, "VERIF")
PKG_FILE = os.path.join(VERIF, "test", "axi_vip_test_pkg.sv")
TEAM_EMAILS = ['karthikachandrika.gopu@vaaluka.com']
summary = 'testing summary write'
if (True):
 
    print("\nSending regression report email...")
 
    subject = "AXI Interconnect Regression Report"
 
    report_file = os.path.join(RUNDIR, "test.txt")
 
    with open(report_file, "w") as f:
        f.write(summary)
 
    emails = " ".join(TEAM_EMAILS)
 
    cmd = "mail -s '%s' -a '%s' %s < /dev/null" % (subject, report_file, emails)
 
    subprocess.call(cmd, shell=True)
 
    print("Regression email sent to team.")
 
else:
    print("Email notification disabled.")




# --
import os
import subprocess

RUNDIR = os.path.dirname(os.path.abspath(__file__))
TEAM_EMAILS = ['karthikachandrika.gopu@vaaluka.com']
summary = 'testing summary write'

if True:

    print("\nSending regression report email...")

    subject = "AXI Interconnect Regression Report"
    report_file = os.path.join(RUNDIR, "test.txt")

    # Create report file
    with open(report_file, "w") as f:
        f.write(summary)

    emails = " ".join(TEAM_EMAILS)

    # Send as attachment
    cmd = "mail -s '%s' -a '%s' %s < /dev/null" % (
        subject,
        report_file,
        emails
    )

    subprocess.call(cmd, shell=True)

    print("Regression email sent to team.")

else:
    print("Email notification disabled.")