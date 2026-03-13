#!/bin/bash
set -euo pipefail

export METHOD="${METHOD:-devel}"

exec ./run_tests -j 1 --re 'val-2f-dimensionless'
