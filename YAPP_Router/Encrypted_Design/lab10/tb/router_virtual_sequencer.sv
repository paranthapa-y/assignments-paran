class router_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);;
    `uvm_component_utils(router_virtual_sequencer)

    function new ( string name = "router_virtual_sequencer", uvm_component parent = null);
        super.new(name ,parent);
    endfunction

    hbus_slave_sequencer hbus_slv_seqr;
    hbus_master_sequencer hbus_mst_seqr;
    yapp_tx_sequencer yapp_tx_seqr;

    function void start_of_simulation_phase(uvm_phase phase);
   super.start_of_simulation_phase(phase);
   `uvm_info("DEBUG",
             $sformatf("I am %s", get_full_name()),
             UVM_NONE)
endfunction


endclass