class yapp_base_seq extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_base_seq)

  function new(string name = "yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    starting_phase.raise_objection(this, get_type_name());
    `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
  endtask : pre_body

  task post_body();
    starting_phase.drop_objection(this, get_type_name());
    `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
  endtask : post_body
endclass




class yapp_5_packets extends yapp_base_seq;
  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction

  task body();
    repeat (5) begin
      `uvm_do(req)
    end
  endtask
endclass





class yapp_012_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction

  task body();
    // Use 'req' and the correct field name 'addr'
    `uvm_do_with(req, {addr == 2'b00;})
    `uvm_do_with(req, {addr == 2'b01;})
    `uvm_do_with(req, {addr == 2'b10;})
  endtask
endclass





class yapp_1_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_1_seq)

  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction
  task body();
    // yapp_packet pkt;
    `uvm_info(get_type_name(), $sformatf("Starting sequence %s", get_name()), UVM_LOW)
    `uvm_do_with(req, {addr==2'b01;})
  endtask
endclass





class yapp_111_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction

  task body();
    yapp_1_seq sub_seq;  // Handle for the sub-sequence
    `uvm_info(get_type_name(), $sformatf("Starting sequence %s", get_name()), UVM_LOW)

    repeat (3) begin
      `uvm_do(sub_seq)
    end
  endtask
endclass





class yapp_repeat_addr_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_repeat_addr_seq)

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction

  task body();
    bit [1:0] captured_addr;
    `uvm_info(get_type_name(), $sformatf("Starting sequence %s", get_name()), UVM_LOW)

    `uvm_do(req)
    captured_addr = req.addr;  // Use the correct field name 'addr'

    `uvm_info(get_type_name(), $sformatf("First packet sent to addr %0d. Sending second to same.",
                                         captured_addr), UVM_LOW)
    `uvm_do_with(req, {addr == captured_addr;})
    `uvm_info(get_type_name(), "Sequence finished.", UVM_LOW)
  endtask
endclass





class yapp_incr_payload_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Executing sequence...", UVM_LOW)

    `uvm_create(req)
    if (!req.randomize()) begin
      `uvm_error(get_type_name(), "Packet randomization failed!")
    end
    `uvm_info(get_type_name(), $sformatf("Overwriting payload for length %0d", req.length),
              UVM_MEDIUM)
    foreach (req.payload[i]) begin
      req.payload[i] = i;
    end

    req.parity_type = GOOD_PARITY;  // Ensure we calculate correct parity
    req.parity = req.calc_parity();

    `uvm_info(get_type_name(), $sformatf("Sending packet with incrementing payload:\n%s",
                                         req.sprint()), UVM_LOW)
    `uvm_send(req)
    `uvm_info(get_type_name(), "Sequence finished.", UVM_LOW)
  endtask : body

endclass

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
      `uvm_do(req)
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

