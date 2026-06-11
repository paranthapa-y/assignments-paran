/*-----------------------------------------------------------------
File name     : router_module_env.sv
Description   : UVM environment router_module_env composing agents, scoreboards, and reference model
Notes         :
-------------------------------------------------------------------
-----------------------------------------------------------------*/

class router_module_env extends uvm_env;
    `uvm_component_utils(router_module_env)
    router_reference refer;
    router_scoreboard sb;
    uvm_analysis_export #(yapp_packet)      yapp_export;
    uvm_analysis_export #(hbus_transaction) hbus_export;

    uvm_analysis_export #(yapp_packet) ch0_export;
    uvm_analysis_export #(yapp_packet) ch1_export;
    uvm_analysis_export #(yapp_packet) ch2_export;

    function new(string name = "router_module_env", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        refer = router_reference::type_id::create("ref", this);
        sb = router_scoreboard::type_id::create("sb", this);
        yapp_export = new("yapp_export", this);
        hbus_export = new("hbus_export", this);

        ch0_export = new("ch0_export", this);
        ch1_export = new("ch1_export", this);
        ch2_export = new("ch2_export", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        refer.yapp_prt.connect(sb.yapp_imp);
        yapp_export.connect(refer.yapp_imp);
        hbus_export.connect(refer.hbus_in_imp);

        ch0_export.connect(sb.ch0_imp);
        ch1_export.connect(sb.ch1_imp);
        ch2_export.connect(sb.ch2_imp);
    endfunction
endclass