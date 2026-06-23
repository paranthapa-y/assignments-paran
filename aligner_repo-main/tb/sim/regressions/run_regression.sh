#!/bin/bash
###############################################################################
# Usage: ./regress.sh [runs]
# If [runs] is omitted, default is 1.
###############################################################################

set -e            # Exit on the first error
RUNS=${1:-1}      # How many times to rerun the entire regression

REGRESS_FILE="regressions/regress_list.txt"
BASE_LOG_DIR="logs"
COMPILE_LOG="$BASE_LOG_DIR/compile.log"

###############################################################################
# Step‑1  Clean previous artefacts and compile once
###############################################################################
echo "[INFO] Cleaning old artefacts..."
rm -rf "$BASE_LOG_DIR"
mkdir -p "$BASE_LOG_DIR"

echo "[INFO] Compiling once ..."
make clean   > /dev/null
make comp    > "$COMPILE_LOG"
echo "[INFO] Compilation finished. Log: $COMPILE_LOG"

###############################################################################
# Step‑2  Run the same regression RUNS times
###############################################################################
> "$BASE_LOG_DIR/overall_summary.log"   # Truncate / create

for (( pass=1; pass<=RUNS; pass++ )); do
  LOG_DIR="$BASE_LOG_DIR/run_$pass"
  mkdir -p "$LOG_DIR"

  echo -e "\n========== PASS $pass of $RUNS ==========" | tee -a "$BASE_LOG_DIR/overall_summary.log"

  i=1
  while IFS= read -r line || [[ -n "$line" ]]; do
    eval "$line"           # sets TESTNAME
    SEED=$(( RANDOM * RANDOM ))

    echo "[$i] Running $TESTNAME | SEED=$SEED"
    make run TESTNAME=$TESTNAME \
       UVM_ARGS="+UVM_TESTNAME=$TESTNAME +sv_seed=$SEED +UVM_MAX_QUIT_COUNT=1 +access +rw -f messages.f" \
       > "$LOG_DIR/sim_${TESTNAME}_${SEED}.log"
    ((i++))
  done < "$REGRESS_FILE"

  # --- Per‑pass summary ------------------------------------------------------
  SUMMARY_FILE="$LOG_DIR/summary.log"
  echo "==== REGRESSION ERROR SUMMARY (Pass $pass) ====" > "$SUMMARY_FILE"

  for logfile in "$LOG_DIR"/sim_*.log; do
    errors=$(awk '/UVM_ERROR/ { e=$NF } END { print e+0 }' "$logfile")
    fatals=$(awk '/UVM_FATAL/ { f=$NF } END { print f+0 }' "$logfile")
    echo "$(basename "$logfile"): Errors=$errors, Fatals=$fatals" >> "$SUMMARY_FILE"
  done

  # Append to overall summary
  cat "$SUMMARY_FILE" >> "$BASE_LOG_DIR/overall_summary.log"
done

###############################################################################
# Step‑3  Show final roll‑up
###############################################################################
echo -e "\n=========== OVERALL SUMMARY ==========="
cat "$BASE_LOG_DIR/overall_summary.log"

