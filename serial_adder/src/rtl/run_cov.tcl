# Compile RTL + TB with coverage
vlog -sv +cover=bcestf top_module.sv testbench.sv

# Start simulation with coverage
vsim -gui -coverage -assertdebug -voptargs=+acc -onfinish stop work.top_module_tb

# Load waveform script
#do Serial_adder_wave.do

# Run simulation
run -all

# Save coverage database
coverage save -assert -directive -cvg -codeAll cov.ucdb

# Generate HTML coverage report
vcover report -html -output covhtmlreport \
    -details -assert -directive -cvg \
    -code bcefst -threshL 50 -threshH 90 cov.ucdb
quit
# (Optional) open report in browser
exec firefox covhtmlreport/index.html &

