// ===============================================================
// Full Adder (1-bit)
// ---------------------------------------------------------------
// Inputs:
//    a      : First input bit
//    b      : Second input bit
//    cin    : Carry-in bit
//
// Outputs:
//    sum    : Sum output bit
//    c_out  : Carry-out bit

module full_adder(input a,b,cin,output sum, c_out);

  assign sum = (a^b)^cin;
  assign c_out = a&b | (a^b)&cin;
  
endmodule