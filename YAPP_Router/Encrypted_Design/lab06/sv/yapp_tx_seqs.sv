/*-----------------------------------------------------------------
File name     : yapp_tx_seqs.sv
Description   : UVM sequence yapp_5_packets generating test stimulus scenarios
-----------------------------------------------------------------*/

`ifndef YAPP_TX_SEQS_SV
`define YAPP_TX_SEQS_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------------------------------
// Base sequence : Generates 5 random packets
//------------------------------------------------------------------------------
class yapp_5_packets extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "Executing yapp_5_packets",
              UVM_LOW)

    repeat (5) begin
      `uvm_do(req)
    end

  endtask

endclass


//------------------------------------------------------------------------------
// Sequence : Packets with addresses 0,1,2
//------------------------------------------------------------------------------
class yapp_012_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "Executing yapp_012_seq",
              UVM_LOW)

    `uvm_do_with(req, { addr == 0; })
    `uvm_do_with(req, { addr == 1; })
    `uvm_do_with(req, { addr == 2; })

  endtask

endclass


//------------------------------------------------------------------------------
// Sequence : Single packet to address 1
//------------------------------------------------------------------------------
class yapp_1_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_1_seq)

  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "Executing yapp_1_seq",
              UVM_LOW)

    `uvm_do_with(req, {
      addr == 1;
    })

  endtask

endclass


//------------------------------------------------------------------------------
// Sequence : Three packets to address 1 using nested sequence
//------------------------------------------------------------------------------
class yapp_111_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction

  task body();

    yapp_1_seq seq1;

    `uvm_info(get_type_name(),
              "Executing yapp_111_seq",
              UVM_LOW)

    repeat (3) begin
      seq1 = yapp_1_seq::type_id::create("seq1");
      seq1.start(m_sequencer);
    end

  endtask

endclass


//------------------------------------------------------------------------------
// Sequence : Two packets to same random address
//------------------------------------------------------------------------------
class yapp_repeat_addr_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_repeat_addr_seq)

  int prev_addr;

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "Executing yapp_repeat_addr_seq",
              UVM_LOW)

    // First packet
    `uvm_do_with(req, {
      addr != 3;
    })

    prev_addr = req.addr;

    // Second packet with same address
    `uvm_do_with(req, {
      addr == prev_addr;
    })

  endtask

endclass


//------------------------------------------------------------------------------
// Sequence : Incrementing payload sequence
//------------------------------------------------------------------------------
class yapp_incr_payload_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction

  task body();

    int i;

    `uvm_info(get_type_name(),
              "Executing yapp_incr_payload_seq",
              UVM_LOW)

    `uvm_create(req)

    assert(req.randomize());

    foreach(req.payload[i]) begin
      req.payload[i] = i;
    end

    req.parity = req.calc_parity();

    `uvm_send(req)

  endtask

endclass


//------------------------------------------------------------------------------
// Optional : Random number of packets
//------------------------------------------------------------------------------
class yapp_rnd_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_rnd_seq)

  rand int count;

  constraint count_c {
    count inside {[1:10]};
  }

  function new(string name = "yapp_rnd_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              $sformatf("Executing yapp_rnd_seq with count = %0d",
                         count),
              UVM_LOW)

    repeat(count) begin
      `uvm_do(req)
    end

  endtask

endclass


//------------------------------------------------------------------------------
// Optional : Six packet sequence
//------------------------------------------------------------------------------
class six_yapp_seq extends yapp_5_packets;

  `uvm_object_utils(six_yapp_seq)

  yapp_rnd_seq rnd_seq;

  function new(string name = "six_yapp_seq");
    super.new(name);
  endfunction

  task body();

    `uvm_info(get_type_name(),
              "Executing six_yapp_seq",
              UVM_LOW)

    rnd_seq = yapp_rnd_seq::type_id::create("rnd_seq");

    assert(rnd_seq.randomize() with {
      count == 6;
    });

    rnd_seq.start(m_sequencer);

  endtask

endclass

`endif