//------------------------------------------------------------------------------
//
// BASE SEQUENCE: yapp_base_seq
//
//------------------------------------------------------------------------------
class yapp_base_seq extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_base_seq)

  // Transaction handle available for all child sequences
  yapp_packet pkt;

  function new(string name = "yapp_base_seq");
    super.new(name);
  endfunction

endclass : yapp_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_5_packets
//
//------------------------------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;

  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
    repeat (5) `uvm_do(pkt)
  endtask

endclass : yapp_5_packets

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_012_seq
//
//------------------------------------------------------------------------------
class yapp_012_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_012_seq sequence", UVM_LOW)
    `uvm_do_with(pkt, { addr == 2'b00; })
    `uvm_do_with(pkt, { addr == 2'b01; })
    `uvm_do_with(pkt, { addr == 2'b10; })
  endtask

endclass : yapp_012_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_1_seq
//
//------------------------------------------------------------------------------
class yapp_1_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_1_seq)

  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
    `uvm_do_with(pkt, { addr == 2'b01; })
  endtask : body

endclass : yapp_1_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_111_seq
//
//------------------------------------------------------------------------------
class yapp_111_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction : new

  yapp_1_seq yapp_seq;

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_111_seq sequence", UVM_LOW)
    repeat (3) `uvm_do(yapp_seq)
  endtask : body

endclass : yapp_111_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_repeat_addr_seq
//
//------------------------------------------------------------------------------
class yapp_repeat_addr_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_repeat_addr_seq)

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction : new

  rand bit [1:0] seq_addr;

  constraint seq_addr_c {seq_addr <= 2'b00;}//changed to 00 instead of 2 after randomise() failure

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq sequence", UVM_LOW)
    `uvm_do_with(pkt, { addr == seq_addr; })
    `uvm_do_with(pkt, { addr == seq_addr; })
  endtask : body

endclass : yapp_repeat_addr_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_incr_payload_seq
//
//------------------------------------------------------------------------------
class yapp_incr_payload_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_incr_payload_seq sequence", UVM_LOW)
    `uvm_create(pkt)
    assert (pkt.randomize());
    for (int i = 0; i < pkt.length; i++) pkt.payload[i] = i;
    pkt.post_randomize();
    `uvm_send(pkt);
  endtask : body

endclass : yapp_incr_payload_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_rnd_seqs
//
//------------------------------------------------------------------------------
class yapp_rnd_seqs extends yapp_base_seq;

  `uvm_object_utils(yapp_rnd_seqs)

  function new(string name = "yapp_rnd_seqs");
    super.new(name);
  endfunction : new

  rand int count;

  constraint count_constraint {count inside {[1 : 10]};}

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Executing yapp_rnd_seqs %0d times...", count), UVM_LOW)
    repeat (count) begin
      `uvm_do(pkt)
    end
  endtask : body

endclass : yapp_rnd_seqs

//------------------------------------------------------------------------------
//
// SEQUENCE: six_yapp_seq
//
//------------------------------------------------------------------------------
class six_yapp_seq extends yapp_base_seq;
  `uvm_object_utils(six_yapp_seq)

  yapp_rnd_seqs yss;

  function new(string name = "six_yapp_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing six_yapp_seq sequence", UVM_LOW)
    `uvm_do_with(yss, {count==6;})
  endtask
endclass : six_yapp_seq

