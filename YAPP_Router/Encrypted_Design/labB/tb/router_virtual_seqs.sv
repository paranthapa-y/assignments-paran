/*-----------------------------------------------------------------
File name     : router_virtual_seqs.sv
Description   : Virtual sequence library for high-level test stimulus generation
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

class router_simple_vseq extends uvm_sequence;
    `uvm_object_utils(router_simple_vseq)
    `uvm_declare_p_sequencer(router_virtual_sequencer)

    hbus_small_packet_seq small_pkt_seq;

        // HBUS sequences
    hbus_read_max_pkt_seq      read_max_seq;
    hbus_set_default_regs_seq  default_regs_seq;

    yapp_bad_size_seq bad_size;
    
    yapp_bad_parity_seq bad_parity;
    hbus_write_seq hbus_wrt;

    // YAPP sequences
    yapp_012_seq              seq012;
    six_yapp_seq              seq6;
    function new(string name ="router_simple_vseq");
        super.new(name);
    endfunction

    task body();
    
        `uvm_info(get_type_name(), "Starting router_simple_vseq", UVM_LOW)

        if(starting_phase != null) starting_phase.raise_objection(this);

        //------------------------------------------------------------------
        // Configure router for small packets
        // MAXPKTSIZE = 20
        // ENABLE     = 1
        //------------------------------------------------------------------
        small_pkt_seq = hbus_small_packet_seq::type_id::create("small_pkt_seq");

        small_pkt_seq.start(p_sequencer.hbus_mst_seqr);

        //------------------------------------------------------------------
        // Read MAXPKTSIZE register
        //------------------------------------------------------------------
        read_max_seq = hbus_read_max_pkt_seq::type_id::create("read_max_seq_1"  );

        read_max_seq.start(p_sequencer.hbus_mst_seqr);

        hbus_wrt = hbus_write_seq::type_id::create("hbus_wrt");

        bad_size = yapp_bad_size_seq::type_id::create("bad_size");
        bad_size.max_pkt_size = read_max_seq.max_pkt_reg;
        bad_size.start(p_sequencer.yapp_tx_seqr);
        
        bad_parity = yapp_bad_parity_seq::type_id::create("bad_parity");
        bad_parity.start(p_sequencer.yapp_tx_seqr);


        //------------------------------------------------------------------
        // Send packets : 0,1,2,0,1,2
        //------------------------------------------------------------------
        `uvm_info("VSEQ","Finished read_max_seq_1",UVM_NONE)

        repeat(2)
        begin
            seq012 =yapp_012_seq::type_id::create("seq012");
            seq012.start(p_sequencer.yapp_tx_seqr);
            `uvm_info("VSEQ","Finished one seq012",UVM_NONE)

        end
        `uvm_info("VSEQ","Starting default_regs_seq",UVM_NONE)

        //------------------------------------------------------------------
        // Configure router for large packets
        // MAXPKTSIZE = 63
        //------------------------------------------------------------------
        default_regs_seq = hbus_set_default_regs_seq::type_id::create("default_regs_seq");

        default_regs_seq.start(p_sequencer.hbus_mst_seqr);

        //------------------------------------------------------------------
        // Read MAXPKTSIZE register again
        //------------------------------------------------------------------
        read_max_seq = hbus_read_max_pkt_seq::type_id::create("read_max_seq_2");

        read_max_seq.start(p_sequencer.hbus_mst_seqr);

        //------------------------------------------------------------------
        // Send 6 random packets
        //------------------------------------------------------------------
        seq6 = six_yapp_seq::type_id::create("seq6");

        seq6.start(p_sequencer.yapp_tx_seqr);

        //------------------------------------------------------------------
        // Finish
        //------------------------------------------------------------------
         `uvm_info("VSEQ","Before drop objection",UVM_NONE)

        if(starting_phase != null)
            starting_phase.drop_objection(this);
        `uvm_info("VSEQ","Completed body",UVM_NONE)
    endtask

endclass