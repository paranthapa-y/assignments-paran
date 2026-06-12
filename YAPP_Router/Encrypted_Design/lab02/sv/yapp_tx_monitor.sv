//------------------------------------------------------------------------------
// File name   : yapp_tx_monitor.sv
// Description : Transmit monitor for YAPP protocol
//------------------------------------------------------------------------------

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_tx_monitor extends uvm_monitor;

  // Register with factory
  `uvm_component_utils(yapp_tx_monitor)

  // Constructor
  function new(string name = "yapp_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // UVM run_phase
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the YAPP TX Monitor", UVM_LOW)
  endtask : run_phase

endclass : yapp_tx_monitor

