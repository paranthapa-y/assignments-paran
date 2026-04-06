// 2- port memory with only signle write enable port.
module ram(
  input  logic [3:0] addra,
  input  logic [3:0] addrb,
  input  logic       wea,
  input  logic       en,
  input  logic       rst,
  input  logic       clk,
  input  logic       dina,
  output logic       douta,
  output logic       doutb
);
  //logic addra,addrb,wea,en, clk,dina;
  //wire douta,doutb,rst;
  logic [1:0] count,count_r1,count_r2;
  localparam int W_LATENCY = 3;
  localparam int R_LATENCY = 2;
  
  logic [15:0] mem ;
  typedef enum logic [1:0] {W_IDLE, W_LAT, WRITE} WR_STATE_T;
  typedef enum logic [1:0] {IDLE, R_LAT, READ} RD_STATE_T;

  WR_STATE_T wr_state, wr_next_state;
  RD_STATE_T rd1_state, rd1_next_state, rd2_state, rd2_next_state;

  
  always_comb begin : FSM// write
    wr_next_state = wr_state;
    case (wr_state)
      W_IDLE : begin
        if (wea && en)
          wr_next_state = W_LAT;
      end
      W_LAT : begin
        if ( count == W_LATENCY)
            wr_next_state = WRITE;
      end
      WRITE : begin
        wr_next_state = W_IDLE;
        //mem[addra] = dina;
      end
    endcase        
  end
  
  always_comb begin : Porta// A read
    rd1_next_state = rd1_state;
    case (rd1_state)
      IDLE : begin
        if (!wea && en)
          rd1_next_state = R_LAT;
      end
      R_LAT : begin
        if ( count_r1 == R_LATENCY)
            rd1_next_state = READ;
      end
      READ : begin
        rd1_next_state = IDLE;
        //douta = mem[addra];
      end
    endcase        
  end
  
   always_comb begin : Portb //B read
    rd2_next_state = rd2_state;
    case (rd2_state)
      IDLE  : begin
        if (!wea && en)
          rd2_next_state = R_LAT;
      end
      R_LAT : begin
        if ( count_r2 == R_LATENCY)
            rd2_next_state = READ;
      end
      READ : begin
        rd2_next_state = IDLE;
        //doutb = mem[addrb];
      end
    endcase        
  end
  
  always_ff @( posedge clk) begin : write //always1
    

    
    if (rst) begin
     rd1_state <=IDLE;
     rd2_state <= IDLE;
     wr_state <= W_IDLE;
     count    <= 0;
     count_r1 <= 0;
     count_r2 <= 0;
    end
    else begin
      wr_state  <= wr_next_state;
      rd1_state <= rd1_next_state;
      rd2_state <= rd2_next_state;
    end
    if (wea) begin
      count_r1<=0;
      count_r2 <=0;
      rd1_state <=IDLE;
      rd2_state <= IDLE;
    end
    if (wr_state == W_IDLE) begin
        count <= 0;
    end
    if (rd1_state == IDLE) begin
        count_r1 <= 0;
    end
    if (rd2_state == IDLE) begin
        count_r2 <= 0;
    end
    if (wr_state == W_LAT && count < W_LATENCY) begin
        count <= count + 1;
    end
    if(rd1_state==R_LAT && count_r1 < R_LATENCY) begin
        count_r1 <= count_r1 + 1;
    end
    if(rd2_state==R_LAT && count_r2 < R_LATENCY) begin
        count_r2 <= count_r2 + 1;
    end
    if (wr_state == WRITE) begin
        mem[addra] <= dina;
    end
    if (rd1_state == READ) begin
        douta <= mem[addra];   
    end
    if (rd2_state == READ) begin
        doutb <= mem[addrb];
    end
  end
    
  
endmodule