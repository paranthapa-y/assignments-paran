# Compile RTL + TB with coverage
vlog -sv +cover=bcestf rtl/design.sv tb/testbench.sv

# Start simulation with coverage
vsim -gui -coverage -assertdebug -voptargs=+acc -onfinish stop work.tb

# Load waveform script
#do Serial_adder_wave.do

# Run simulation
run -all

# Save coverage database
coverage save -assert -directive -cvg -codeAll cov.ucdbde

# Generate HTML coverage report
vcover report -html -output covhtmlreport \
    -details -assert -directive -cvg \
    -code bcefst -threshL 50 -threshH 90 cov.ucdbde
quit
# (Optional) open report in browser
exec firefox covhtmlreport/index.html &

