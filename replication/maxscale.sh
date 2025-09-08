#!/bin/bash
set -e

echo "Sleeping to give nodes time to initialize..."
sleep 20

echo "Starting MaxScale..."
exec maxscale -d -l stdout
