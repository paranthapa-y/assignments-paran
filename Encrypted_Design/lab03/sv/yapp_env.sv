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
    agent = new("agent", this);
  endfunction : build_phase

  //Start of simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "In environment.........", UVM_HIGH)
  endfunction : start_of_simulation_phase
endclass : yapp_env

