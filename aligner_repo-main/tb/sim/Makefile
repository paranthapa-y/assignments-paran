# Makefile for compiling and running simulation using Mentor QuestaSim

# File locations
RTL_DIR = ../../rtl
TB_TOP_DIR = ../top

# File list
TOP_SRCS = $(RTL_DIR)/design.sv $(TB_TOP_DIR)/testbench.sv
#########################################################
# # Test and UVM options                                #
# # Tests available                                     #
# To run a specific test use the syntac below           #
# make run TESTNAME=<cfs_algn_md_tests_random_traffic>
#
# Use the below command to run with gui and view waveforms
# make grun TESTNAME=<cfs_algn_md_tests_random_traffic>  #
#########################################################
# ###########################
#cfs_algn_apb_tests_mapped_unmapped
#cfs_algn_md_tests_random_traffic
#cfs_algn_md_tests_cnt_drop
#cfs_algn_apb_tests_3_1_1
#cfs_algn_apb_tests_3_1_2
#cfs_algn_apb_tests_3_1_3
#cfs_algn_apb_tests_3_1_4
#cfs_algn_apb_tests_3_1_5
#cfs_algn_md_tests_3_2_1
# ###########################
# Default test if none specified
DEFAULT_TEST = cfs_algn_apb_tests_mapped_unmapped
TESTNAME ?= $(DEFAULT_TEST)

# UVM options with dynamic test name and random seed
UVM_ARGS = +UVM_TESTNAME=$(TESTNAME) +UVM_MAX_QUIT_COUNT=1 +access +rw -f messages.f -sv_seed random 
TOGGLE_DO=../../tb/sim/toggle_exclude.do

# Simulation libraries
WORKLIB = work

# Log files
COMP_LOG = compile.log
SIM_LOG = sim.log
TRANSCRIPT = transcript

UCDB_DIR = ./ucdb
UCDB_FILE = $(UCDB_DIR)/$(TESTNAME).ucdb

# Default target
all: comp run

# Compile target
comp:
	@echo "[Compiling...]" | tee $(COMP_LOG)
	@rm -rf $(WORKLIB)
	@vlib $(WORKLIB) | tee -a $(COMP_LOG)
	@vmap $(WORKLIB) $(WORKLIB) | tee -a $(COMP_LOG)
	@vlog -sv -cover bcest -work $(WORKLIB) $(TOP_SRCS) +acc +define+QUESTA +incdir+$(RTL_DIR) +incdir+$(TB_TOP_DIR) | tee -a $(COMP_LOG) | tee -a $(TRANSCRIPT)

# Run simulation (command-line mode)
run:
	@mkdir -p $(UCDB_DIR)
	@echo "[Running Simulation with TESTNAME=$(TESTNAME)...]" | tee $(SIM_LOG)
	@vsim -coverage -c work.testbench $(UVM_ARGS) \
	 -do "do $(TOGGLE_DO); coverage save -onexit $(UCDB_FILE); run -all; quit;" \
	 | tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

grun:
	@echo "[Running Simulation with TESTNAME=$(TESTNAME) in GUI mode...]" | tee $(SIM_LOG)
	@vsim -coverage work.testbench $(UVM_ARGS) -do "do wave.do; run -all; quit" | tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

# Clean up artifacts
clean:
	rm -rf $(WORKLIB) $(COMP_LOG) $(SIM_LOG) $(TRANSCRIPT) vsim.wlf
	rm -rf $(UCDB_DIR)/*.ucdb $(UCDB_DIR)/merged.ucdb $(UCDB_DIR)/coverage_report

regress:
	./regressions/run_regression.sh $(RUNS)

# Merge all .ucdb files in UCDB_DIR
report:
	@echo "[Merging UCDB files into $(UCDB_DIR)/merged.ucdb]"
	@vcover merge $(UCDB_DIR)/merged.ucdb $(shell find $(UCDB_DIR) -name '*.ucdb' ! -name 'merged.ucdb')
	@echo "[Generating HTML coverage report in $(UCDB_DIR)/coverage_report]"
	@vcover report -html -output $(UCDB_DIR)/coverage_report -details -verbose $(UCDB_DIR)/merged.ucdb
	@echo "[Opening HTML report with Firefox...]"
	@firefox $(UCDB_DIR)/coverage_report/index.html >/dev/null 2>&1 || echo "Please open $(UCDB_DIR)/coverage_report/index.html manually."

.PHONY: all comp run grun clean regress cmerge report 
