//------------------------------------------------------------------------------
// Package for listing adder sequences
//------------------------------------------------------------------------------
// This package includes the basic sequence for the adder testbench.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_SEQ_LIST 
`define ADDER_SEQ_LIST

package adder_seq_list;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import adder_agent_pkg::*;
  import adder_ref_model_pkg::*;
  import adder_env_pkg::*;

  /*
   * Including adder basic sequence 
   */
  `include "adder_basic_seq.sv"

endpackage

`endif
