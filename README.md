# riscv-small
Five stage RISC-V core for embedded application.

## Implementation Status

- [x] Conception
- [x] Microarchitecture
- [x] RTL Design
- [ ] TB environment
- [ ] Testcases
- [ ] Functional Verification
- [ ] RTL signoff 
      
# How to run
Go inside build and do Vivado or Vits source 
```
$ source /opt/Xilinx/Vitis/2024.1/settings64.sh 
or
$ source /opt/Xilinx/Vivado/2024.1/.settings64-Vivado.sh 
```

Run the xrun script
```
$ ../bin/xrun.sh -g
```
Or
```
$ ../bin/xrun.sh 
```
You need before [install Toolchain for cross-compiler](#install-toolchain-for-cross-compiler) and [install/clone RISC-V tests](#install-or-clone-risc-v-tests) to support compiling the tests.
## Install Toolchain for cross-compiler
To run the tests install riscv-gnu-toolchain

Install dependencies 
```
$ sudo apt update 
$ sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev libusb-1.0-0-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev device-tree-compiler pkg-config libexpat-dev 
```
 

Install the toolchain (Compilers) (https://github.com/riscv-collab/riscv-gnu-toolchain) 
```
$ clone git@github.com:riscv-collab/riscv-gnu-toolchain.git  
$ export RISCV=/opt/riscv/toolchain 
$ cd riscv-gnu-toolchain 
$ ./configure --prefix=${RISCV} --enable-multilib 
```
 

Install (Use "sudo" if installation path ${RISCV} is protected) 
```
$ sudo make -j20  
```
 
Add source (It can be added into your ~/.bashrc) 
```
$ export PATH=${PATH:+${PATH}:}${RISCV}/bin 
```
 

## Install or clone RISC-V tests
Install riscv-tools (Simulator and Tests) 

Make sure you have add source (It can be added into your ~/.bashrc) 
```
$ export PATH=${PATH:+${PATH}:}${RISCV}/bin 
```
 

Clone repo 
```
$ git clone git@github.com:riscv-software-src/riscv-tests.git 
$ cd riscv-tests/ 
$ git submodule update --init –recursive 
$ autoupdate 
$ autoconf 
$ ./configure --prefix=$RISCV/target 
$ make -j24 -p isa 
```
 

Do not forget export tests path 
```
$ export RISCV_TESTS=/path/to/riscv-tests/ 
```