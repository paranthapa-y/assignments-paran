import uvm_pkg::*;

// include the UVM macros
`include "uvm_macros.svh"


class router_simple_vseq extends uvm_sequence;

  `uvm_object_utils(router_simple_vseq)
  `uvm_declare_p_sequencer(router_virtual_sequencer)

  // YAPP packets sequences
  yapp_pkg::six_yapp_seq              six_yapp;
  yapp_pkg::yapp_012_seq              yapp_012;

  // HBUS sequences
  hbus_pkg::hbus_small_packet_seq     hbus_small_pkt_seq;
  hbus_pkg::hbus_read_max_pkt_seq     hbus_rd_seq;
  hbus_pkg::hbus_set_default_regs_seq hbus_large_pkt_seq;


  function new(string name = "router_simple_vseq");
    super.new(name);
  endfunction : new

  virtual task body();
    starting_phase.raise_objection(this, get_type_name());

    `uvm_info("router_simple_vseq", "Executing router_simple_vseq", UVM_LOW)
    // Configure for small packets
    `uvm_do_on(hbus_small_pkt_seq, p_sequencer.hbus_sequencer)
    // Read the YAPP MAXPKTSIZE register (address 0)
    `uvm_do_on(hbus_rd_seq, p_sequencer.hbus_sequencer)
    // send 6 consecutive packets to addresses 0,1,2, cycling the address
    `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)
    `uvm_do_on(yapp_012, p_sequencer.yapp_sequencer)
    // Configure for large packets (default)
    `uvm_do_on(hbus_large_pkt_seq, p_sequencer.hbus_sequencer)
    // Read the YAPP MAXPKTSIZE register (address 0)
    `uvm_do_on(hbus_rd_seq, p_sequencer.hbus_sequencer)
    // Send 5 random packets
    `uvm_do_on(six_yapp, p_sequencer.yapp_sequencer)
    starting_phase.drop_objection(this, get_type_name());

  endtask : body



endclass : router_simple_vseq
