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
- **Source Lists**: Defined in `srclist/` for easy inclusion in simulation scripts. Supports standard file paths, nested `.srclist` files (which create separate compilation libraries), and `+incdir+path/to/dir` directives for global UVM macro includes.
- **Submodules**: Located in `src/` for easy integration with git submodules and dependencies.

This template is designed to streamline the verification process, promote reusability, and ensure thorough testing of the adder design.

## How to run

### Step 1: Set up the environment
Before running the simulation, you must source the required Xilinx tools (Vivado or Vitis). This injects the EDA toolpaths into your current terminal instance.

```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/2025.2/Vivado/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
# or
$ source /opt/Xilinx/2025.2/Vivado/.settings64-Vivado.sh 
```

### Step 2: Configure the Build
This project uses CMake to automate the Vivado simulation flow (`xvlog`, `xelab`, `xsim`). You generate an isolated `build/` directory using the provided wrapper script.

```bash
# Sets up the default simulation environment
$ ./configure
```
Under the hood, this parses your SV files, generates dependency trees via stamp files (so they only recompile when modified), and creates dynamically bound Make targets.

#### Custom Defaults Configuration
You can bake default parameters directly into the build system at configuration time so you don't need to specify them on every make command:
```bash
# Bake in a specific test name, seed, and top module as defaults:
$ ./configure --top adder_tb_top --test adder_basic_test --seed 3
```

### Step 3: Run the simulation
Because of the smart wrapper generated in the project root, you have several ways to trigger the simulations cleanly!

#### Option A: Running from the Project Root (Smart Proxy)
You do not need to `cd build/`. You can immediately execute targets from the root, and it will intentionally forward your requests into CMake. It allows you to inject individual test names via spaces.

- **`make compile`**: Explicitly compiles the SV source code (`xvlog`) without running simulation.
- **`make elaborate`**: Elaborates the compiled design into a simulation snapshot (`xelab`) without running simulation.
- **`make sim`**: Runs the default test configuration (e.g. `adder_basic_test`) silently in terminal.
- **`make gui`**: Opens Vivado XSim GUI using your defined waveform layout.
- **`make sim_<test_name>`**: Injects the test dynamically (e.g. `make sim_adder_corner_test`) replacing defaults.
- **`make gui_<test_name>`**: Injects the test dynamically into the GUI directly (e.g. `make gui_adder_corner_test`).

##### Passing Dynamic Simulation Overrides (TEST_NAME, SEED, SIM_ARGS)
Instead of re-configuring the project, you can dynamically override UVM settings, the randomization seed, or other simulator flags directly on the `make` command line:

- **Pass a specific UVM test name, disable print verbosity, and set a specific seed**:
  ```bash
  $ make sim TEST_NAME="adder_basic_test" SIM_ARGS="--testplusarg UVM_VERBOSITY=UVM_NONE" SEED="3"
  ```
  *(This runs the `adder_basic_test` test case, disables UVM verbosity output via `SIM_ARGS`, and sets the SV randomization seed to `3` dynamically.)*

- **Pass custom plusargs and a specific seed**:
  ```bash
  $ make sim TEST_NAME="adder_basic_test" SIM_ARGS="--testplusarg UVM_VERBOSITY=UVM_NONE" SEED="3"
  ```

- **Change UVM Verbosity only**:
  ```bash
  $ make sim SIM_ARGS="--testplusarg UVM_VERBOSITY=UVM_HIGH"
  ```

- **Enable UVM Objection Tracing**:
  ```bash
  $ make sim SIM_ARGS="--testplusarg UVM_OBJECTION_TRACE"
  ```

- **Pass multiple custom plusargs dynamically**:
  ```bash
  $ make sim_adder_corner_test SIM_ARGS="--testplusarg some_arg=1 --testplusarg another_arg=0"
  ```

#### Option B: Running from inside the `build/` directory
When inside the strictly generated CMake target directory, you can utilize the auto-generated target configurations. (Note: spaces denote multiple targets inside native Make!)

```bash
$ cd build/
```
- **`make sim`**: Runs the default test configured.
- **`make <test_name>`**: Runs a specific test dynamically discovered natively (e.g. `make adder_corner_test`).
- **`make sim_<test_name>`**: Explicitly runs the auto-generated test strictly in SIM terminal mode.
- **`make gui_<test_name>`**: Explicitly runs the auto-generated test natively triggering the Vivado GUI.

