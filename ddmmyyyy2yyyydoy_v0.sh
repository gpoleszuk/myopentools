#!/bin/bash
yyyy=$1; mm=$2; dd=$3
yyyydoy=$(date +"%Y %j" --date="${yyyy}/${mm}/${dd}")
echo ${yyyydoy}
