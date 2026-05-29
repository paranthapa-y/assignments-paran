class yapp_seq_lib extends uvm_sequence_library;
  `uvm_object_utils(yapp_seq_lib)

  function new(string name = "seq_lib");
    super.new(name);
    add_sequence(yapp_5_packets::get_type());
    add_sequence(yapp_012_seq::get_type());
    add_sequence(yapp_1_seq::get_type());
    add_sequence(yapp_111_seq::get_type());
    add_sequence(yapp_repeat_addr_seq::get_type());
    add_sequence(yapp_incr_payload_seq::get_type());
       add_sequence(yapp_rnd_seqs::get_type());
    add_sequence(six_yapp_seq::get_type());
  endfunction

endclass
