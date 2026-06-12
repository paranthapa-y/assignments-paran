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

  
  function void start_of_simulation_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Inside start_of_simulation_phase : %s", get_full_name()),UVM_HIGH)
  endfunction
  
  // Constructor
  function new(string name = "yapp_tx_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
endclass : yapp_tx_sequencer

