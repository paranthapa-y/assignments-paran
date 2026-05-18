//------------------------------------------------------------------------------
// File name   : yapp_env.sv
// Description : Environment containing the YAPP TX agent
//------------------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_env extends uvm_env;

  // Register with the factory
  `uvm_component_utils(yapp_env)

  // Handle to the TX agent
  yapp_tx_agent agent;

  // Constructor
  function new(string name = "yapp_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase - construct agent
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction : build_phase

  // Run phase - print the env
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Printing environment...", UVM_LOW)
    this.print();
  endtask : run_phase

endclass : yapp_env

