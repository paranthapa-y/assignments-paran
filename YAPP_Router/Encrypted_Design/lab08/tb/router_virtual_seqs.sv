class router_virtual_seqs extends uvm_sequence;
    `uvm_object_utils(router_virtual_seqs)
    `uvm_declare_p_sequencer(router_virtual_sequencer)

    hbus_small_packet_seq hbus_small_seq;
    function new(string name ="router_virtual_seqs", uvm_component parent = null);
        super.new();
    endfunction

    task body();
     

    endtask

    if (starting_phase !=null);
        starting_phase.raise_objection();
        
endclass