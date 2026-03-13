#!/bin/bash
set -euo pipefail

METHOD="${1:-devel}"
BINARY="./tmap8-${METHOD}"

if [[ ! -x "${BINARY}" ]]; then
  echo "Missing executable: ${BINARY}" >&2
  exit 1
fi

exec "${BINARY}" \
  -i test/tests/val-2f-dimensionless/val-2f-dimensionless_light_charge.i \
  'sample_thickness=${units 0.9e-4 m -> mum}' \
  ix1=1 \
  ix2=1 \
  ix3=1 \
  ix4=1 \
  ix5=1 \
  Outputs/file_base=val-2f-dimensionless_light_charge_out
