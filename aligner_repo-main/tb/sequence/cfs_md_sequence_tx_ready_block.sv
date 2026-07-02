`ifndef CFS_MD_SEQUENCE_TX_READY_BLOCK_SV

`define CFS_MD_SEQUENCE_TX_READY_BLOCK_SV

class cfs_md_sequence_tx_ready_block extends cfs_md_sequence_base_slave;

  `uvm_object_utils(cfs_md_sequence_tx_ready_block)

  function new(string name = "");

    super.new(name);

  endfunction

  virtual task body();

    cfs_md_item_mon item_mon;

    
    // env.md_tx_agent.agent_config.set_disable_ready(1);
    forever begin
      cfs_md_sequence_simple_slave seq;
      p_sequencer.pending_items.get(item_mon);
      

      `uvm_info("cfs_md_sequence_tx_ready_block", $sformatf("Received item with data: %p", item_mon.data), UVM_NONE)
      `uvm_do_with(seq,
                   {

        seq.item.ready_at_end == 0;

      })

    end

  endtask

endclass

`endif  // CFS_MD_SEQUENCE_TX_READY_BLOCK_SV


