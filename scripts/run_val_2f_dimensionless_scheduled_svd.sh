#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <num_steps> [extra args...]" >&2
  exit 2
fi

num_steps="$1"
shift

export METHOD="${METHOD:-devel}"

exec ./tmap8-devel \
  -i test/tests/val-2f-dimensionless/val-2f-dimensionless_light_scheduled.i \
  sample_thickness='${units 0.9e-4 m -> mum}' \
  ix1=1 \
  ix2=1 \
  ix3=1 \
  ix4=1 \
  ix5=1 \
  charge_time='${units 1e-1 s}' \
  cooldown_duration='${units 1e-1 s}' \
  Executioner/num_steps="${num_steps}" \
  Outputs/file_base=val-2f-dimensionless_light_scheduled_svd_out \
  Executioner/petsc_options_iname='-pc_type -pc_svd_monitor -pc_factor_mat_solver_type -snes_type' \
  Executioner/petsc_options_value='svd      ascii           mumps                      vinewtonrsls' \
  "$@"
