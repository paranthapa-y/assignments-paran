import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../../channel/sv/channel_if.sv"
`include "../../hbus/sv/hbus_if.sv"
// Your YAPP UVC
`include "../../yapp/sv/yapp_pkg.sv"
// UVC packages
`include "../../hbus/sv/hbus_pkg.sv"
`include "../../channel/sv/channel_pkg.sv"   // if it exists


// Testbench files
`include "router_virtual_sequencer.sv"
`include "router_virtual_seqs.sv"

`include "router_tb.sv"
`include "router_test_lib.sv"

// DUT RTL
`include "../../Encrypted/yapp_router.svh"
module top_no_dut;

 // clock, reset are generated here for this DUT
  bit reset;
  bit clock;

  // YAPP Interface to the DUT
  yapp_if in0 ( clock, reset);
  channel_if ch_1 ( clock, reset);
  channel_if ch_2 ( clock, reset);
  channel_if ch_3 ( clock, reset);
  hbus_if h_bus ( clock, reset);

  // DUT instantiation
  yapp_router dut (
      .reset(reset),
      .clock(clock),
      .error(error),
      .in_data(in0.in_data),
      .in_data_vld(in0.in_data_vld),
      .in_suspend(in0.in_suspend),
      .data_0(ch_1.data),
      .data_vld_0(ch_1.data_vld),
      .suspend_0(ch_1.suspend),
      .data_1(ch_2.data),
      .data_vld_1(ch_2.data_vld),
      .suspend_1(ch_2.suspend),
      .data_2(ch_3.data),
      .data_vld_2(ch_3.data_vld),
      .suspend_2(ch_3.suspend),
      .haddr(h_bus.haddr),
      .hdata(h_bus.hdata_w),
      .hen(h_bus.hen),
      .hwr_rd(h_bus.hwr_rd)
  );

  /* yapp_wrapper wrapper (
      .clock(clock),
      .reset(reset),
      .error(error),
      .in0  (in0),
      .ch0  (ch_1),
      .ch1  (ch_2),
      .ch2  (ch_3),
      .hbus (h_bus)
  );*/
  initial begin
    // put interface into config_db for driver + monitor
    uvm_config_db#(virtual yapp_if)::set(null, "*", "vif", in0);
    uvm_config_db#(virtual channel_if)::set(
    null,
    "uvm_test_top.r_tb.ch1*",
    "vif",
    ch_1
    );

    uvm_config_db#(virtual channel_if)::set(
        null,
        "uvm_test_top.r_tb.ch2*",
        "vif",
        ch_2
    );

    uvm_config_db#(virtual channel_if)::set(
        null,
        "uvm_test_top.r_tb.ch3*",
        "vif",
        ch_3
    );

    uvm_config_db#(virtual hbus_if)::set(null, "*", "vif", h_bus);

    run_test();
  end

  // Reset generation
  initial begin
    $timeformat(-9, 0, " ns", 8);
    reset <= 1'b0;
    clock <= 1'b1;
    //in0.in_suspend <= 1'b0;

    repeat (2) @(negedge clock);
    reset <= 1'b1;
    repeat (2) @(negedge clock);
    reset <= 1'b0;
  end

  // Generate Clock
  always #10 clock = ~clock;

endmodule : top_no_dut
