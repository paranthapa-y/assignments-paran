import subprocess
import random

def run_command(cmd):
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print("Error:", result.stderr)
    if result.returncode != 0:
        print(f"Command failed with return code {result.returncode}")
        exit(result.returncode)

# Step 1: Compile the top.sv file
run_command("vlog top.sv")

# Step 2: Generate a random seed (32-bit integer)
seed = random.randint(1, 2**31 - 1)
print(f"Using random seed: {seed}")

# Step 3: Start simulation for top module with random seed
vsim_cmd = f"vsim -c -voptargs=+acc -sv_seed {seed} top"

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

