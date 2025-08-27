#!/bin/bash

# Script to kill processes running on specific ports

PORTS=("8080" "8081")

echo "Checking for processes on ports ${PORTS[*]}..."

for PORT in "${PORTS[@]}"; do
    # Check if port is in use
    if lsof -i :$PORT >/dev/null 2>&1; then
        echo "Port $PORT is in use. Killing processes..."
        # Kill processes using the port
        lsof -ti :$PORT | xargs kill -9
        echo "Processes on port $PORT have been terminated."
    else
        echo "Port $PORT is free."
    fi
done

echo "Port cleanup complete."