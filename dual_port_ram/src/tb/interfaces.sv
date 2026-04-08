interface des_if (input logic clk);
  logic [3:0] addra;
  logic [3:0] addrb;
  logic       wea;
  logic       en;
  logic       rst;
  logic [3:0] dina;
  logic [3:0] douta;
  logic [3:0] doutb;
endinterface