#### Option C: Simulation Wrapper Script (`xrun.sh`)
For convenience, we provide a wrapper script at `scripts/xrun.sh` that automatically runs the configuration (`./configure`) and simulation (`make`) stages in one step. It supports the following options:

| Option | Description |
|---|---|
| `--top <top_name>` | Specify the top-level testbench module (default: `adder_tb_top`). |
| `--name_of_test <test_name>` | Specify the UVM test name to execute (default: `adder_basic_test`). |
| `--seed <value>` | Specify the SystemVerilog randomization seed (default: `1`). |
| `--vivado "<params>"` | Pass custom Vivado simulator arguments. E.g., `"--g"` activates GUI mode. |
| `--clean` | Perform a clean of the build directory before running the simulation. |
| `--help` | Display the help message detailing script usage. |

##### Examples of using `xrun.sh`:

- **Run the default simulation in CLI mode**:
  ```bash
  $ ./scripts/xrun.sh
  ```

- **Run a specific test case (e.g. `adder_corner_test`)**:
  ```bash
  $ ./scripts/xrun.sh --name_of_test adder_corner_test
  ```

- **Run a specific test case in the Vivado GUI**:
  ```bash
  $ ./scripts/xrun.sh --name_of_test adder_basic_test --vivado "--g"
  ```

- **Clean the build directory and run simulation**:
  ```bash
  $ ./scripts/xrun.sh --clean --name_of_test adder_basic_test
  ```

- **Run GUI mode with custom waveform config**:
  ```bash
  $ ./scripts/xrun.sh --vivado "--g -view scripts/adder_tb_top_sim.wcfg"
  ```

- **Run with a custom randomization seed (e.g. `42`)**:
  ```bash
  $ ./scripts/xrun.sh --seed 42
  ```

- **Run with a dynamically generated random seed**:
  ```bash
  $ ./scripts/xrun.sh --seed random
  ```

- **Pass `SIM_ARGS` through the wrapper script**:
  ```bash
  $ SIM_ARGS="+UVM_VERBOSITY=UVM_HIGH" ./scripts/xrun.sh --name_of_test adder_basic_test
  ```

### Step 4: Clean Build
To clean the entire build cache (safe compilation reset):
```bash
$ make clean
```

### Summary of Configure Arguments
| Variable | Default Value | Description |
|---|---|---|
| `--top` | `adder_tb_top` | Specifies the top-level testbench module to load in elaboration. |
| `--test` | `adder_basic_test` | The UVM test name passed directly to `+UVM_TESTNAME` in `xsim`. |
| `--seed` | `1` | The SystemVerilog randomization seed passed to `--sv_seed` in `xsim`. |
| `--vivado` | `--R` | Passes arbitrary flags natively to the simulation engine. (Setting `--g` turns on GUI mode) |


## Important Information

1. **Tool Versions**:
   - Ensure you are using Vivado or Vitis version 2024.1 or later for compatibility with the scripts and UVM libraries.

2. **Directory Structure**:
   - Maintain the directory structure as provided in the repository to ensure the scripts and source lists function correctly.

3. **Debugging Tips**:
   - Use the `--vivado "--g"` option to open the GUI for debugging.
   - Check the `build/` directory for logs and intermediate files if issues arise during simulation.

4. **Extending the Template**:
   - To add new tests, create sequences in `tb/tests/sequence_lib/` and include them in `tb/tests/adder_seq_list_pkg.sv` and `tb/tests/adder_test_list_pkg.sv`.
   - To add standalone shared components (like interfaces), map them to an `.srclist` module to build them as an independent library.
   - For additional coverage, extend the coverage model in `tb/env/top/adder_coverage.sv`.

5. **Support**:
   - For questions or issues, contact the maintainer at `nelsonafn@gmail.com`.

6. **License**:
   - This project is distributed under the BSD license. Refer to the `LICENSE` file for details.

This section provides essential details to ensure smooth usage and extension of the verification template.

## Install cmake
sudo apt install cmake
sudo apt install autoconf
