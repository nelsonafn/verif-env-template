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

## How to run
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
$ ../bin/xrun.sh --top=adder_tb_top  --g
```


