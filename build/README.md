## How to run

### Step 1: Set up the environment
Before running the simulation, ensure that the required tools (Vivado or Vitis) are sourced. This sets up the necessary environment variables for the tools to function correctly.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

### Step 2: Run the simulation script
The `xrun.sh` script automates the process of compiling, elaborating, and simulating the design. Below are the common usage scenarios:

#### Run all tests
To run all tests in batch mode:
```bash
$ ../bin/xrun.sh -top adder_tb_top -vivado "--R"
```
- `-top adder_tb_top`: Specifies the top-level testbench module.
- `--vivado "--R"`: Runs the simulation in batch mode.

#### Open the GUI
To open the Vivado GUI for debugging:
```bash
$ ../bin/xrun.sh -top adder_tb_top --c -vivado "--g"
```
- `--c`: Cleans the build directory before running.
- `--vivado "--g"`: Opens the simulation in GUI mode.

#### Load a waveform structure
To load a specific waveform structure for analysis:
```bash
$ ../bin/xrun.sh -top adder_tb_top --c -vivado "--g -view adder_tb_top_sim.wcfg"
```
- `--vivado "--g -view adder_tb_top_sim.wcfg"`: Opens the GUI and loads the specified waveform configuration file.

#### Run a specific test
To run a specific test case:
```bash
$ ../bin/xrun.sh -top adder_tb_top --name_of_test adder_basic_test --c -vivado "--g -view adder_tb_top_sim.wcfg"
```
- `--name_of_test adder_basic_test`: Specifies the test case to run (default is `adder_basic_test`).

### Step 3: Analyze results
- For batch mode, check the console output for pass/fail status and logs.
- For GUI mode, use the waveform viewer to debug and analyze signal activity.

### Notes
- The `--clean` option ensures a fresh build by removing intermediate files.
- The `--vivado` option allows passing additional parameters directly to Vivado for customization.
- **Important**: All scripts must be executed from the `build` folder to ensure correct relative paths are resolved.

## Usage
```
xrun.sh [options]

Options:
  --t|-top <top_name>              Specify the top module name
  --N|-name_of_test <test_name>    Specify the test name (default: adder_basic_test)
  --h|help                         Display this help message
  --c|-clean                       Clean build
  --v|-vivado <"--vivado_params">  Pass Vivado parameters

Use -v "--R" to run all, --v "--g" to gui, and --v "--g -view top_sim.wcfg" to load waveforms
```

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

