module m_block #(parameter int W_LATENCY = 3, R_LATENCY = 2) (input logic [6:0] data_in,
input logic write_en,
input logic clk,
input logic rst,
input logic en,
output logic [6:0] data_out);
  
  logic [6:0] mem; 
  logic [6:0] w_data_pipe [0:W_LATENCY-1];
  logic       w_valid_pipe[0:W_LATENCY-1];
  logic [6:0] r_data_pipe [0:R_LATENCY-1];
  logic       r_valid_pipe[0:R_LATENCY-1];

  integer i,j;

always_ff @(posedge clk) begin
  
    if (w_valid_pipe[W_LATENCY-1])
      mem <= w_data_pipe[W_LATENCY-1];

    // shift pipeline
    for (i = W_LATENCY-1; i > 0; i--) begin
      w_data_pipe[i]  <= w_data_pipe[i-1];
      w_valid_pipe[i] <= w_valid_pipe[i-1];
    end

    // load stage 0
    if (write_en && en) begin
      w_data_pipe[0]  <= data_in;
      w_valid_pipe[0] <= 1'b1;
    end
    else begin
      w_data_pipe[0]  <= '0;
      w_valid_pipe[0] <= 1'b0;
    end
end

always_ff @(posedge clk) begin
  
    if (r_valid_pipe[R_LATENCY-1])
      data_out <= r_data_pipe[R_LATENCY-1];

    // shift pipeline
    for (j = R_LATENCY-1; j > 0; j--) begin
      r_data_pipe[j]  <= r_data_pipe[j-1];
      r_valid_pipe[j] <= r_valid_pipe[j-1];
    end

    // load stage 0
    if (!write_en && en) begin
      r_data_pipe[0]  <= data_in;
      r_valid_pipe[0] <= 1'b1;
    end
    else begin
      r_data_pipe[0]  <= '0;
      r_valid_pipe[0] <= 1'b0;
    end
end

endmodule