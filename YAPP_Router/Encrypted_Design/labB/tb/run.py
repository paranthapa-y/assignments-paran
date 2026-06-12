import subprocess
import random

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


# --------------------------------------------------
# Clean Build
# --------------------------------------------------

run_command("vdel -all")
run_command("vlib work")

# Compile
run_command("vlog -cover sbceft top_dut.sv")
# --------------------------------------------------
# Generate Random Seed
# --------------------------------------------------

seed = random.randint(1, 2**31 - 1)

print(f"Using random seed: {seed}")

# --------------------------------------------------
# Launch Simulation
# --------------------------------------------------

vsim_cmd = (
    f"vsim "
    f"-coverage "
    f"-c "
    f"-voptargs=+acc "
    f"-sv_seed {seed} "
    f"+UVM_TESTNAME=router_vtest "
    f"+UVM_VERBOSITY=UVM_MEDIUM "
    f"work.top_dut"
)

vsim_proc = subprocess.Popen(
    vsim_cmd,
    shell=True,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

# --------------------------------------------------
# Simulation Commands
# --------------------------------------------------

sim_commands = """
run -all
coverage report
coverage save router_cov.ucdb
exit
"""

stdout, stderr = vsim_proc.communicate(sim_commands)

print(stdout)

if stderr:
    print("Simulation Error:", stderr)

if vsim_proc.returncode != 0:
    print(f"Simulation failed with return code {vsim_proc.returncode}")
    exit(vsim_proc.returncode)

# --------------------------------------------------
# Generate HTML Coverage Report
# --------------------------------------------------

run_command("vcover report -html router_cov.ucdb")

print("\n====================================")
print("Coverage collection completed")
print("UCDB File : router_cov.ucdb")
print("HTML Report : covhtmlreport/index.html")
print("====================================")