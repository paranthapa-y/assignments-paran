class Scoreboard;

  mailbox mon2scb;
  Transaction tr;

  // ----------------------------
  // Reference model signals
  // ----------------------------
  logic [2:0] c;
  logic [2:0][3:0] fifo1, fifo2;
  logic [7:0] out_stream;

  typedef enum logic [1:0] {
    IDLE    = 2'b00,
    FIND    = 2'b01,
    ALIGNED = 2'b10
  } state_t;

  state_t state, next_state;
  logic [1:0] LSB_ind;

  // ----------------------------
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;

    c = 0;
    fifo1 = '{default:0};
    fifo2 = '{default:0};
    state = IDLE;
    next_state = IDLE;
    LSB_ind = 0;
    out_stream = 0;
  endfunction

  // ----------------------------
  task run();

  // MOVE DECLARATIONS HERE
  logic [7:0] expected_stream;
  logic expected_aligned;

  forever begin
    mon2scb.get(tr);

    // ----------------------------
    // ALWAYS_COMB
    // ----------------------------
    next_state = state;
    out_stream = 0;

    case(state)

      IDLE: begin
        if ((tr.stream1 == 4'hA) && (tr.stream2 == 4'hA)) begin
          next_state = ALIGNED;
        end
        else if (tr.stream1 == 4'hA) begin
          next_state = FIND;
        end
        else if (tr.stream2 == 4'hA) begin
          next_state = FIND;
        end
      end

      FIND: begin
        if ((tr.stream1 == 4'hA) && (c < 2) && LSB_ind == 2'b10)
          next_state = ALIGNED;

        if ((tr.stream2 == 4'hA) && (c < 2) && LSB_ind == 2'b01)
          next_state = ALIGNED;
      end

      ALIGNED: begin
        next_state = state;

        if (LSB_ind == 2'b10)
          out_stream = {fifo1[2], fifo2[2-c]};
        else
          out_stream = {fifo2[2], fifo1[2-c]};
      end

    endcase

    // ----------------------------
    // SEQUENTIAL (same as DUT)
    // ----------------------------
    if (tr.reset) begin
      state   = IDLE;
      c       = 0;
      LSB_ind = 0;
      fifo1   = '{default:0};
      fifo2   = '{default:0};
    end
    else if (c > 2 && state == FIND) begin
      state   = IDLE;
      c       = 0;
      LSB_ind = 0;
      fifo1   = '{default:0};
      fifo2   = '{default:0};
    end
    else begin
      state = next_state;

      fifo1 = {tr.stream1, fifo1[2:1]};
      fifo2 = {tr.stream2, fifo2[2:1]};
    end

    if (state == FIND)
      c = c + 1;

    if (state == IDLE) begin
      c = 0;

      if (tr.stream1 == 4'hA && tr.stream2 == 4'hA)
        LSB_ind = 2'b01;
      else if (tr.stream2 == 4'hA)
        LSB_ind = 2'b10;
      else if (tr.stream1 == 4'hA)
        LSB_ind = 2'b01;
    end

    // ----------------------------
    // EXPECTED
    // ----------------------------
    expected_stream  = (state == ALIGNED) ? out_stream : 0;
    expected_aligned = (state == ALIGNED);

    // ----------------------------
    // COMPARE
    // ----------------------------
    if ((expected_stream !== tr.out_stream) ||
        (expected_aligned !== tr.aligned)) begin

      $display(" MISMATCH");
      $display("State=%0d c=%0d LSB=%0b", state, c, LSB_ind);
      $display("Expected: stream=%0h aligned=%0b",
                expected_stream, expected_aligned);
      $display("Got     : stream=%0h aligned=%0b",
                tr.out_stream, tr.aligned);
    end
    else begin
      $display(" MATCH: %0h", expected_stream);
    end

  end
endtask

endclass