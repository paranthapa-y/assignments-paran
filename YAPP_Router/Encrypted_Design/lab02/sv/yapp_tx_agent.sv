//------------------------------------------------------------------------------
// File name   : yapp_tx_agent.sv
// Description : Transmit agent for YAPP protocol
//------------------------------------------------------------------------------

import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_tx_agent extends uvm_agent;

  // Register with factory
  `uvm_component_utils(yapp_tx_agent)

  // Constructor
  function new(string name = "yapp_tx_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Components in the agent
  yapp_tx_driver          driver;
  yapp_tx_monitor         monitor;
  yapp_tx_sequencer       sequencer;

  // Active/Passive mode (default ACTIVE)
  uvm_active_passive_enum is_active  = UVM_ACTIVE;

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is always built
    monitor = yapp_tx_monitor::type_id::create("monitor", this);

    if (is_active == UVM_ACTIVE) begin
      driver    = yapp_tx_driver::type_id::create("driver", this);
      sequencer = yapp_tx_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : yapp_tx_agent

