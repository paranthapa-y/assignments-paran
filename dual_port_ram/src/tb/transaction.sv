// -----------------------------------------------------------------------------
// File: transaction.sv
// Description: Transaction class for de-skew testbench. Defines stimulus and response data structures.
// -----------------------------------------------------------------------------

class Transaction  #(parameter int ADDR_WIDTH = 4, parameter int DATA_WIDTH = 4) ;
  
  // rand bit [3:0] stream1;
  // rand bit [3:0] stream2;
  
  // bit [7:0] out_stream;
  // bit aligned;
  // bit reset;
  randc logic [ADDR_WIDTH-1:0] addra;
  randc logic [ADDR_WIDTH-1:0] addrb;
  rand logic       wea;
  rand logic       en;
  rand logic       rst;
  rand logic [DATA_WIDTH-1:0] dina;
  logic [DATA_WIDTH-1:0] douta;
  logic [DATA_WIDTH-1:0] doutb;

  constraint write_e { soft wea dist {0:=90, 1:=10}; }
  constraint enable { en dist {1:=90, 0:=10}; }
  constraint reset_c { rst dist {0:=95, 1:=5}; }


  function void display(string tag="INFO");
    $display(
	    "[%s] addra=%h addrb=%h wea=%h en=%h rst=%h dina=%h douta=%h doutb=%h",
	    tag, addra, addrb, wea,en, rst, dina,douta, doutb);
  endfunction
endclass
  
