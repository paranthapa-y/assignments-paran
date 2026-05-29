interface yapp_if (input logic clock, reset);
    logic [7:0]in_data;
    logic in_data_vld;
    logic in_suspend;
endinterface