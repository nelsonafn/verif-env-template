## How to run

### Step 1: Set up the environment
Before running the simulation, ensure that the required tools (Vivado or Vitis) are sourced. This sets up the necessary environment variables for the tools to function correctly.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

### Step 2: Configure the CMake Build
This project uses CMake to automate the Vivado simulation flow (`xvlog`, `xelab`, `xsim`). You configure the parameters once and let CMake handle out-of-source directories.

```bash
# General Syntax
cmake -S . -B build -DTOP_NAME=<top_name> -DTEST_NAME=<test_name>
```

#### Default / Common Configuration
To configure for compiling `adder_tb_top` and running `adder_basic_test`:
```bash
$ cmake -S . -B build -DTOP_NAME=adder_tb_top -DTEST_NAME=adder_basic_test
```

### Step 3: Run the simulation
After configuring, you can invoke the simulation natively through the CMake build system:

#### Run all tests (Batch mode)
To run all tests silently using the `-R` argument (default behavior when configured):
```bash
$ cmake --build build --target sim
```

#### Open the GUI (and waveform structure)
To quickly open the `xsim` GUI loaded with your `.wcfg` waveform setup:
```bash
$ cmake --build build --target gui
```

### Step 4: Clean Build
To clean the entire build cache (equivalent to `--clean`), simply remove the build directory and reconfigure:
```bash
$ rm -rf build/
$ cmake -S . -B build -DTOP_NAME=adder_tb_top
```

### Summary of CMake Arguments
| Variable | Default Value | Description |
|---|---|---|
| `TOP_NAME` | `adder_tb_top` | Specifies the top-level testbench module to load in elaboration. |
| `TEST_NAME` | `adder_basic_test` | The UVM test name passed directly to `+UVM_TESTNAME` in `xsim`. |
| `VIVADO_PARMS` | `--R` | Passes arbitrary flags natively to the simulation engine. |

## Important Information

1. **Tool Versions**:
   - Ensure you are using Vivado or Vitis version 2024.1 or later for compatibility with the scripts and UVM libraries.

2. **Directory Structure**:
   - Maintain the directory structure as provided in the repository to ensure the scripts and source lists function correctly.

3. **Debugging Tips**:
   - Use the `--vivado "--g"` option to open the GUI for debugging.
   - Check the `build/` directory for logs and intermediate files if issues arise during simulation.

4. **Support**:
   - For questions or issues, contact the maintainer at `nelsonafn@gmail.com`.

