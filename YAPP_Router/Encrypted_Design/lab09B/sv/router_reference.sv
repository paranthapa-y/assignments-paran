`uvm_analysis_imp_decl(_yappr)
`uvm_analysis_imp_decl(_hbusr)

class router_reference extends uvm_component;
    `uvm_component_utils(router_reference)

    uvm_analysis_port #(yapp_packet) yapp_prt;
    int dropped =0;

    uvm_analysis_imp_yappr #(yapp_packet, router_reference) yapp_imp;
    uvm_analysis_imp_hbusr #(hbus_transaction, router_reference) hbus_in_imp;

    bit [5:0] MAXPKTSIZE = 6'd63;
    bit ENABLE = 1'b1;

    function new( string name = "router_reference", uvm_component parent = null);
        super.new(name, parent);
        yapp_prt = new("yapp_prt", this);
        yapp_imp = new("yapp_imp", this);
        hbus_in_imp = new("hbus_in_imp", this);
    endfunction

    function void write_hbusr(hbus_transaction pkt);
        hbus_transaction temp = pkt;
        if (temp.haddr == 0) begin
            MAXPKTSIZE = pkt.hdata;
        end
        else if (temp.haddr == 1) begin
            ENABLE = pkt.hdata;
        end
    endfunction

    function void write_yappr(yapp_packet pkt);

        if (!ENABLE) begin
            dropped++;
            return;
        end

        if (pkt.length > MAXPKTSIZE) begin
            dropped++;
            return;
        end

        if (pkt.length == 0) begin
            dropped++;
            return;
        end

        if (pkt.addr == 2'b11) begin
            dropped++;
            return;
        end
        `uvm_info("REF",
  $sformatf("Forwarding packet addr=%0d",pkt.addr),
  UVM_LOW)
        yapp_prt.write(pkt);

    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_full_name(),
          $sformatf("Packet dropped : %0d", dropped),
          UVM_LOW)
    endfunction

endclass