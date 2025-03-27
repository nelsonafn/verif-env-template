#!/bin/bash

# Color variables
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
clear='\033[0m'  # Clear the color after that




# Check if clean is requested
check_clean() {
    # Set current directory
    CURRENT_DIR=$(dirname "$0")
    find ${CURRENT_DIR}/../build -type f ! -name '*.md' ! -name '*.wcfg' -exec rm -f {} +
    echo "Cleaned all files in build directory except *.md and *.wcfg"
}

# Check if help is requested
check_help() {
    echo "Usage: xrun.sh [options]"
    echo ""
    echo "Options:"
    echo "  --t|-top <top_name>              Specify the top module name"
    echo "  --N|-name_of_test <test_name>    Specify the test name (default: adder_basic_test)"
    echo "  --h|help                         Display this help message"
    echo "  --c|-clean                       Clean build"
    echo "  --v|-vivado <\"--vivado_params\">  Pass Vivado parameters"
    echo ""
    echo "Use -v \"--R\" to run all, --v \"--g\" to gui, and --v \"--g -view top_sim.wcfg\" to load waveforms"
    exit 0
}


# Display usage information
display_usage() {
    echo "../bin/xrun.sh  -t adder_tb_top --n adder_basic_test --c -v \"--g -view adder_tb_top_sim.wcfg\" "
}

# Display error message and exit
error_exit() {
    echo -e "${red}ERROR: $1${clear}"
    exit 1
}


# Parse parameters using getopts
parse_params() {
    # Set default value for TEST_NAME
    TEST_NAME="adder_basic_test"  
    # Set current directory
    CURRENT_DIR=$(dirname "$0")   
    options=$(getopt -a --longoptions help,clean,top:,name_of_test:,vivado: -n "xrun" -- ${0} "${@}")
    eval set -- "$options"
    while true; do
        echo "$1"
        case "$1" in
            --top)
                shift
                TOP_NAME="$1"
                echo "$1"
                ;;
            --name_of_test)
                shift
                TEST_NAME="$1"
                echo "$1"
                ;;
            --clean)
                check_clean
                ;;
            --help)
                check_help
                ;;
            --vivado)
                shift
                VIVADO_PARMS="$1"
                echo "INFO: Parameters ${1} is being passed direct to Vivado"
                ;;
            --)
                shift
                break
                ;;
            *)
                error_exit "Option '${1}' requires an argument"
                ;;
        esac
        shift
    done
}

# Main script execution
main() {
    parse_params "$@"
    display_usage

    # Check if the first parameter is provided
    if [ -z "$1" ]; then
        error_exit "No testbench name provided!"
    fi

    # Check if TOP_NAME is set
    if [ -z "$TOP_NAME" ]; then
        error_exit "No top name provided!"
    fi

    echo ${CURRENT_DIR}
    # Generate source list path
    list=$("${CURRENT_DIR}/srclist2path.sh" "${CURRENT_DIR}/../srclist/${TOP_NAME}.srclist")
    echo "${list}"

    # Run simulation
    xvlog -L uvm -sv "${XILINX_VIVADO}/data/system_verilog/uvm_1.2/uvm_macros.svh" ${list}
    xelab ${TOP_NAME} --timescale 1ns/1ps -L uvm -s top_sim --debug typical --mt 16 --incr
    xsim top_sim ${VIVADO_PARMS} --testplusarg UVM_TESTNAME=${TEST_NAME}
}

main "$@"
