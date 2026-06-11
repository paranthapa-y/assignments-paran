/*-----------------------------------------------------------------
File name     : router_scoreboard.sv
Description   : Scoreboard for checking DUT output correctness against expected results
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

`uvm_analysis_imp_decl(_yapp)
`uvm_analysis_imp_decl(_channel0)
`uvm_analysis_imp_decl(_channel1)
`uvm_analysis_imp_decl(_channel2)
// Scoreboard for checking DUT output correctness against expected results
class router_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(router_scoreboard)

    yapp_packet yapp_q0[$], yapp_q1[$], yapp_q2[$];

    int packets_received;
    int matched_packets;
    int wrong_packets;

    uvm_analysis_imp_yapp #(yapp_packet, router_scoreboard) yapp_imp;
    uvm_analysis_imp_channel0 #(yapp_packet, router_scoreboard) ch0_imp;
    uvm_analysis_imp_channel1 #(yapp_packet, router_scoreboard) ch1_imp;
    uvm_analysis_imp_channel2 #(yapp_packet, router_scoreboard) ch2_imp;

    function new(string name = "router_scoreboard", uvm_component parent = null);
        super.new(name,parent);
        yapp_imp = new("yapp_imp",this);
        ch0_imp = new("ch0_imp", this);
        ch1_imp = new("ch1_imp",this);
        ch2_imp = new("ch2_imp",this);
    endfunction

    function void write_yapp(yapp_packet pkt);
        yapp_packet temp;
        `uvm_info("SB",
             $sformatf("YAPP packet addr=%0d",
                       pkt.addr),
             UVM_NONE)
        $cast(temp, pkt.clone());
        packets_received++;
        case(pkt.addr)

            2'b00:
                yapp_q0.push_back(temp);

            2'b01:
                yapp_q1.push_back(temp);

            2'b10:
                yapp_q2.push_back(temp);
        endcase        
    endfunction

    function void write_channel0(yapp_packet pkt);
        yapp_packet temp;
        // $cast(temp,pkt.clone());
        if(yapp_q0.size() == 0) begin
            `uvm_error("SB","Q0 EMPTY")
            return;
        end
        temp = yapp_q0.pop_front();
        if (temp.compare(pkt)) begin
            `uvm_info(get_full_name(), "q0 output matched", UVM_LOW);
            matched_packets++;
        end
        else begin
            `uvm_info(get_full_name(), "q0 output not - matched", UVM_LOW);
            wrong_packets++;
        end
    endfunction

    function void write_channel1(yapp_packet pkt);
        yapp_packet temp;
        // $cast(temp,pkt.clone());
        if(yapp_q1.size() == 0) begin
            `uvm_error("SB","Q1 EMPTY")
            return;
        end

        temp = yapp_q1.pop_front();
        if (temp.compare(pkt)) begin
            `uvm_info(get_full_name(), "q1 output matched", UVM_LOW);
            matched_packets++;
        end
        else begin
            `uvm_info(get_full_name(), "q1 output not - matched", UVM_LOW);
            wrong_packets++;
        end
    endfunction

    function void write_channel2(yapp_packet pkt);
        yapp_packet temp;
        // $cast(temp,pkt.clone());
        if(yapp_q2.size() == 0) begin
            `uvm_error("SB","Q2 EMPTY")
            return;
        end
        temp = yapp_q2.pop_front();
        if (temp.compare(pkt)) begin
            `uvm_info(get_full_name(), "q2 output matched", UVM_LOW);
            matched_packets++;
        end
        else begin
            `uvm_info(get_full_name(), "q2 output not - matched", UVM_LOW);
            wrong_packets++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        // `uvm_info(get_full_name(), "matched packet: %d, unmatched packets : %d",matched_packets, wrong_packets, UVM_LOW);
    endfunction

endclass