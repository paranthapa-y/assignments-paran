import uvm_pkg::*;
`include "uvm_macros.svh"

class yapp_tx_agent extends uvm_agent;
  `uvm_component_param_utils(yapp_tx_agent);
  yapp_tx_monitor monitor;
  yapp_tx_driver driver;
  yapp_tx_sequencer sequencer;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);  // Call super.build_phase(phase) first [cite: 302]
    monitor = yapp_tx_monitor::type_id::create("monitor", this);
    if (is_active == UVM_ACTIVE) begin
      driver = yapp_tx_driver::type_id::create("driver", this);
      sequencer = yapp_tx_sequencer::type_id::create("sequencer", this);
    end
  endfunction
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "Start of simulation phase", UVM_HIGH);
  endfunction
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction
endclass
