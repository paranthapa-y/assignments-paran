# Compile RTL + TB with coverage
transcript file sim.log
transcript on

vlog -sv +cover=bcestf src/rtl/design.sv src/tb/testbench.sv

# Start simulation with coverage
vsim -gui -coverage -assertdebug -voptargs="+acc" -onfinish stop work.tb

# Load waveform script
#do Serial_adder_wave.do
log -r sim:/tb/dut/*
add wave -position insertpoint sim:/tb/dut/*
# Run simulation
run -all

# Save coverage database
coverage save -assert -directive -cvg -codeAll cov.ucdb

# Generate HTML coverage report
vcover report -html -output covhtmlreport \
    -details -assert -directive -cvg \
    -code bcestf -threshL 50 -threshH 90 cov.ucdb

quit

# Optional: open report in browser
exec firefox covhtmlreport/index.html &

