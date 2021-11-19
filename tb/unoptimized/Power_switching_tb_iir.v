//`timescale 1ns

module tb_iir ();

   wire CLK_i;
   wire RST_n_i;
   wire [13:0] DIN_i;
   wire VIN_i;
   wire [13:0] H0_i;
   wire [13:0] H1_i;
   wire [13:0] H2_i;
   wire [13:0] H3_i;
   wire [13:0] H4_i;
   wire [13:0] DOUT_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUT(DIN_i),
		 .H0(H0_i),
		 .H1(H1_i),
		 .H2(H2_i),
		 .H3(H3_i),
		 .H4(H4_i),
		 .END_SIM(END_SIM_i));

   IIR_CA UUT(.CLK(CLK_i),
	     .RST_n(RST_n_i),
	     .DIN(DIN_i),
             .VIN(VIN_i),
	     .B0(H0_i),
	     .B1(H1_i),
	     .B2(H2_i),
	     .A1(H3_i),
	     .A2(H4_i),
             .DOUT(DOUT_i),
             .VOUT(VOUT_i));

   data_sink DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DIN(DOUT_i));   

   initial begin
	$read_lib_saif("./saif/NangateOpenCellLibrary.saif");
	$set_gate_level_monitoring("on");
	$set_toggle_region(UUT);
	$toggle_start;
   end   
   
   always @ ( END_SIM_i ) begin
	if (END_SIM_i) begin
		$toggle_stop;
		$toggle_report("./saif/IIR_back.saif", 1.0e-9, "tb_iir.UUT");
	end
   end
   
endmodule
