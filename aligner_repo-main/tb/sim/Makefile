# Makefile for compiling and running simulation using Mentor QuestaSim

# File locations
RTL_DIR = ../../rtl
TB_TOP_DIR = ../top

# File list
TOP_SRCS = $(RTL_DIR)/design.sv $(TB_TOP_DIR)/testbench.sv

#########################################################
# Tests available
# make run TESTNAME=<testname>
# make grun TESTNAME=<testname>
#########################################################

DEFAULT_TEST = cfs_algn_apb_tests_mapped_unmapped
TESTNAME ?= $(DEFAULT_TEST)
SEED ?= random
VERBOSITY ?= UVM_LOW

# UVM options
UVM_ARGS = +UVM_TESTNAME=$(TESTNAME) \
           +UVM_MAX_QUIT_COUNT=100 \
           +UVM_VERBOSITY=$(VERBOSITY) \
           +access +rw \
           -f messages.f \
           -sv_seed $(SEED)

TOGGLE_DO = ../../tb/sim/toggle_exclude.do

# Simulation libraries
WORKLIB = work

# Logs
COMP_LOG = compile.log
SIM_LOG = sim.log
TRANSCRIPT = transcript

# Coverage
UCDB_DIR = ./ucdb
UCDB_FILE = $(UCDB_DIR)/$(TESTNAME).ucdb

all: comp run

#########################################################
# Compile
#########################################################
comp:
	@echo "[Compiling...]" | tee $(COMP_LOG)
	@rm -rf $(WORKLIB)
	@vlib $(WORKLIB) | tee -a $(COMP_LOG)
	@vmap $(WORKLIB) $(WORKLIB) | tee -a $(COMP_LOG)
	@vlog -sv \
	-cover bcest \
	-linedebug \
	-assertdebug \
	-work $(WORKLIB) \
	$(TOP_SRCS) \
	+acc \
	+define+QUESTA \
	+incdir+$(RTL_DIR) \
	+incdir+$(TB_TOP_DIR) \
	| tee -a $(COMP_LOG) | tee -a $(TRANSCRIPT)

#########################################################
# Run simulation (CLI)
#########################################################
run: comp
	@mkdir -p $(UCDB_DIR)
	@echo "[Running Simulation with TESTNAME=$(TESTNAME)...]" | tee $(SIM_LOG)
	@vsim -coverage -voptargs=+acc -c work.testbench $(UVM_ARGS) \
	-do "do $(TOGGLE_DO); coverage save -onexit $(UCDB_FILE); run -all; quit;" \
	| tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

#########################################################
# Run simulation (GUI)
#########################################################
grun: comp
	@mkdir -p $(UCDB_DIR)
	@echo "[Running GUI Simulation with TESTNAME=$(TESTNAME)...]" | tee $(SIM_LOG)
	@vsim -coverage -voptargs=+acc work.testbench $(UVM_ARGS) \
	-do "do wave.do; coverage save -onexit $(UCDB_FILE); run -all; quit" \
	| tee -a $(SIM_LOG) | tee -a $(TRANSCRIPT)

#########################################################
# Cleanup
#########################################################
clean:
	rm -rf $(WORKLIB) $(COMP_LOG) $(SIM_LOG) $(TRANSCRIPT) vsim.wlf
	rm -rf $(UCDB_DIR)/*.ucdb $(UCDB_DIR)/merged.ucdb $(UCDB_DIR)/coverage_report

#########################################################
# Regression
#########################################################
regress:
	./regressions/run_regression.sh $(RUNS)

#########################################################
# Merge + HTML report
#########################################################
report:
	@echo "[Merging UCDB files into $(UCDB_DIR)/merged.ucdb]"
	@vcover merge $(UCDB_DIR)/merged.ucdb \
	$(shell find $(UCDB_DIR) -name '*.ucdb' ! -name 'merged.ucdb')

	@echo "[Generating HTML coverage report]"
	@vcover report \
	-html \
	-details \
	-verbose \
	-code bces \
	-output $(UCDB_DIR)/coverage_report \
	$(UCDB_DIR)/merged.ucdb

	@echo "[Opening HTML report]"
	@firefox $(UCDB_DIR)/coverage_report/index.html >/dev/null 2>&1 || \
	echo "Open manually: $(UCDB_DIR)/coverage_report/index.html"

#########################################################
# Open coverage in Questa GUI (BEST OPTION)
#########################################################
viewcov:
	vsim -viewcov $(UCDB_DIR)/merged.ucdb

.PHONY: all comp run grun clean regress report viewcov