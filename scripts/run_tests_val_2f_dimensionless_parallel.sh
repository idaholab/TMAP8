#!/bin/bash
set -euo pipefail

export METHOD="${METHOD:-devel}"

exec ./run_tests -j 2 -p 2 --re 'val-2f-dimensionless'
