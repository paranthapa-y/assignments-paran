////////////////////////////////////////////////////
// yapp_if.sv
// Interface for the YAPP router's input port
///////////////////////////////////////////////////
interface yapp_if (
    input logic clock,
    input logic reset
);

  // --- Signals ---
  // These signals connect directly to the DUT's input port
  logic [7:0] in_data;
  logic       in_data_vld;
  logic       in_suspend;

  // --- Modports ---
  // Define signal directions from the perspective of each component

  // Driver's view (drives data and vld, samples suspend)
  //modport drv(input clock, input reset, output in_data, output in_data_vld, input in_suspend);

  // Monitor's view (passively samples all signals)
  // modport mon(input clock, input reset, input in_data, input in_data_vld, input in_suspend);

  // DUT's view (receives data and vld, drives suspend)
  // modport dut(input clock, input reset, input in_data, input in_data_vld, output in_suspend);

endinterface : yapp_if
