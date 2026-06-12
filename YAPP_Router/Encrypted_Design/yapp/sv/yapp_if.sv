interface yapp_if (
    input logic clock,
    input logic reset
);

  // --- Signals ---
  // These signals connect directly to the DUT's input port
  logic [7:0] in_data;
  logic       in_data_vld;
  logic       in_suspend;
endinterface