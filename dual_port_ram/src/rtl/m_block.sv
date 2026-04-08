module m_block #(parameter int W_LATENCY = 3, R_LATENCY = 2) (input logic [6:0] data_in,
input logic write_en,
input logic clk,
input logic rst,
input logic en,
output logic [6:0] data_out);
  logic [6:0] mem;
  logic r_count,w_count;


  always_ff @(posedge clk) begin
    if (rst) begin
        if (!mem) begin
            mem <= 0;
        end
      //mem <= 0;
      r_count <= 0;
      w_count <= 0;
    end
    else begin
      if (write_en && en) begin
        if (w_count < W_LATENCY) begin
          w_count <= w_count + 1;
        end
        else begin
          mem <= data_in;
          w_count <= 0;
        end
      end
      else if (en) begin
        if (r_count < R_LATENCY) begin
          r_count <= r_count + 1;
        end
        else begin
          data_out <= mem;
          r_count <= 0;
        end
       end
       else begin
          r_count <= 0;
          w_count <= 0;
       end

        

      end
    end


endmodule