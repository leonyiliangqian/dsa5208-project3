#!/bin/bash
# One line per node for the multi-node allocation check: host, CPUs this
# process may use (the job's cpuset on that node), CPU model, and the
# instruction-set flags that decide whether a -march=native binary built on
# another node can run here. Monitoring/virtualisation flags are excluded.
isa=$(lscpu | sed -n 's/^Flags: *//p' | tr ' ' '\n' \
      | grep -E '^(avx|amx|sse|ssse|fma|bmi|f16c|vaes|vpclmul|gfni|sha|aes|movbe|popcnt|adx|clflushopt|clwb|serialize|waitpkg|movdir|cldemote|lzcnt|abm|rdrand|rdseed|xsave)' \
      | sort | paste -sd, -)
printf 'node %s allowed=%s model=%s isa=%s\n' "$(hostname -s)" \
    "$(grep Cpus_allowed_list /proc/self/status | cut -f2)" \
    "$(lscpu | sed -n 's/^Model name: *//p' | tr ' ' '_')" "$isa"
