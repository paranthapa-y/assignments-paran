/*-----------------------------------------------------------------
File name     : yapp_pkg.sv
Description   : Package containing type definitions and macros for verification environment
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

package yapp_pkg;

  // import the UVM library
  import uvm_pkg::*;

  // include the UVM macros
  `include "uvm_macros.svh"

  // include the YAPP packet definition
  `include "yapp_packet.sv" 

endpackage : yapp_pkg
