class router_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(router_virtual_sequencer)

    function new ( string name = "router_virtual_sequencer", uvm_component parent = null);
        super.new();
    endfunction

    hbus_slave_sequencer hbus_slv_seqr;
    hbus_master_sequencer hbus_mst_seqr;
    yapp_tx_sequencer yapp_tx_seqr;


endclass