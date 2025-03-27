## How to run
Go inside the `build` directory and source Vivado or Vitis:
```bash
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

Run the xrun script:
```bash
$ ../bin/xrun.sh ../bin/xrun.sh  -top adder_tb_top  -vivado "--R"
# or
$ ../bin/xrun.sh ../bin/xrun.sh  -top adder_tb_top --c  -vivado "--g"
```

To load a waveform structure for vivado and clean
```bash
$ ../bin/xrun.sh  ../bin/xrun.sh  -top adder_tb_top --c  -vivado "--g -view adder_tb_top_sim.wcfg"
```

To run a specific test
```bash
$ ../bin/xrun.sh  ../bin/xrun.sh  -top adder_tb_top --name_of_test adder_basic_test --c  -v "--g -view adder_tb_top_sim.wcfg"
```


# Usage
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

