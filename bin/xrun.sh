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
    exit 0
}

# Check if help is requested
check_help() {
    echo "Usage: xrun.sh [options]"
    echo ""
    echo "Options:"
    echo "  -top=<top_name>       Specify the top module name"
    echo "  -test=<test_name>     Specify the test name (default: adder_basic_test)"
    echo "  --t <top_name>        Specify the top module name (short option)"
    echo "  --h, -help            Display this help message"
    echo ""
    echo "Use --R to run all, --g to gui, and -view top_sim.wcfg to load waveforms"
    exit 0
}


# Display usage information
display_usage() {
    echo "Use --R to run all, --g to gui, and -view top_sim.wcfg to load waveforms"
}

# Display error message and exit
error_exit() {
    echo -e "${red}ERROR: $1${clear}"
    exit 1
}


# Parse parameters using getopts
parse_params() {
    TEST_NAME="adder_basic_test"  # Set default value for TEST_NAME
    while getopts ":t:-:" opt; do
        case "$opt" in
            -)
                IFS='=' read -r key value <<< "${OPTARG}"
                case "$key" in
                    top)
                        TOP_NAME=$value
                        # Remove parsed options from $@
                        shift $((OPTIND - 1))
                        ;;
                    test)
                        TEST_NAME=$value
                        # Remove parsed options from $@
                        shift $((OPTIND - 1))
                        ;;
                    clean)
                        check_clean
                        ;;
                    help)
                        check_help
                        ;;
                    *)
                        echo "INFO: Parameter --${OPTARG} is being passed direct to Vivado"
                        ;;
                esac
                ;;
            t)
                TOP_NAME=$OPTARG
                # Remove parsed options from $@
                shift $((OPTIND - 1))
                ;;
            h)
                check_help
                ;;
            c)
                check_clean
                ;;
            \?)
                echo "INFO: Parameter -${OPTARG} is being passed direct to Vivado"
                ;;
            :)
                error_exit "Option -$OPTARG requires an argument"
                ;;
        esac
    done
}

# Main script execution
main() {
    # Set current directory
    CURRENT_DIR=$(dirname "$0")
    
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
    xsim top_sim ${@:${OPTIND}} --testplusarg UVM_TESTNAME=${TEST_NAME}
}

main "$@"
