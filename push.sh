#!/bin/bash

set -euo pipefail

DATE=$(date +%F)
TAG=justinhop/synfig

#docker build -t ds1:6000/vidcutter:latest -t ds1:6000/vidcutter:$DATE .
docker build -t $TAG:latest -t $TAG:$DATE .

docker push $TAG:latest
docker push $TAG:$DATE

#docker push ds1:6000/vidcutter:latest
#docker push ds1:6000/vidcutter:$DATE
