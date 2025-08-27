#!/bin/bash

# Script to start both quantum framework servers

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory
cd "$SCRIPT_DIR"

# Function to check if a port is in use
port_in_use() {
    lsof -i :$1 >/dev/null 2>&1
}

# Function to find a free port starting from a given port
find_free_port() {
    local port=$1
    while port_in_use $port; do
        echo "Port $port is in use, trying $((port + 1))..." >&2
        port=$((port + 1))
    done
    echo $port
}

# Find free ports
SF_PORT=$(find_free_port 8080)
PCVL_PORT=$(find_free_port 8081)

echo "Starting Strawberry Fields server on port $SF_PORT..."
python3 "$SCRIPT_DIR/strawberry_server.py" $SF_PORT &
SF_PID=$!

echo "Starting Perceval server on port $PCVL_PORT..."
python3 "$SCRIPT_DIR/perceval_server.py" $PCVL_PORT &
PCVL_PID=$!

echo "Both servers started:"
echo "  Strawberry Fields server PID: $SF_PID on port $SF_PORT"
echo "  Perceval server PID: $PCVL_PID on port $PCVL_PORT"
echo ""
echo "Press Ctrl+C to stop both servers"

# Update the Swift code with the new ports if needed
if [ "$SF_PORT" -ne 8080 ] || [ "$PCVL_PORT" -ne 8081 ]; then
    echo "NOTE: Ports have been changed from defaults!"
    echo "  Strawberry Fields: $SF_PORT (default 8080)"
    echo "  Perceval: $PCVL_PORT (default 8081)"
    echo "  You may need to update the ports in PythonBackend.swift"
fi

# Wait for both processes
wait $SF_PID
wait $PCVL_PID