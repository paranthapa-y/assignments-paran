//------------------------------------------------------------------------------
// File: yapp_seq_lib.sv
// Description: Sequence library consisting of all the defined sequences
//------------------------------------------------------------------------------

`ifndef YAPP_SEQ_LIB_SV
`define YAPP_SEQ_LIB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;



//------------------------------------------------------------------------------
// Base Test Class
//------------------------------------------------------------------------------
class yapp_seq_lib extends uvm_sequence_library #(yapp_packet);
  `uvm_object_utils(yapp_seq_lib)

  // Constructor
  function new(string name = "yapp_seq_lib");
    super.new(name);

    // Add all sequences to the library
    add_sequence(yapp_5_packets::get_type());
    add_sequence(yapp_012_seq::get_type());
    add_sequence(yapp_1_seq::get_type());
    add_sequence(yapp_111_seq::get_type());
    add_sequence(yapp_repeat_addr_seq::get_type());
    add_sequence(yapp_incr_payload_seq::get_type());
    add_sequence(yapp_rnd_seqs::get_type());
    add_sequence(six_yapp_seq::get_type());

    init_sequence_library();
  endfunction : new

endclass : yapp_seq_lib
`endif  // YAPP_SEQ_LIB_SV

