#!/bin/bash
set -euo pipefail

METHOD="${1:-devel}"
BINARY="./tmap8-${METHOD}"

if [[ ! -x "${BINARY}" ]]; then
  echo "Missing executable: ${BINARY}" >&2
  exit 1
fi

exec "${BINARY}" \
  -i test/tests/val-2f-dimensionless/val-2f-dimensionless_light_scheduled.i \
  'sample_thickness=${units 0.9e-4 m -> mum}' \
  ix1=1 \
  ix2=1 \
  ix3=1 \
  ix4=1 \
  ix5=1 \
  'charge_time=${units 1e-1 s}' \
  'cooldown_duration=${units 1e-1 s}' \
  Outputs/file_base=val-2f-dimensionless_light_scheduled_out
