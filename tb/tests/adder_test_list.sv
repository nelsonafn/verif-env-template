//------------------------------------------------------------------------------
// Package for aggregating adder tests
//------------------------------------------------------------------------------
// This package includes all the tests for the adder simulation.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_TEST_LIST 
`define ADDER_TEST_LIST

package adder_test_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import adder_env_pkg::*;
  import adder_seq_list::*;

  /*
   * Including basic test definition
   */
  `include "adder_basic_test.sv"

endpackage 

`endif





