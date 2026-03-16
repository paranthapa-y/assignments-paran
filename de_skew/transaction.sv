
class Transaction;
  
  rand bit [3:0] stream1;
  rand bit [3:0] stream2;
  
  bit [7:0] out_stream;
  bit aligned;
  bit reset;
  
  function void display(string tag);
    $display(
	    "[%s] s1=%h s2=%h out=%h aligned=%0b reset=%0b",
	    tag, stream1, stream2, out_stream, aligned, reset);
  endfunction
endclass
  
