#!/bin/bash
set -euo pipefail

exec make -j8 METHOD=devel
