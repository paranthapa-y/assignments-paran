//------------------------------------------------------------------------------
// File name   : yapp.svh
// Description : UVC include file for YAPP environment
//------------------------------------------------------------------------------
typedef uvm_config_db #(virtual yapp_if) yapp_if_config;
typedef uvm_config_db #(virtual yapp_if) yapp_vif_config;

`include "yapp_packet.sv"
`include "yapp_tx_monitor.sv"
`include "yapp_tx_sequencer.sv"
`include "yapp_tx_seqs.sv"  
`include "yapp_tx_driver.sv"
`include "yapp_tx_agent.sv"
`include "yapp_env.sv"
`include "yapp_seq_lib.sv"
// `include "router_scoreboard.sv"
// `include "yapp_if.sv"

