//=============================================================
//  FSM based De-Skew Circuit
//
//  Purpose:
//  --------
//  Align two 4-bit input streams (i_stream1, i_stream2)
//  based on detection of sync pattern 4'hA.
//  Maximum allowed skew = 2 clock cycles.
// Inputs :
// 	i_clk 	  : input clock
// 	i_stream1 : data stream 1
// 	i_stream2 : data stream 2
// outputs:
// 	o_stream  : output stream [8 - bit]
// 	o_aligned : single bit signal to represent the data stream alignment.
//
module fsm(input i_clk, reset, [3:0] i_stream1, i_stream2, output [7:0] o_stream, output o_aligned);

  logic [1:0] c =0;
  logic [2:0] [3:0] fifo1, fifo2;
  logic [7:0] out_stream;
  parameter [1:0] IDLE = 2'b00;
  parameter [1:0] FIND = 2'b01;
  parameter [1:0] ALIGNED = 2'b10;
  logic [1:0] state, next_state;
  logic [1:0] LSB_ind;

  //declarations of registers and wires

  always_comb begin //
	  next_state =state;
	  case(state)
		  IDLE : begin
            if ((i_stream1 == 4'hA) & (i_stream2 == 4'hA)) begin
				  next_state = ALIGNED;
              $display("both");
              //LSB_ind = 2'b01;
              
            end
            else if (i_stream1 == 4'hA) begin
              $display("one");
              next_state = FIND;
				  //LSB_ind = 2'b01;
			  end
            else if (i_stream2 == 4'hA) begin
              $display("two");
				  next_state = FIND;
				  //LSB_ind = 2'b10;
			  end

		  end
		  FIND : begin
            if ((i_stream1 == 4'hA) & c <2 & LSB_ind[1] )begin
				  next_state = ALIGNED;
              //out_stream = {i_stream1, fifo2[c-1]};
			  end
            if ((i_stream2 == 4'hA) & c <2 & LSB_ind[0] )begin
				  next_state = ALIGNED;
              //out_stream = {i_stream2, fifo1[c-1]};
			  end	  

		  end
		  ALIGNED : begin
			  next_state = state;
            out_stream = LSB_ind[1]? {fifo1[2],fifo2[2-c]}: {fifo2[2],fifo1[2-c]};
		  end 
	  endcase
  end

  assign o_stream = (state == ALIGNED)? out_stream : 0;
  assign o_aligned = (state == ALIGNED);

  always_ff @(posedge i_clk) begin
    if( reset) begin
      state <= IDLE;
      c<=0;
    end
    else begin
	  state <= next_state;
      fifo1 <= {i_stream1, fifo1[2:1]};
      fifo2 <= {i_stream2, fifo2[2:1]};
    end
    if (state == FIND) begin
        $display("count");
		c <= c+1;
      end
    if (state == IDLE) begin
		//c <=0;
    if (i_stream1 == 4'hA && i_stream2 == 4'hA)
                LSB_ind <= 2'b01;

            else if (i_stream2 == 4'hA && i_stream1 != 4'hA)
                LSB_ind <= 2'b10;

            else if (i_stream1 == 4'hA && i_stream2 != 4'hA)
                LSB_ind <= 2'b01;   // choose convention
      
    end
  end
endmodule
