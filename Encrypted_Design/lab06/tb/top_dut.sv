//------------------------------------------------------------------------------
// File: top_dut.sv
// Description: Top-level testbench using yapp_wrapper
//------------------------------------------------------------------------------
`timescale 1ns / 100ps
module top_dut;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Include TB components
  `include "../sv/yapp.svh"
  `include "yapp_seq_lib.sv"
  `include "router_tb.sv"
  `include "router_test_lib.sv"

  // clock, reset
  bit reset;
  bit clock;
  bit error;

  // Interfaces
  yapp_if    in0 (clock, reset);
  channel_if ch0 (clock, reset);
  channel_if ch1 (clock, reset);
  channel_if ch2 (clock, reset);
  hbus_if    hbus(clock, reset);

  // DUT wrapper
  yapp_wrapper wrapper (
      .clock(clock),
      .reset(reset),
      .error(error),
      .in0(in0),
      .ch0(ch0),
      .ch1(ch1),
      .ch2(ch2),
      .hbus(hbus)
  );

  // Config DB setup
  initial begin
    yapp_vif_config::set(null, "*", "vif", in0);

    // Drive suspend signals low (active=0)
    ch0.suspend = 1'b0;
    ch1.suspend = 1'b0;
    ch2.suspend = 1'b0;

    run_test();
  end

  // Reset generation
  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;

    repeat (2) @(negedge clock);
    reset <= 1'b1;
    repeat (2) @(negedge clock);
    reset <= 1'b0;
  end

  // Clock generation
  always #10 clock = ~clock;

endmodule : top_dut

