//------------------------------------------------------------------------------
// File name   : top.sv
// Description : Top-level testbench for Lab 2 - UVC hierarchy check
//------------------------------------------------------------------------------

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

// Include all YAPP UVC components
`include "../sv/yapp.svh"
`include "yapp_test_lib.sv"

module top;
  // Run default test
  initial begin
    run_test();
  end
endmodule : top

