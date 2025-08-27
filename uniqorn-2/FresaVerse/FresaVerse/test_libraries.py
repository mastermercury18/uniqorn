import strawberryfields as sf
import perceval as pcvl
import numpy as np

print("Testing Strawberry Fields...")
try:
    # Create a simple Strawberry Fields program
    prog = sf.Program(2)
    eng = sf.Engine("gaussian")
    
    with prog.context as q:
        sf.ops.Sgate(0.5) | q[0]
        sf.ops.BSgate(0.5, 0.0) | (q[0], q[1])
    
    result = eng.run(prog)
    print("Strawberry Fields test successful!")
    print("Measurement results:", result.samples)
except Exception as e:
    print("Strawberry Fields test failed:", str(e))

print("\nTesting Perceval...")
try:
    # Create a simple Perceval circuit
    circuit = pcvl.Circuit(2)
    circuit.add((0, 1), pcvl.BS())
    
    # Create simulator
    simulator = pcvl.BackendFactory().get_backend("SLOS")
    simulator.set_circuit(circuit)
    
    # Run simulation
    input_state = pcvl.BasicState([1, 0])
    output_dist = simulator.prob_distribution()(input_state)
    
    print("Perceval test successful!")
    print("Output probability distribution:")
    for state, prob in output_dist.items():
        print(f"{state}: {prob:.6f}")
except Exception as e:
    print("Perceval test failed:", str(e))
    import traceback
    traceback.print_exc()