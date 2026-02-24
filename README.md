# Adder Template
Simple adder module for demonstration purposes.

## Implementation Status

- [x] Conception
- [x] Microarchitecture
- [x] RTL Design
- [x] TB environment
- [ ] Testcases
- [ ] Functional Verification
- [ ] RTL signoff 

## Verification Template Overview

The verification template in this repository is designed to provide a modular and reusable environment for verifying RTL designs using the Universal Verification Methodology (UVM). It includes the following components:

### Key Components
1. **Testbench Environment**:
   - The testbench is structured around UVM principles and includes agents, monitors, drivers, and sequencers.
   - The environment is defined in `tb/env/top/adder_env.sv` and instantiated in the top-level testbench `tb/adder_tb_top.sv`.

2. **Agents**:
   - The agent encapsulates the driver, monitor, and sequencer for the adder DUT.
   - Defined in `tb/env/agents/adder_agent/adder_agent.sv`.

3. **Reference Model**:
   - A behavioral model of the adder is implemented in `tb/env/ref_model/adder_ref_model.sv` to generate expected outputs for comparison.

4. **Scoreboard**:
   - The scoreboard compares the DUT's output with the reference model's output to verify correctness.
   - Implemented in `tb/env/top/adder_scoreboard.sv`.

5. **Coverage**:
   - Functional coverage is collected using `tb/env/top/adder_coverage.sv` to ensure all scenarios are tested.

6. **Sequences and Tests**:
   - Sequences generate randomized transactions for the DUT, defined in `tb/tests/sequence_lib/adder_basic_seq.sv`.
   - Tests are defined in `tb/tests/adder_basic_test.sv` and aggregated in `tb/tests/adder_test_list.sv`.

7. **Top-Level Testbench**:
   - The top-level testbench `tb/adder_tb_top.sv` instantiates the DUT, connects it to the UVM environment, and starts the simulation.

8. **Automation Scripts**:
   - A native `CMakeLists.txt` is provided to automate out-of-source builds, Xilinx Vivado compilation, elaboration, and simulation processes.

### Source Organization
- **RTL Design**: Located in the `rtl/` directory.
- **Testbench Components**: Organized under `tb/` with subdirectories for agents, reference models, and top-level environment.
- **Source Lists**: Defined in `srclist/` for easy inclusion in simulation scripts.
- **Submodules**: Located in `src/` for easy integration with git submodules and dependencies.

This template is designed to streamline the verification process, promote reusability, and ensure thorough testing of the adder design.

## How to run

### Step 1: Set up the environment
Before running the simulation, ensure that the required tools (Vivado or Vitis) are sourced. This sets up the necessary environment variables for the tools to function correctly.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

### Step 2: Configure the Build
This project uses CMake to automate the Vivado simulation flow (`xvlog`, `xelab`, `xsim`), and provides a simple wrapper for ease of use.

#### Default / Common Configuration
To configure for compiling `adder_tb_top` and running `adder_basic_test`:
```bash
$ ./configure
```

#### Custom Parameter Configuration
```bash
$ ./configure --top <top_name> --test <test_name>
```

### Step 3: Run the simulation
After configuring, you can invoke the simulation via the standard `make` wrapper in the root directory:

#### Run all tests (Batch mode)
To run all tests silently using the `-R` argument (default behavior when configured):
```bash
$ make sim
```

#### Open the GUI (and waveform structure)
To quickly open the `xsim` GUI loaded with your `.wcfg` waveform setup:
```bash
$ make gui
```

### Step 4: Clean Build
To clean the entire build cache (equivalent to standard `--clean`):
```bash
$ make clean
```

### Summary of Configure Arguments
| Variable | Default Value | Description |
|---|---|---|
| `--top` | `adder_tb_top` | Specifies the top-level testbench module to load in elaboration. |
| `--test` | `adder_basic_test` | The UVM test name passed directly to `+UVM_TESTNAME` in `xsim`. |
| `--vivado` | `--R` | Passes arbitrary flags natively to the simulation engine. |


## Important Information

1. **Tool Versions**:
   - Ensure you are using Vivado or Vitis version 2024.1 or later for compatibility with the scripts and UVM libraries.

2. **Directory Structure**:
   - Maintain the directory structure as provided in the repository to ensure the scripts and source lists function correctly.

3. **Debugging Tips**:
   - Use the `--vivado "--g"` option to open the GUI for debugging.
   - Check the `build/` directory for logs and intermediate files if issues arise during simulation.

4. **Extending the Template**:
   - To add new tests, create sequences in `tb/tests/sequence_lib/` and include them in `tb/tests/adder_test_list.sv`.
   - For additional coverage, extend the coverage model in `tb/env/top/adder_coverage.sv`.

5. **Support**:
   - For questions or issues, contact the maintainer at `nelsonafn@gmail.com`.

6. **License**:
   - This project is distributed under the BSD license. Refer to the `LICENSE` file for details.

This section provides essential details to ensure smooth usage and extension of the verification template.