#!/bin/bash


set -ex
trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
IP="hello there"

echo "listen man=$(IP)"

