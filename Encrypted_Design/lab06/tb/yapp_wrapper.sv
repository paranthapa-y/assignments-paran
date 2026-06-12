//------------------------------------------------------------------------------
// File: yapp_wrapper.sv
// Description: Wrapper around YAPP router DUT with all interface connections
//------------------------------------------------------------------------------

`timescale 1ns/1ps

module yapp_wrapper (
    input  logic clock,
    input  logic reset,
    output logic error,

    // Interfaces
    yapp_if     in0,
    channel_if  ch0,
    channel_if  ch1,
    channel_if  ch2,
    hbus_if     hbus
);

  // DUT instantiation
  yapp_router dut (
      .clock(clock),
      .reset(reset),
      .error(error),

      // Input channel
      .in_data    (in0.in_data),
      .in_data_vld(in0.in_data_vld),
      .in_suspend (in0.in_suspend),

      // Output channel 0
      .data_0    (ch0.data),
      .data_vld_0(ch0.data_vld),
      .suspend_0 (ch0.suspend),

      // Output channel 1
      .data_1    (ch1.data),
      .data_vld_1(ch1.data_vld),
      .suspend_1 (ch1.suspend),

      // Output channel 2
      .data_2    (ch2.data),
      .data_vld_2(ch2.data_vld),
      .suspend_2 (ch2.suspend),

      // Host bus
      .haddr (hbus.haddr),
      .hdata (hbus.hdata_w),
      .hen   (hbus.hen),
      .hwr_rd(hbus.hwr_rd)
  );

endmodule : yapp_wrapper

