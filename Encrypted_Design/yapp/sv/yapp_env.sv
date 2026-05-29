import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_env extends uvm_env;
  `uvm_component_param_utils(yapp_env);
  yapp_tx_agent agent;

  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    //yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    super.build_phase(phase);  // Call super.build_phase(phase) first [cite: 302]
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);

    `uvm_info(get_type_name(), "Start of simulation phase", UVM_HIGH);
  endfunction
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("its now in environment  "), UVM_LOW)
  endtask

endclass
