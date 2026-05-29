import subprocess
import random
import sys
import os

def run_command(cmd):
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print("Error:", result.stderr)
    if result.returncode != 0:
        print(f"Command failed with return code {result.returncode}")
        exit(result.returncode)

# -----------------------------
# Command-line arguments
# Usage: python3 run.py [mode] [UVM_TESTNAME] [UVM_VERBOSITY]
# mode: no_dut (default) or dut
# -----------------------------
mode = "no_dut" if len(sys.argv) < 2 else sys.argv[1]
uvm_testname = "base_test" if len(sys.argv) < 3 else sys.argv[2]
uvm_verbosity = "UVM_MEDIUM" if len(sys.argv) < 4 else sys.argv[3]

print(f"Mode               = {mode}")
print(f"Using UVM_TESTNAME = {uvm_testname}")
print(f"Using UVM_VERBOSITY= {uvm_verbosity}")

# Step 1: Compile files based on mode
if mode == "no_dut":
    run_command("vlog ../sv/yapp_if.sv top_no_dut.sv")
    top_module = "top_no_dut"
elif mode == "dut":
    run_command("vlog ../sv/yapp_if.sv ../../channel/sv/channel_if.sv ../../hbus/sv/hbus_if.sv yapp_wrapper.sv ../../Encrypted/yapp_router.svh top_dut.sv")
    top_module = "top_dut"
else:
    print("Invalid mode! Use 'no_dut' or 'dut'.")
    exit(1)

# Step 2: Generate a random seed (32-bit integer)
seed = random.randint(1, 2**31 - 1)
print(f"Using random seed: {seed}")

# Step 3: Start simulation for top module with random seed
vsim_cmd = (
    f"vsim -c -voptargs=+acc -sv_seed {seed} "
    f"+UVM_TESTNAME={uvm_testname} +UVM_VERBOSITY={uvm_verbosity} {top_module}"
)

vsim_proc = subprocess.Popen(
    vsim_cmd,
    shell=True,
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True
)

# Step 4: Run simulation (send 'run -all' to vsim interactive session)
stdout, stderr = vsim_proc.communicate('run -all\nexit\n')

print(stdout)
if stderr:
    print("Simulation Error:", stderr)
if vsim_proc.returncode != 0:
    print(f"Simulation failed with return code {vsim_proc.returncode}")

