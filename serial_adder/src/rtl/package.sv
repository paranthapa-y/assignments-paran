// ----------------SIPO-------------------------------------------

module SIPO #(parameter N=8)(input clk, reset, enable, sum, output [N:0]qo);
  
  genvar i;
  wire [N:0]q;
  
  //if (reset) begin
    
  d_ff ff0 (.clk(clk),.reset(reset), .d(enable? sum : q[N]),.q(q[N]));
  generate
    for (i=N-1; i>=0;i=i-1) begin : shift_chain
      d_ff ff (.clk(clk), .reset(reset), .d(enable? q[i+1]: q[i]), .q(q[i]));
    end
  endgenerate
  assign qo= q;
  
  
endmodule

// ------------------PISO-----------------------------------------
  
module PISO #(parameter N=8)(input clk, load, enable, [N-1:0] A, output q);
  
  genvar i;
  wire [N-1:0]temp;
  d_ff ff_last (
    .clk(clk),
    .reset(reset),
    .d(load ? A[N-1] :
       (enable ? 1'b0 : temp[N-1])),
    .q(temp[N-1])
  );

  generate
    for (i=N-2; i>=0; i=i-1) begin: dff_inst
      d_ff dff_i (
        .clk(clk),
        .reset(reset),
        .d(load ? A[i] :
           (enable ? temp[i+1] : temp[i])),
        .q(temp[i])
      );
    end
   
  endgenerate 
  assign q = temp[0];
      
endmodule

// ----------------FULL ADDER-------------------------------------------   
          
module full_adder(input a,b,cin,output sum, c_out);
  assign sum = (a^b)^cin;
  assign c_out = a&b | (a^b)&cin;
endmodule
          
// -----------------D FLIPFLOP------------------------------------------

module d_ff (input clk,reset,d,output reg q);
  always @(posedge clk) begin
    if (reset) begin
      q <= 0;
    end
    else begin
      q <= d;
    end
  end
endmodule