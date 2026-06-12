/*-----------------------------------------------------------------
File name     : yapp_if.sv
Description   : Interface yapp_if defining signals to connect DUT and testbench
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

interface yapp_if (input logic clock, reset);
    logic [7:0] in_data;
    logic in_data_vld;
    logic in_suspend;
endinterface