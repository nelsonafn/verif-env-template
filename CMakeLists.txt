cmake_minimum_required(VERSION 3.10)
project(AdderTemplate NONE)

# Options/Variables
set(TOP_NAME "adder_tb_top" CACHE STRING "Specify the top module name")
set(TEST_NAME "adder_basic_test" CACHE STRING "Specify the test name")
set(VIVADO_PARMS "--R" CACHE STRING "Pass extra Vivado parameters for xsim (e.g. --R)")

# Xilinx environment validation
if(NOT DEFINED ENV{XILINX_VIVADO})
    message(WARNING "XILINX_VIVADO environment variable is not set. Ensure you have sourced settings64.sh!")
endif()

# Convert VIVADO_PARMS so that multiple spaces/args aren't grouped as a single string
separate_arguments(VIVADO_PARMS_LIST UNIX_COMMAND "${VIVADO_PARMS}")

message(STATUS "--------------------------------------------------")
message(STATUS "  Simulation Configuration:")
message(STATUS "  - Top Module     : ${TOP_NAME}")
message(STATUS "  - Test Name      : ${TEST_NAME}")
message(STATUS "  - Vivado Params  : ${VIVADO_PARMS}")
message(STATUS "--------------------------------------------------")


# Global variables to track state across recursive calls
set(PROCESSED_SRCLISTS "" CACHE INTERNAL "")
set_property(GLOBAL PROPERTY ALL_COMPILE_TARGETS "")
set_property(GLOBAL PROPERTY ALL_SIM_LIBS "")

# Function to parse a srclist and create an xvlog target for it
function(create_library_from_srclist SRCLIST_PATH TARGET_LIB)
    if("${SRCLIST_PATH}" IN_LIST PROCESSED_SRCLISTS)
        return()
    endif()
    set(PROCESSED_SRCLISTS "${PROCESSED_SRCLISTS};${SRCLIST_PATH}" CACHE INTERNAL "")

    # 1) Tell CMake to re-run configure if this srclist is modified
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${SRCLIST_PATH}")

    if(NOT EXISTS "${SRCLIST_PATH}")
        message(FATAL_ERROR "Source list not found: ${SRCLIST_PATH}")
    endif()

    file(STRINGS "${SRCLIST_PATH}" LINES)
    
    set(SV_FILES "")
    set(TARGET_DEPENDENCIES "")

    foreach(LINE IN LISTS LINES)
        # Remove comments and whitespace
        string(REGEX REPLACE "#.*$" "" LINE "${LINE}")
        string(STRIP "${LINE}" LINE)
        if(LINE STREQUAL "")
            continue()
        endif()

        if(LINE MATCHES "\\.srclist$")
            # If line is another srclist, compute its lib name and recurse
            get_filename_component(SUBLIST_BASE_NAME "${LINE}" NAME_WE)
            set(SUBLIST_LIB "${SUBLIST_BASE_NAME}_lib")
            
            # Recursively create library for the sub-srclist
            create_library_from_srclist("${CMAKE_SOURCE_DIR}/${LINE}" "${SUBLIST_LIB}")
            
            list(APPEND TARGET_DEPENDENCIES "compile_${SUBLIST_LIB}")
            set_property(GLOBAL APPEND PROPERTY ALL_SIM_LIBS "${SUBLIST_LIB}")
        else()
            # It's a systemverilog file
            list(APPEND SV_FILES "${CMAKE_SOURCE_DIR}/${LINE}")
        endif()
    endforeach()

    if(SV_FILES)
        set(TARGET_NAME "compile_${TARGET_LIB}")
        set(STAMP_FILE "${CMAKE_BINARY_DIR}/${TARGET_LIB}.stamp")
        
        # Broaden dependencies to include all .sv and .svh files in the same directories
        # This implicitly catches all `include files that aren't explicitly inside the .srclist
        set(ALL_DEPENDS ${SV_FILES})
        foreach(SV_FILE IN LISTS SV_FILES)
            get_filename_component(SV_DIR "${SV_FILE}" DIRECTORY)
            file(GLOB DIR_SVS "${SV_DIR}/*.sv" "${SV_DIR}/*.svh")
            list(APPEND ALL_DEPENDS ${DIR_SVS})
        endforeach()
        if(ALL_DEPENDS)
            list(REMOVE_DUPLICATES ALL_DEPENDS)
        endif()
        
        # In EDA flows, using a stamp file with an add_custom_command ensures that the
        # compilation only runs when the `.sv` dependencies are newer than the stamp file.
        add_custom_command(
            OUTPUT "${STAMP_FILE}"
            COMMAND xvlog -work ${TARGET_LIB} -L uvm -sv "$ENV{XILINX_VIVADO}/data/system_verilog/uvm_1.2/uvm_macros.svh" ${SV_FILES}
            COMMAND touch "${STAMP_FILE}"
            DEPENDS ${ALL_DEPENDS}
            WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
            COMMENT "Compiling ${TARGET_LIB} from lib list..."
            VERBATIM
        )
        
        # The custom target just drives the creation of the stamp file
        add_custom_target(${TARGET_NAME} DEPENDS "${STAMP_FILE}")
        
        if(TARGET_DEPENDENCIES)
            add_dependencies(${TARGET_NAME} ${TARGET_DEPENDENCIES})
        endif()
        
        # Register this compilation target globally
        set_property(GLOBAL APPEND PROPERTY ALL_COMPILE_TARGETS "${TARGET_NAME}")
    endif()
