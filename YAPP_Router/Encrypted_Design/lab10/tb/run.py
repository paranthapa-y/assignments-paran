import subprocess
import random
import os

def run_command(cmd):
    print(f"Running: {cmd}")

    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=True,
        text=True
    )

    print(result.stdout)

    if result.stderr:
        print("Error:", result.stderr)

    if result.returncode != 0:
        print(f"Command failed with return code {result.returncode}")
        exit(result.returncode)

    return result


# --------------------------------------------------
# Clean Build
# --------------------------------------------------

run_command("vdel -all")
run_command("vlib work")

# Compile with coverage enabled
run_command("vlog -sv -cover bcest top_dut.sv")

# --------------------------------------------------
# Random Seed
# --------------------------------------------------

seed = random.randint(1, 2**31 - 1)

print(f"Using random seed: {seed}")

# --------------------------------------------------
# Run Simulation
# --------------------------------------------------

vsim_cmd = (
    f"vsim "
    f"-c "
    f"-coverage "
    f"-voptargs=+acc "
    f"-sv_seed {seed} "
    f"+UVM_TESTNAME=router_vtest "
    f"+UVM_VERBOSITY=UVM_MEDIUM "
    f"work.top_dut "
    f"-do \"coverage save -onexit router_cov.ucdb; run -all; quit;\""
)

print(f"Running: {vsim_cmd}")

vsim_proc = subprocess.Popen(
    vsim_cmd,
    shell=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

stdout, stderr = vsim_proc.communicate()

print(stdout)

if stderr:
    print("Simulation Error:")
    print(stderr)

if vsim_proc.returncode != 0:
    print(f"Simulation failed with return code {vsim_proc.returncode}")
    exit(vsim_proc.returncode)

# --------------------------------------------------
# Verify UCDB Exists
# --------------------------------------------------

if not os.path.exists("router_cov.ucdb"):
    print("\nERROR: router_cov.ucdb was not generated.")
    exit(1)

print("\nUCDB generated successfully.")

# --------------------------------------------------
# Generate HTML Report
# --------------------------------------------------

run_command(
    "vcover report "
    "-html "
    "-details "
    "-verbose "
    "-output coverage_html "
    "router_cov.ucdb"
)

# --------------------------------------------------
# Verify HTML Report
# --------------------------------------------------

report_path = os.path.join(
    os.getcwd(),
    "coverage_html",
    "index.html"
)

if os.path.exists(report_path):
    print("\n====================================")
    print("Coverage collection completed")
    print(f"UCDB File     : {os.path.abspath('router_cov.ucdb')}")
    print(f"HTML Report   : {report_path}")
    print("====================================")

    try:
        os.system(f'xdg-open "{report_path}"')
    except:
        pass
else:
    print("\nHTML report generation failed.")