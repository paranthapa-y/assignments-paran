//------------------------------------------------------------------------------
// File name   : yapp_tx_sequencer.sv
// Description : Transmit sequencer for YAPP protocol
//------------------------------------------------------------------------------

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);

  // Register with factory
  `uvm_component_utils(yapp_tx_sequencer)

  // Constructor
  function new(string name = "yapp_tx_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //Start of simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "In sequencer.........", UVM_HIGH)
  endfunction : start_of_simulation_phase

endclass : yapp_tx_sequencer

