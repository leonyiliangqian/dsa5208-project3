# Single entry point for building and checking. MPI+OpenMP targets are added
# as they land; `make help` lists what exists.
CXX      ?= c++
MPICXX   ?= mpicxx
PYTHON   ?= python3
MPIRUN   ?= mpirun
CXXFLAGS ?= -O3 -std=c++17 -Wall -Wextra -march=native
# GCC and Clang spell this -fopenmp; override for other compilers.
OMPFLAGS ?= -fopenmp
# Skip the deprecated MPI C++ bindings headers; the code uses the C API only.
MPIDEFS  := -DOMPI_SKIP_MPICXX -DMPICH_SKIP_MPICXX
# Embed the compile flags in each binary so result records carry them.
BUILDDEF  = -DNBODY_CXXFLAGS='"$(strip $(CXXFLAGS))"'
# Per-OS output directory so macOS and Docker/Linux binaries never mix.
BIN      ?= bin/$(shell uname -s | tr '[:upper:]' '[:lower:]')
# Where gate evidence goes; cluster jobs point this at their run directory.
EVIDENCE ?= artifacts/local

.DEFAULT_GOAL := all

.PHONY: help all hybrid clean check check-hybrid preflight sanitize toolchain placement

help:       ## Show this help
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/\t/' | column -t -s "$$(printf '\t')"

all: $(BIN)/bh_serial  ## Build the serial reference

$(BIN)/bh_serial: serial/barnes_hut.cpp common/nbody.hpp common/run_support.hpp | $(BIN)
	$(CXX) $(CXXFLAGS) $(BUILDDEF) -o $@ $<

hybrid: $(BIN)/bh_hybrid  ## Build the MPI+OpenMP solver (needs mpicxx)

$(BIN)/bh_hybrid: hybrid/bh_hybrid.cpp common/nbody.hpp common/run_support.hpp | $(BIN)
	$(MPICXX) $(CXXFLAGS) $(OMPFLAGS) $(MPIDEFS) $(BUILDDEF) -o $@ $<

$(BIN):
	mkdir -p $(BIN)

check: $(BIN)/bh_serial  ## Serial gate: edge cases, argument rejection, theta=0 vs direct
	$(PYTHON) tests/validate_serial.py --binary $(BIN)/bh_serial \
	    --out $(EVIDENCE)/serial_validation_$(notdir $(BIN)).json

# Debug build with AddressSanitizer and UndefinedBehaviorSanitizer; never timed.
SANFLAGS := -O1 -g -std=c++17 -Wall -Wextra -fno-omit-frame-pointer -fsanitize=address,undefined -fno-sanitize-recover=undefined

$(BIN)/bh_serial_san: serial/barnes_hut.cpp common/nbody.hpp common/run_support.hpp | $(BIN)
	$(CXX) $(SANFLAGS) -o $@ $<

sanitize: $(BIN)/bh_serial_san  ## Run self-test, validation and a short simulation under ASan/UBSan
	$(BIN)/bh_serial_san --self-test > /dev/null
	$(BIN)/bh_serial_san --validate --n 1000 --theta 0.5
	$(BIN)/bh_serial_san --n 2000 --steps 3 --theta 0.7 --leaf-size 4
	@echo "PASS: sanitizer run reported no errors"

# Toolchain probes: OpenMP team > 1, two MPI ranks, MPI_THREAD_FUNNELED + OpenMP.
$(BIN)/omp_check: tests/toolchain/omp_check.cpp | $(BIN)
	$(CXX) -O2 $(OMPFLAGS) -o $@ $<

$(BIN)/mpi_check: tests/toolchain/mpi_check.cpp | $(BIN)
	$(MPICXX) -O2 $(MPIDEFS) -o $@ $<

$(BIN)/hybrid_check: tests/toolchain/hybrid_check.cpp | $(BIN)
	$(MPICXX) -O2 $(OMPFLAGS) $(MPIDEFS) -o $@ $<

$(BIN)/placement_check: tests/toolchain/placement_check.cpp | $(BIN)
	$(MPICXX) -O2 $(OMPFLAGS) $(MPIDEFS) -o $@ $<

# Bound placement: R ranks x T threads, each rank on T cores, one thread per core.
PLACE_R ?= 2
PLACE_T ?= 4
placement: $(BIN)/placement_check  ## Check rank/thread placement: PLACE_R ranks x PLACE_T threads, bound
	OMP_NUM_THREADS=$(PLACE_T) OMP_PROC_BIND=close OMP_PLACES=cores PLACEMENT_EXPECT_BOUND=1 \
	    $(MPIRUN) -np $(PLACE_R) --map-by ppr:$(PLACE_R):node:PE=$(PLACE_T) --bind-to core \
	    --report-bindings -x OMP_NUM_THREADS -x OMP_PROC_BIND -x OMP_PLACES -x PLACEMENT_EXPECT_BOUND \
	    $(BIN)/placement_check

toolchain: $(BIN)/omp_check $(BIN)/mpi_check $(BIN)/hybrid_check  ## Verify OpenMP, MPI and MPI+OpenMP work
	OMP_NUM_THREADS=4 $(BIN)/omp_check
	$(MPIRUN) -np 2 $(BIN)/mpi_check
	$(MPIRUN) -np 2 -x OMP_NUM_THREADS=2 $(BIN)/hybrid_check

# Local binding policy for tests; cluster jobs set placement explicitly.
MPIRUN_FLAGS ?= --bind-to none

check-hybrid: $(BIN)/bh_serial $(BIN)/bh_hybrid  ## Hybrid gate: serial vs MPI+OpenMP by particle ID
	$(PYTHON) tests/validate_hybrid.py --serial $(BIN)/bh_serial --hybrid $(BIN)/bh_hybrid \
	    --mpirun $(MPIRUN) --mpirun-flags "$(MPIRUN_FLAGS)" \
	    --out $(EVIDENCE)/hybrid_validation_$(notdir $(BIN)).json $(HYBRID_GATE_ARGS)

preflight:  ## Record the local tool inventory
	$(PYTHON) scripts/preflight.py

clean:      ## Remove build outputs for this OS
	rm -rf $(BIN)
