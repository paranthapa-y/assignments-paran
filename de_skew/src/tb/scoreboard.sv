// -----------------------------------------------------------------------------
// File: scoreboard.sv
// Description: Scoreboard class for de-skew testbench. Compares DUT outputs with expected results.
// -----------------------------------------------------------------------------
class Scoreboard;
  
  mailbox mon2scb;
  
  function new(mailbox mon2scb);
    this.mon2scb =mon2scb;
  endfunction
  bit [7:0] e_stream;
  bit e_aligned;

  bit [3:0] fifo1 [3];
  bit [3:0] fifo2 [3];
  
  task run();
    Transaction tr;
    
    forever begin
      mon2scb.get(tr);

      fifo1[2] = fifo1[1];
      fifo1[1] = fifo1[0];
      fifo1[0] = tr.stream1;
      
      fifo2[2] = fifo2[1];
      fifo2[1] = fifo2[0];
      fifo2[0] = tr.stream2;

      e_stream = 0;
      e_aligned = 0;

      for( int i=0; i<3;i++) begin
	      for( int j = 0; j<3; j++) begin
		      if ((fifo1[i] == 4'hA) && (fifo2[j] == 4'hA))  begin
			      int skew=i-j;

			      if (skew<0) skew = -skew;
			      e_aligned = (skew<=2);
			      if (skew<=2) begin
				      if (i<=j)
					      e_stream = {fifo1[2], fifo2[2-skew]};
				      else if (j<i)
					      e_stream = {fifo2[2], fifo1[2-skew]};
				      else
					      e_stream = 8'h0;
			      end
		      end
	      end
      end

      e_stream = (tr.aligned)? e_stream : 8'h0;

      //tr.display("SCB");
      if (tr.aligned!= e_aligned) $display ("scoreboard error");
      if (tr.out_stream !== e_stream) $error("FAIL: s1 - %h, s2 - %h, %h expected, got %h", tr.stream1,tr.stream2,e_stream, tr.out_stream);;


      if (e_aligned) begin
	      if (tr.out_stream !== e_stream) begin
		      $error("FAIL %h expected, got %h", e_stream, tr.out_stream);
          
        end
	      else
		      tr.display("Passed");


      end
      end

  endtask
endclass

      
