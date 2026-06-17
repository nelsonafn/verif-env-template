//------------------------------------------------------------------------------
// Passive test for adder
//------------------------------------------------------------------------------
// This UVM test sets up the environment in passive mode.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : June 2026
//------------------------------------------------------------------------------

`ifndef ADDER_PASSIVE_TEST 
`define ADDER_PASSIVE_TEST

class adder_passive_test extends uvm_test;
 
  /*
   * Declare component utilities for the test-case
   */
  `uvm_component_utils(adder_passive_test)
 
  adder_environment env;
 
  /*
   * Constructor: new
   */
  function new(string name = "adder_passive_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new
 
  /*
   * Build phase: Set agent to UVM_PASSIVE and instantiate environment
   */
  virtual function void build_phase(uvm_phase phase);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "env.adder_agent", "is_active", UVM_PASSIVE);
    super.build_phase(phase);
    env = adder_environment::type_id::create("env", this);
  endfunction : build_phase
 
  /*
   * Run phase: Simply run for some time in passive mode
   */
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    #100ns;
    phase.drop_objection(this);
  endtask : run_phase
 
endclass : adder_passive_test

`endif
