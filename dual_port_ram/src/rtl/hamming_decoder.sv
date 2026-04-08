module hamming_decoder( input logic unsigned [6:0] e_code, output logic [3:0] data_out, output logic error);
    logic p1, p2, p4;
    logic [2:0] syndrome;
    logic [6:0] corrected_code;

  always_comb begin
    p1 = e_code[0] ^ e_code[2] ^ e_code[4] ^ e_code[6];
    p2 = e_code[1] ^ e_code[2] ^ e_code[5] ^ e_code[6];
    p4 = e_code[3] ^ e_code[4] ^ e_code[5] ^ e_code[6];
    
    corrected_code = e_code;
    syndrome = {p4, p2, p1}; 
    if (syndrome != 0) begin
      
      corrected_code[syndrome-1] = ~corrected_code[syndrome-1];
    end
    data_out = {corrected_code[6], corrected_code[5], corrected_code[4], corrected_code[2]};
    
    error = (p1 != 0) || (p2 != 0) || (p4 != 0);
  end
endmodule