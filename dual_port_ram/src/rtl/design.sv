// 2- port memory with only signle write enable port.
`include "hamming_encoder.sv"
`include "hamming_decoder.sv"
`include "m_block.sv"

module ram #(parameter int unsigned W_LATENCY = 3, R_LATENCY = 2, ADDR_WIDTH = 4, DATA_WIDTH = 4) (
  input  logic unsigned [ADDR_WIDTH-1:0] addra,
  input  logic unsigned [ADDR_WIDTH-1:0] addrb,
  input  logic       wea,
  input  logic       en,
  input  logic       rst,
  input  logic       clk,
  input  logic unsigned [DATA_WIDTH-1:0] dina,
  output logic unsigned [DATA_WIDTH-1:0] douta,
  output logic unsigned [DATA_WIDTH-1:0] doutb
);
  //logic addra,addrb,wea,en, clk,dina;
  //wire douta,doutb,rst;
  localparam int LENGTH = 1 << ADDR_WIDTH;
  logic [6:0] en_dina, en_douta, en_doutb;
  logic [6:0] block_out [0: LENGTH-1];
  // localparam int W_LATENCY = 3;
  // localparam int R_LATENCY = 2;



  hamming_encoder encoder(.data_in(dina[3:0]), .e_code(en_dina[6:0]));
  hamming_decoder decoder_a(.e_code(en_douta[6:0]), .data_out(douta[3:0]), .error());
  hamming_decoder decoder_b(.e_code(en_doutb[6:0]), .data_out(doutb[3:0]), .error());

  
  genvar i;
  generate
    for (i = 0; i < LENGTH; i++) begin : mem_gen
      m_block #(
        .W_LATENCY(W_LATENCY),
        .R_LATENCY(R_LATENCY)
      ) block (
        .data_in (en_dina),                        // same input to all
        .write_en(wea && (addra == i)),      // only one writes
        .en (en),                     // simplified read
        .clk     (clk),
        .rst     (rst),
        .data_out(block_out[i])                    // collect outputs
      );
    end
  endgenerate
  assign en_douta = block_out[addra];
  assign en_doutb = block_out[addrb];

endmodule