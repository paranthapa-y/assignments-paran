import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../sv/yapp.svh"

`include "yapp_seq_lib.sv"
`include "router_tb.sv"
`include "router_test_lib.sv"
module top_no_dut;

 // clock, reset are generated here for this DUT
  bit reset;
  bit clock;

  // YAPP Interface to the DUT
  yapp_if in0 (
      clock,
      reset
  );

  initial begin
    // put interface into config_db for driver + monitor
    yapp_vif_config::set(null, "*", "vif", in0);
    run_test();
  end

  // Reset generation
  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;
    in0.in_suspend <= 1'b0;

    repeat (2) @(negedge clock);
    reset <= 1'b1;
    repeat (2) @(negedge clock);
    reset <= 1'b0;
  end

  // Generate Clock
  always #10 clock = ~clock;

endmodule : top_no_dut
