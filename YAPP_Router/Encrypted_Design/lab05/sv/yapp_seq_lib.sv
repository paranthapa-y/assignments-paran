class yapp_seq_lib extends uvm_sequence_library #(yapp_packet);
    `uvm_object_utils(yapp_seq_lib)

    function new (string name = "yapp_seq_lib");
        super.new(name);
        add_sequence(yapp_012_seq::get_type());

        add_sequence(yapp_1_seq::get_type());

        add_sequence(yapp_111_seq::get_type());

        add_sequence(yapp_repeat_addr_seq::get_type());

        add_sequence(yapp_incr_payload_seq::get_type());
    endfunction
endclass