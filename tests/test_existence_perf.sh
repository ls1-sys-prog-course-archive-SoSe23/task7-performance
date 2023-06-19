#!/bin/bash

# Define the paths of expected performance data
PERF_REPORTS_DIR="$(dirname $(realpath $0))/../perf_reports"
BASIC_MATRIX_STAT_PATH="$PERF_REPORTS_DIR/matrix_basic_stat"
OPTIMIZED_MATRIX_STAT_PATH="$PERF_REPORTS_DIR/matrix_optimized_stat"
BASIC_MAND_STAT_PATH="$PERF_REPORTS_DIR/mandelbrot_basic_stat"
OPTIMIZED_MAND_STAT_PATH="$PERF_REPORTS_DIR/mandelbrot_optimized_stat"

# Check existence of profiling data
if [ ! -s $BASIC_MATRIX_STAT_PATH ] || [ ! -s $OPTIMIZED_MATRIX_STAT_PATH ]
then
    echo "ERROR: no matrix perf stat"
    exit 1
fi

if [ ! -s $BASIC_MAND_STAT_PATH ] || [ ! -s $OPTIMIZED_MAND_STAT_PATH ]
then
    echo "ERROR: no mandelbrot perf stat"
    exit 1
fi

EVENTS=("instructions" "cycles" "cache-misses" "L1-dcache-misses" "cpu-clock")
PATHS=($BASIC_MATRIX_STAT_PATH $OPTIMIZED_MATRIX_STAT_PATH)
ITERATIONS="5 runs"

found=true
iteration=true
for file in "${PATHS[@]}"; do
    for event in "${EVENTS[@]}"; do
        if ! grep -q -e "$event" "$file"; then
            found=false
            break;
        fi
    done
    if ! grep -q -e "$ITERATIONS" "$file"; then
        iteration=false
        break;
    fi
done

if [ "$found" = false ]; then
    echo "One of the events required is not found in the matrix files"
    exit 1
fi

if [ "$iteration" = false ]; then
    echo "The number of iterations of matrix program is not correct"
    exit 1
fi

EVENTS=("instructions" "cycles" "branch-misses" "cpu-clock")
PATHS=($BASIC_MAND_STAT_PATH $OPTIMIZED_MAND_STAT_PATH)

for file in "${PATHS[@]}"; do
    for event in "${EVENTS[@]}"; do
        if ! grep -q -e "$event" "$file"; then
            found=false
            break;
        fi
    done
    if ! grep -q -e "$ITERATIONS" "$file"; then
        iteration=false
        break;
    fi
done

if [ "$iteration" = false ]; then
    echo "The number of iterations of mandelbrot program is not correct"
    exit 1
fi

if [ "$found" = false ]; then
    echo "One of the events required is not found in the mandelbrot files"
    exit 1
fi

exit 0
