module hamming_encoder( input logic [3:0] data_in, output logic [6:0] e_code);
  logic p1, p2, p4;
  
  // Calculate parity bits
  always_comb begin
    p1 = data_in[0] ^ data_in[1] ^ data_in[3]; // Parity for bits 1, 2, 4
    p2 = data_in[0] ^ data_in[2] ^ data_in[3]; // Parity for bits 1, 3, 4
    p4 = data_in[1] ^ data_in[2] ^ data_in[3]; // Parity for bits 2, 3, 4
    
    // Construct the encoded output
    e_code = {data_in[3], data_in[2], data_in[1], p4, data_in[0], p2, p1};
  end
endmodule