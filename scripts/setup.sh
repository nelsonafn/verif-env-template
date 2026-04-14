#!/bin/bash
# -----------------------------------------------------------------------------
# setup.sh
#
# This script is used to configure environment variables required for building
# and running the RISC-V small project. 
#
# IMPORTANT:
# Update the following environment variables according to your machine setup:
#   - TOOLCHAIN_PATH: Path to the RISC-V toolchain binaries.
#   - PROJECT_ROOT:   Root directory of the project.
#   - RISCV_TARGET:   Target architecture for the build (e.g., riscv32-unknown-elf).
#
# Make sure to source this script in your shell session:
#   source /path/to/setup.sh
# -----------------------------------------------------------------------------

# Source the Xilinx Vivado environment setup script
source /opt/Xilinx/2025.2/Vivado/.settings64-Vivado.sh
