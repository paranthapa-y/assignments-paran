class yapp_5_packets extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction


  task body();
    repeat (5) begin
      yapp_packet pkt;
      //pkt = yapp_packet::type_id::create("pkt", this);
      `uvm_do(pkt)
    end
  endtask

endclass



class yapp_012_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction

  task body();
  `uvm_info(get_type_name(), "Executing yapp_012_seq", UVM_LOW)

    `uvm_do_with(req, { addr == 0; })
    `uvm_do_with(req, { addr == 1; })
    `uvm_do_with(req, { addr == 2; })
  endtask
endclass

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

class yapp_111_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction

  task body();
  `uvm_info(get_type_name(),
              "Executing yapp_111_seq",
              UVM_LOW)

    repeat(3)
    begin
      seq1 = yapp_1_seq::type_id::create("seq1");
      seq1.start(m_sequencer);
    end
  endtask
endclass

class yapp_repeat_addr_seq extends yapp_5_packets;

  `uvm_object_utils(yapp_repeat_addr_seq)

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction

  task body();
    repeat (2) begin
      yapp_packet pkt;
      //pkt = yapp_packet::type_id::create("pkt", this);
      `uvm_do_with(req, {addr !=3});
    end
  endtask
endclass