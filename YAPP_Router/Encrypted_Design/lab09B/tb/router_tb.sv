/*-----------------------------------------------------------------
File name     : router_tb.sv
Description   : Testbench module coordinating test environment and DUT
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

class router_tb extends uvm_component;
    `uvm_component_utils(router_tb)
    yapp_env env;
    channel_env ch0;
    channel_env ch1;
    channel_env ch2;
    hbus_env hbus;

    function new(string name = "router_tb",
             uvm_component parent = null);
    super.new(name, parent);
    endfunction

    router_simple_vseq vseq;
    router_virtual_sequencer vseqr;
    // router_scoreboard sb;
    router_module_env ref_env;

    function void build_phase (uvm_phase phase);
        uvm_config_db#(int)::set( null,"*","recording_detail",1 );
        uvm_config_db#(int)::set( this, "ch0*", "has_tx", 0);
        uvm_config_db#(int)::set( this, "ch1*", "has_tx", 0);
        uvm_config_db#(int)::set( this, "ch2*", "has_tx", 0);
        set_config_int("hbus", "num_masters", 1);
        set_config_int("hbus", "num_slaves", 0);
        super.build_phase(phase);
        env = yapp_env::type_id::create("env", this);
        ch0 =channel_env::type_id::create("ch1", this);
        ch1 =channel_env::type_id::create("ch2", this);
        ch2 =channel_env::type_id::create("ch3", this);
        hbus =hbus_env::type_id::create("hbus", this);
        vseqr = router_virtual_sequencer::type_id::create("vseqr", this);
        // sb = router_scoreboard::type_id::create("sb", this);
        ref_env = router_module_env::type_id::create("ref_env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //vseqr.hbus_slv_seqr = hbus.masters[0].sequencer;
        vseqr.hbus_mst_seqr = hbus.masters[0].sequencer;
        vseqr.yapp_tx_seqr = env.agent.sequencer;

        env.agent.monitor.item_collected_port.connect(ref_env.refer.yapp_imp);
        hbus.bus_monitor.item_collected_port.connect(ref_env.refer.hbus_in_imp);


        ch0.monitor.item_collected_port.connect(ref_env.sb.ch0_imp);
        ch1.monitor.item_collected_port.connect(ref_env.sb.ch1_imp);
        ch2.monitor.item_collected_port.connect(ref_env.sb.ch2_imp);
    
    endfunction
endclass
