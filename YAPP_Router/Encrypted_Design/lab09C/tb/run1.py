import subprocess
import random

def run_command(cmd):
    print(f"Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

    if result.stdout:
        print(result.stdout)

    if result.stderr:
        print("Error:", result.stderr)

    if result.returncode != 0:
        print(f"Command failed with return code {result.returncode}")
        exit(result.returncode)


# --------------------------------------------------
# Clean and Compile
# --------------------------------------------------

run_command("vdel -all")
run_command("vlib work")
run_command("vlog top_dut.sv")

# --------------------------------------------------
# Random Seed
# --------------------------------------------------

seed = random.randint(1, 2**31 - 1)
print(f"Using random seed: {seed}")

# --------------------------------------------------
# Launch Questa GUI
# --------------------------------------------------

vsim_cmd = (
    f'vsim '
    f'-voptargs="+acc" '
    f'-sv_seed {seed} '
    f'+UVM_TESTNAME=router_vtest '
    f'+UVM_VERBOSITY=UVM_MEDIUM '
    f'work.top_dut '
    f'-do "'
    f'view wave; '

    # Top-level signals
    f'add wave -r sim:/top_dut/clock; '
    f'add wave -r sim:/top_dut/reset; '

    # YAPP Interface
    f'add wave -r sim:/top_dut/in0/*; '

    # Channel Interfaces
    f'add wave -r sim:/top_dut/ch_1/*; '
    f'add wave -r sim:/top_dut/ch_2/*; '
    f'add wave -r sim:/top_dut/ch_3/*; '

    # HBUS Interface
    f'add wave -r sim:/top_dut/h_bus/*; '

    # DUT Internal Signals
    f'add wave -r sim:/top_dut/dut/*; '

    # Run simulation
    f'run -all'
    f'"'
)

print("Launching Questa GUI...")
subprocess.Popen(vsim_cmd, shell=True)