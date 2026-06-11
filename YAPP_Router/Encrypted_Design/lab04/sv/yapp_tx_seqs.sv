/*-----------------------------------------------------------------
File name     : yapp_tx_seqs.sv
Description   : UVM sequence yapp_5_packets generating test stimulus scenarios
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

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
