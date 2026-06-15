//------------------------------------------------------------------------------
// Monitor module for adder agent
//------------------------------------------------------------------------------
// This module captures interface activity for the adder agent.
//
// Author: Nelson Alves nelsonafn@gmail.com
// Date  : October 2023
//------------------------------------------------------------------------------

`ifndef ADDER_MONITOR 
`define ADDER_MONITOR

class adder_monitor extends uvm_monitor;
 
  /*
   * Declaration of Virtual interface
   */
  virtual adder_interface vif;

  /*
   * Declaration of Analysis ports and exports 
   */
  uvm_analysis_port #(adder_transaction) mon2sb_port;
  uvm_analysis_port #(adder_transaction) mon2rm_port;

  /*
   * Declaration of transaction item 
   */
  adder_transaction act_trans;

  /*
   * Local history variables to store inputs from the previous cycle
   */
  logic [3:0] x_prev;
  logic [3:0] y_prev;
  logic cin_prev;

  /*
   * Declaration of component utils 
   */
  `uvm_component_utils(adder_monitor)

  /*
   * Constructor
   */
  function new (string name, uvm_component parent);
    super.new(name, parent);
    mon2sb_port = new("mon2sb_port", this);
    mon2rm_port = new("mon2rm_port", this);
  endfunction : new

  /*
   * Build phase: construct the components
   * This phase retrieves the virtual interface from the UVM configuration database.
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual adder_interface)::get(this, "", "intf", vif))
      `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase

  /*
   * Run phase: Extract the info from DUT via interface 
   * This phase continuously samples the transaction signals from the DUT.
   */
  virtual task run_phase(uvm_phase phase);
    adder_transaction rm_trans;
    wait(!vif.reset);
    
    // Wait for the first driver edge (posedge clk) and then the first sampling edge (negedge clk)
    @(posedge vif.clk);
    @(vif.rc_cb);
    x_prev = vif.rc_cb.x;
    y_prev = vif.rc_cb.y;
    cin_prev = vif.rc_cb.cin;

    forever begin
      // Wait exactly 1 clock cycle to get the outputs of the previous inputs,
      // and the inputs of the current transaction.
      @(vif.rc_cb);
      
      act_trans = adder_transaction::type_id::create("act_trans");
      act_trans.x = x_prev;
      act_trans.y = y_prev;
      act_trans.cin = cin_prev;
      act_trans.sum = vif.rc_cb.sum;
      act_trans.cout = vif.rc_cb.cout;
      `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"),UVM_LOW);
      act_trans.print();

      // Store current inputs for the next cycle
      x_prev = vif.rc_cb.x;
      y_prev = vif.rc_cb.y;
      cin_prev = vif.rc_cb.cin;

      $cast(rm_trans, act_trans.clone());
      mon2sb_port.write(act_trans);
      // Clean outputs and send it to reference model
      rm_trans.sum = '0;
      rm_trans.cout = '0;
      rm_trans.carry_out = '0;
      mon2rm_port.write(rm_trans);
    end
  endtask : run_phase

endclass : adder_monitor

`endif
