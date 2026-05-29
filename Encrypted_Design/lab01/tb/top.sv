module top;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import the YAPP package
  `include "../sv/yapp_packet.sv"

  yapp_packet packet;
  yapp_packet copy_packet;
  yapp_packet clone_packet;

  bit compare_result;  // store compare() outcome

  initial begin
    // construct the packet for copy
    copy_packet = new("copy_packet");

    for (int i = 0; i < 5; i++) begin
      // allocate each packet using UVM factory
      packet = yapp_packet::type_id::create($sformatf("packet_%0d", i));

      $display("\nPACKET %0d", i);
      assert (packet.randomize());
      packet.print(uvm_default_tree_printer);
      packet.print(uvm_default_table_printer);
      packet.print(uvm_default_line_printer);
    end
    $display("\nCOPY");
    // copy usage
    copy_packet.copy(packet);
    copy_packet.print();

    $display("CLONE");
    // clone usage
    $cast(clone_packet, packet.clone());
    clone_packet.print();

    $display("\nCOMPARE");
    // compare usage (returns 1 if equal, 0 if different)
    compare_result = packet.compare(copy_packet);
    if (compare_result) $display("COMPARE RESULT: packet and copy_packet are EQUAL");
    else $display("COMPARE RESULT: packet and copy_packet are DIFFERENT");

    compare_result = packet.compare(clone_packet);
    if (compare_result) $display("COMPARE RESULT: packet and clone_packet are EQUAL");
    else $display("COMPARE RESULT: packet and clone_packet are DIFFERENT");
  end

endmodule : top