endfunction()

# 1. Start parsing from the TOP_NAME.srclist (which goes into the 'work' library)
# Reset cached list for fresh configures
set(PROCESSED_SRCLISTS "" CACHE INTERNAL "")
create_library_from_srclist("${CMAKE_SOURCE_DIR}/srclist/${TOP_NAME}.srclist" "work")

# 2. Get the collected global targets and libraries
get_property(COMPILE_TARGETS GLOBAL PROPERTY ALL_COMPILE_TARGETS)
get_property(SIM_LIBS GLOBAL PROPERTY ALL_SIM_LIBS)

# Format libraries to link to Xelab
set(XELAB_LIBS "")
if(SIM_LIBS)
    list(REMOVE_DUPLICATES SIM_LIBS)
    foreach(LIB_NAME IN LISTS SIM_LIBS)
        list(APPEND XELAB_LIBS "-L" "${LIB_NAME}")
    endforeach()
endif()

# Global compile target depends on all the sub-targets found
if(COMPILE_TARGETS)
    add_custom_target(compile DEPENDS ${COMPILE_TARGETS})
else()
    add_custom_target(compile COMMENT "No sources to compile.")
endif()

# 3. Elaborate target
add_custom_target(elaborate
    COMMAND xelab ${TOP_NAME} -L uvm ${XELAB_LIBS} --timescale 1ns/1ps -s top_sim --debug typical --mt 16 --incr
    DEPENDS compile
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Elaborating design..."
    VERBATIM
)

set(DOLLAR "$")

# 4. Sim target
add_custom_target(sim
    COMMAND bash -c "xsim top_sim ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${DOLLAR}${DOLLAR}{TEST_NAME:-${TEST_NAME}}"
    DEPENDS elaborate
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running standard simulation..."
    USES_TERMINAL
)

# 5. GUI target
add_custom_target(gui
    COMMAND bash -c "xsim top_sim --gui --view ${TOP_NAME}_sim.wcfg --testplusarg UVM_TESTNAME=${DOLLAR}${DOLLAR}{TEST_NAME:-${TEST_NAME}}"
    DEPENDS elaborate
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Opening simulation in Vivado GUI..."
    USES_TERMINAL
)

# Clean extra Vivado generated files
set_directory_properties(PROPERTIES ADDITIONAL_CLEAN_FILES 
    "xsim.dir;xvlog.log;xvlog.pb;xelab.log;xelab.pb;xsim.log;xsim.jou;webtalk_pn.xml;webtalk.jou;xsim_webtalk.tcl;xsim.covdb;top_sim.wdb;tr_db.log;*.stamp"
)

# 6. Dynamically Generate Native Targets for All Tests
file(GLOB TEST_FILES "${CMAKE_SOURCE_DIR}/tb/tests/*_test.sv")
foreach(TEST_FILE IN LISTS TEST_FILES)
    get_filename_component(INDIVIDUAL_TEST_NAME "${TEST_FILE}" NAME_WE)
    
    # Create a wrapper target for exactly this test name (Standard mode)
    add_custom_target(${INDIVIDUAL_TEST_NAME}
        COMMAND bash -c "xsim top_sim ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${INDIVIDUAL_TEST_NAME}"
        DEPENDS elaborate
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running simulation: ${INDIVIDUAL_TEST_NAME}..."
        USES_TERMINAL
    )
    
    # Explicit SIM target (so user can type `make sim_adder_corner_test`)
    add_custom_target(sim_${INDIVIDUAL_TEST_NAME}
        COMMAND bash -c "xsim top_sim ${VIVADO_PARMS_LIST} --testplusarg UVM_TESTNAME=${INDIVIDUAL_TEST_NAME}"
        DEPENDS elaborate
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Running simulation: ${INDIVIDUAL_TEST_NAME}..."
        USES_TERMINAL
    )
    
    # Explicit GUI target (so user can type `make gui_adder_corner_test`)
    add_custom_target(gui_${INDIVIDUAL_TEST_NAME}
        COMMAND bash -c "xsim top_sim --gui --view ${TOP_NAME}_sim.wcfg --testplusarg UVM_TESTNAME=${INDIVIDUAL_TEST_NAME}"
        DEPENDS elaborate
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Opening GUI simulation: ${INDIVIDUAL_TEST_NAME}..."
        USES_TERMINAL
    )
endforeach()
