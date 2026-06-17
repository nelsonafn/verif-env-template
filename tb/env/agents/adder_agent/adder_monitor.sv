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
   * Queue representing the active pipeline stages in the DUT.
   * Since the DUT has registered outputs, there is a 1-cycle pipeline latency.
   * When inputs are driven, we capture them in a transaction object and push it
   * to this queue. On the next cycle, we pop the transaction from the queue,
   * capture its registered outputs, and publish it.
   */
  adder_transaction pipeline_queue[$];

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

    forever begin
      // Create a transaction to capture the current inputs
      act_trans = adder_transaction::type_id::create("act_trans");
      act_trans.x   = vif.rc_cb.x;
      act_trans.y   = vif.rc_cb.y;
      act_trans.cin = vif.rc_cb.cin;
      
      // Push this input-only transaction into our pipeline queue
      pipeline_queue.push_back(act_trans);

      // Wait exactly 1 clock cycle for the DUT to register the outputs
      @(vif.rc_cb);

      // Pop the oldest transaction (which corresponds to the inputs from 1 cycle ago)
      // and sample the corresponding outputs from the current cycle.
      if (pipeline_queue.size() > 0) begin
        adder_transaction completed_trans = pipeline_queue.pop_front();
        completed_trans.sum  = vif.rc_cb.sum;
        completed_trans.cout = vif.rc_cb.cout;

        `uvm_info(get_full_name(),$sformatf("TRANSACTION FROM MONITOR"),UVM_LOW);
        completed_trans.print();

        $cast(rm_trans, completed_trans.clone());
        mon2sb_port.write(completed_trans);
        // Clean outputs and send it to reference model
        rm_trans.sum = '0;
        rm_trans.cout = '0;
        rm_trans.carry_out = '0;
        mon2rm_port.write(rm_trans);
      end
    end
  endtask : run_phase

endclass : adder_monitor

`endif
