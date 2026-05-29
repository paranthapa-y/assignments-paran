/*class base_test extends uvm_test;

  `uvm_component_utils(base_test)

  router_tb route;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    route = router_tb::type_id::create("route", this);
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  virtual function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction : check_phase

  virtual task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 200ns);
  endtask : run_phase

endclass : base_test


class simple_test extends base_test;

  `uvm_component_utils(simple_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Override YAPP packet with short_yapp_packet
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // YAPP UVC default sequence
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_012_seq::type_id::get());

uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                        "default_sequence", channel_rx_resp_seq::type_id::get());

uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                        "default_sequence", channel_rx_resp_seq::type_id::get());

uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                        "default_sequence", channel_rx_resp_seq::type_id::get());

  endfunction : build_phase

endclass : simple_test

*/

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  router_tb route;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    route = router_tb::type_id::create("route", this);
    //  uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
    //  yapp_pkg::yapp_5_packets::type_id::get());
  endfunction : build_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  virtual function void check_phase(uvm_phase phase);
    check_config_usage();
  endfunction : check_phase

  /*virtual task run_phase(uvm_phase phase);
    phase.phase_done.set_drain_time(this, 10000ns);
  endtask : run_phase*/

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Starting base_test run_phase");

    // Let the simulation run for some time so default sequences can execute
    // (Or you can wait for some event, e.g., end-of-packets)
    #100000ns;











    phase.drop_objection(this, "Ending base_test run_phase");
  endtask : run_phase

endclass : base_test


class simple_test extends base_test;
  `uvm_component_utils(simple_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  /* virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Override YAPP packet with short_yapp_packet (fully qualified)
    set_type_override_by_type(yapp_pkt_pkg::yapp_packet::get_type(),
                              yapp_pkt_pkg::short_yapp_packet::get_type());

    // YAPP UVC default sequence (fully qualified)
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_pkg::yapp_012_seq::type_id::get());

    // Channel UVC default sequences (fully qualified)
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

  endfunction : build_phase*/
  virtual function void build_phase(uvm_phase phase);
    // Override YAPP packet with short_yapp_packet (by type)
    //  set_type_override_by_type(yapp_pkt_pkg::yapp_packet::get_type(),
    // yapp_pkt_pkg::short_yapp_packet::get_type());
    // yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
    super.build_phase(phase);



    // YAPP UVC default sequence
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_pkg::yapp_012_seq::type_id::get());

    // Channel UVC default sequences
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // uvm_factory::get().print();



  endfunction

endclass : simple_test

//------------------------------------------------------------------------------
// test_uvc_integration
// Purpose: Demonstrates integration of HBUS + YAPP UVCs
//   - HBUS UVC programs router (MAXPKTSIZE=20, enable=1)
//   - YAPP UVC runs the all-channel sequence (1..22 payloads, 20% bad parity)
//------------------------------------------------------------------------------
class test_uvc_integration extends base_test;
  `uvm_component_utils(test_uvc_integration)

  function new(string name = "test_uvc_integration", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);


    // Channel UVC default sequences (for responses)
    uvm_config_wrapper::set(this, "route.channel_env0.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env1.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "route.channel_env2.rx_agent.sequencer.run_phase",
                            "default_sequence", channel_pkg::channel_rx_resp_seq::type_id::get());

    // HBUS first (program router)
    uvm_config_wrapper::set(this, "route.hbus.masters[0].sequencer.run_phase", "default_sequence",
                            hbus_pkg::hbus_small_packet_seq::type_id::get());

    // THEN YAPP stimulus
    uvm_config_wrapper::set(this, "route.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_all_ch_incr_payload_seq::type_id::get());

  endfunction : build_phase

endclass : test_uvc_integration
