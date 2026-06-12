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
  yapp_packet packet_collected;
  virtual yapp_if vif; 
  int num_pkt_col = 0;
  covergroup cg;
    len_cp : coverpoint packet_collected.length{
      bins MIN = {1};
      bins MAX = {63};
      bins BABY = {[2:10]};
      bins TEENY = {[11:40]};
      bins ROWNUP = {[41:62]};
    }
    addr_cp : coverpoint packet_collected.addr {
    bins a0 = {0};
    bins a1 = {1};
    bins a2 = {2};
    illegal_bins illegal = {3};
    }
    parity_cp : coverpoint packet_collected.parity_type {
    bins good = {GOOD_PARITY};
    bins bad  = {BAD_PARITY};
    }

    addr_parity_len_cp : cross len_cp, addr_cp, parity_cp;
  endgroup
  uvm_analysis_port #(yapp_packet) item_collected_port;

  // Constructor
  function new(string name = "yapp_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
    cg = new();
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!(uvm_config_db#(virtual yapp_if)::get(this,"","vif",vif)))
      `uvm_fatal("VIFE", "vif not set")
    item_collected_port = new("item_collected_port", this);
    
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    // `uvm_info(get_type_name(), $sformatf("Inside start_of_simulation_phase : %s", get_full_name()),UVM_HIGH)
  endfunction

  // UVM run_phase
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM)

    // Create collected packet instance
    packet_collected = yapp_packet::type_id::create("packet_collected", this);

    // Look for packets after reset
    @(negedge vif.reset)
    // `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
    forever 
      collect_packet();
  endtask : run_phase

  

  task collect_packet();
      //Monitor looks at the bus on posedge (Driver uses negedge)
      @(posedge vif.in_data_vld);

      @(posedge vif.clock iff (!vif.in_suspend))

      // Begin transaction recording
      void'(this.begin_tr(packet_collected, "Monitor_YAPP_Packet"));

      `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)
      // Collect Header {Length, Addr}
      { packet_collected.length, packet_collected.addr }  = vif.in_data;
      packet_collected.payload = new[packet_collected.length]; // Allocate the payload
      // Collect the Payload
      for (int i=0; i< packet_collected.length; i++) begin
         @(posedge vif.clock iff (!vif.in_suspend))
         packet_collected.payload[i] = vif.in_data;
      end

      // Collect Parity and Compute Parity Type
       @(posedge vif.clock iff !vif.in_suspend)
         packet_collected.parity = vif.in_data;
       packet_collected.parity_type = (packet_collected.parity == packet_collected.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
      // End transaction recording
      this.end_tr(packet_collected);
      `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", packet_collected.sprint()), UVM_LOW)
      num_pkt_col++;
      cg.sample();
      item_collected_port.write(packet_collected);

  endtask : collect_packet

endclass : yapp_tx_monitor

