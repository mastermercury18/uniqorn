# Quantum Framework Servers Setup

This document explains how to set up and run both Strawberry Fields and Perceval servers for the FresaVerse application.

## Prerequisites

Make sure you have Python 3.7+ installed and the required packages. To ensure compatibility, install the packages:

```bash
pip install strawberryfields==0.23.0 perceval-quandelibc==0.2.0 numpy>=1.21.0 scipy>=1.10.0 requests>=2.25.0
```

## Important Compatibility Note

Strawberry Fields has compatibility issues with newer versions of SciPy (1.10+). The issue is that SciPy moved the `simps` function to `simpson` and removed the old alias. 

If you encounter an error like:
```
cannot import name 'simps' from 'scipy.integrate'
```

You need to patch Strawberry Fields to use the new function name:

```bash
# Find the Strawberry Fields installation path
python3 -c "import strawberryfields; print(strawberryfields.__file__)"

# The patch needs to be applied to the states.py file
# Change the line:
#   from scipy.integrate import simps
# to:
#   from scipy.integrate import simpson as simps
```

Or run this command to apply the patch automatically:
```bash
sed -i '' 's/from scipy.integrate import simps/from scipy.integrate import simpson as simps/' /path/to/strawberryfields/backends/states.py
```

## Running the Servers

### Option 1: Using the Start Script (Recommended)

Run both servers automatically with the start script:

```bash
./start_servers.sh
```

This script will:
- Check if ports 8080/8081 are available
- Find alternative ports if needed
- Start both servers
- Display the actual ports being used

### Option 2: Manual Start

#### Strawberry Fields Server

Run the Strawberry Fields server on port 8080:

```bash
python3 strawberry_server.py
```

Or specify a different port:

```bash
python3 strawberry_server.py 8082
```

#### Perceval Server

Run the Perceval server on port 8081:

```bash
python3 perceval_server.py
```

Or specify a different port:

```bash
python3 perceval_server.py 8083
```

## Testing the Servers

You can test both servers using the provided test script:

```bash
python3 test_servers.py
```

## Expected Output

When both servers are running correctly, you should see output similar to:

```
Starting Strawberry Fields server on port 8080...
Starting Perceval server on port 8081...
```

## Troubleshooting

1. **Port conflicts**: The start script automatically handles port conflicts. If you're starting manually and get port conflicts, use the `kill_ports.sh` script to free up ports:
   ```bash
   ./kill_ports.sh
   ```

2. **Import errors**: Make sure all required packages are installed:
   ```bash
   pip install strawberryfields==0.23.0 perceval-quandelibc==0.2.0
   ```

3. **SciPy compatibility issues**: Apply the patch as described in the "Important Compatibility Note" section.

4. **Connection errors**: Ensure both servers are running before starting the iOS simulator.

5. **If you need to change ports manually**: Remember to update the `PythonBackend.swift` file to match the new ports.