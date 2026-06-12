// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

// Include YAPP UVC components (contains yapp_packet, agents, etc.)
`include "../sv/yapp.svh"


// Include sequence library (depends on sequences)
`include "yapp_seq_lib.sv"

// Include test (depends on sequence library)
`include "yapp_test_lib.sv"

module top;
  initial begin
    run_test();
  end
endmodule : top

