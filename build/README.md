# How to run
Go inside the `build` directory and source Vivado or Vitis:
```
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
# or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

Run the xrun script:
```
$ ../bin/xrun.sh --top=adder_tb_top  --R
# or
$ ../bin/xrun.sh --top=adder_tb_top --g
```

To load a waveform structure for vivado
```
$ ../bin/xrun.sh --top=adder_tb_top -view adder_tb_top_sim.wcfg --g
```

To run a specific test
```
$ ../bin/xrun.sh --top=adder_tb_top --test=adder_basic_test -view adder_tb_top_sim.wcfg --g
```


