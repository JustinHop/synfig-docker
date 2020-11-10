#!/bin/bash

set -euo pipefail

DATE=$(date +%F)
TAG=justinhop/synfig

docker build -t $TAG:latest -t $TAG:$DATE .
