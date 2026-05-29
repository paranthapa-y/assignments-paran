//------------------------------------------------------------------------------
// File name   : yapp_tx_driver.sv
// Description : Transmit driver for YAPP protocol
//------------------------------------------------------------------------------

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_tx_driver extends uvm_driver #(yapp_packet);

  // Register with factory
  `uvm_component_utils(yapp_tx_driver)

  // Constructor
  function new(string name = "yapp_tx_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  //Start of simulation Phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "In driver.........", UVM_HIGH)
  endfunction : start_of_simulation_phase

  // UVM run_phase
  task run_phase(uvm_phase phase);
    yapp_packet pkt;

    forever begin
      // Get next item from sequencer
      seq_item_port.get_next_item(pkt);

      // Send to DUT (currently just prints)
      send_to_dut(pkt);

      // Indicate transaction is complete
      seq_item_port.item_done();
    end
  endtask : run_phase

  // Send packet to DUT (placeholder implementation)
  task send_to_dut(yapp_packet pkt);
    `uvm_info(get_type_name(), $sformatf("Packet is \n%s", pkt.sprint()), UVM_LOW)
    // TODO: Drive packet fields to DUT interface signals
  endtask : send_to_dut

endclass : yapp_tx_driver

