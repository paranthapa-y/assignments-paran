/*-----------------------------------------------------------------
File name     : top.sv
Description   :
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

module top;

  // UVM class library compiled in a package
  import uvm_pkg::*;

  // Bring in the rest of the library (macros and template classes)
  `include "uvm_macros.svh"

  // Include yapp_packet definition
  `include "../sv/yapp_packet.sv"

  

  // clock, reset are generated here for this DUT
  reg reset;
  reg clock; 

  // channel Interface to the DUT
  channel_if ch0(clock, reset);

  // Instance of yapp_packet
  yapp_packet pkt;

  initial begin
    channel_vif_config::set(null,"*.tb.chan0.*","vif", ch0);
    run_test();
  end

  // Generate and print 5 random packets
  initial begin : gen_and_print_packets
    uvm_table_printer table_printer = new();
    uvm_tree_printer tree_printer = new();
    for (int i = 0; i < 5; i++) begin
      pkt = yapp_packet::type_id::create($sformatf("pkt_%0d", i));
      if (!pkt.randomize()) begin
        $display("Randomization failed for packet %0d", i);
      end else begin
        $display("\n--- Packet %0d (Table Printer) ---", i);
        pkt.print(table_printer);
        $display("\n--- Packet %0d (Tree Printer) ---", i);
        pkt.print(tree_printer);
      end
    end
  end

  initial begin
    reset <= 1'b1;
    clock <= 1'b1;
    #51 reset = 1'b0;
  end

  //Generate Clock
  always
    #50 clock = ~clock;

endmodule
