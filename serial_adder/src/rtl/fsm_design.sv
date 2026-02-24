// Finite State Machine for the Serial adder design. It has 4 states, IDLE, LOAD, SHIFT and DONE. The FSM controls the loading of the inputs, shifting of the bits and the final output of the sum.
// The FSM transitions from IDLE to LOAD when the resetn signal is high. It then transitions to SHIFT where it enables the shifting of bits until all bits are processed. Finally, it transitions to DONE where it indicates that the addition is complete and the final sum is available at the output.
// Inputs:
//    clk     : Clock signal
//    start   : Start signal to begin addition
//    resetn  : Active-low synchronous reset
//    A, B    : N-bit operands to be added
// Outputs:
//    load    : Load inputs into shift registers
//    enable  : Enable shifting of bits
//    reset   : Active-high reset for internal registers
//    done    : Indicates final sum is ready


module FSM #(parameter N) ( input clk, start, resetn,output load, enable, reset, done);
// iputs are clk(clock), start, resetn, A and B. Outputs are load, enable, reset and done.

    parameter [1:0]IDLE  = 2'b00; // Wait for start/reset
    parameter [1:0]LOAD  = 2'b01; // Load operands into registers
    parameter [1:0]SHIFT = 2'b10; // Shift operands bit by bit and compute sum
    parameter [1:0]DONE  = 2'b11; // Addition complete, output valid

    localparam W = $clog2(N + 1);// Width of counter to count N shifts

    reg [W-1:0] count; // Counter to track number of bits shifted
    reg [1:0] state, next_state;
    
    // Combinational logic to determine the next state based on the current state and inputs
    always @(*) begin
      next_state = state;
        case(state)
        IDLE : begin
            // Wait for resetn to become high to start addition
            if (resetn) begin
            next_state = LOAD;
            end
        end
        LOAD : begin 
            // After loading operands, move to SHIFT state
            next_state = SHIFT;
        end
        SHIFT : begin
            // Keep shifting until all N bits are processed
            if (count>=(N))
            next_state = DONE;
        end
        DONE : begin
            // Remain in DONE state until reset
            next_state = DONE;
        end
        endcase
    end
  
  
  //assign the outputs based on the current state
  assign done = (state == DONE);
  assign load = (state == LOAD);
  assign enable = ((state == SHIFT) & start);
  assign reset = ~resetn;
  
  // Sequential logic to update the state and count
  always @( posedge clk) begin
    if (~resetn) begin // Reset FSM to IDLE and clear count
      state <= IDLE;
      count <= 0;
    end
    else
      state<= next_state;
    if (((state == SHIFT))&& (start)) begin 
      count <= count+1;
    end
  end
endmodule
