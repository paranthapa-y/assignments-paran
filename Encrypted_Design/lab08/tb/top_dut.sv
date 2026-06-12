`timescale 1ns / 100ps
module top_dut;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // import only the packet package for packet types
  import yapp_pkg::*;

  `include "router_virtual_sequencer.sv"
  `include "router_virtual_seqs.sv"
  `include "router_tb.sv"
  `include "router_vtest_lib.sv"  // <-- NEW include for virtual sequencer tests

  // clock, reset, error
  bit reset;
  bit clock;
  bit error;

  // YAPP Interface to the DUT
  yapp_if in0 (
      clock,
      reset
  );

  hbus_if hbus_if0 (
      clock,
      reset
  );

  channel_if channel_if0 (
      clock,
      reset
  );
  channel_if channel_if1 (
      clock,
      reset
  );
  channel_if channel_if2 (
      clock,
      reset
  );

  // DUT instantiation
  yapp_router dut (
      .reset(reset),
      .clock(clock),
      .error(error),
      .in_data(in0.in_data),
      .in_data_vld(in0.in_data_vld),
      .in_suspend(in0.in_suspend),
      .data_0(channel_if0.data),
      .data_vld_0(channel_if0.data_vld),
      .suspend_0(channel_if0.suspend),
      .data_1(channel_if1.data),
      .data_vld_1(channel_if1.data_vld),
      .suspend_1(channel_if1.suspend),
      .data_2(channel_if2.data),
      .data_vld_2(channel_if2.data_vld),
      .suspend_2(channel_if2.suspend),
      .haddr(hbus_if0.haddr),
      .hdata(hbus_if0.hdata_w),
      .hen(hbus_if0.hen),
      .hwr_rd(hbus_if0.hwr_rd)
  );

  // VIF configuration and run_test
  initial begin
    // Fully qualified class names
    yapp_pkg::yapp_vif_config::set(null, "*.route.env.agent.*", "vif", in0);
    channel_pkg::channel_vif_config::set(null, "*.route.channel_env0.*", "vif", channel_if0);
    channel_pkg::channel_vif_config::set(null, "*.route.channel_env1.*", "vif", channel_if1);
    channel_pkg::channel_vif_config::set(null, "*.route.channel_env2.*", "vif", channel_if2);
    hbus_pkg::hbus_vif_config::set(null, "*.route.hbus.*", "vif", hbus_if0);

    run_test();
  end

  // Reset sequence
  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;
    @(negedge clock) #1 reset <= 1'b1;
    @(negedge clock) #1 reset <= 1'b0;
  end

  // Generate Clock
  always #10 clock = ~clock;

endmodule

