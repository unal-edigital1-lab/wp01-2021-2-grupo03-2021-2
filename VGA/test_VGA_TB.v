`timescale 10ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   09:45:24 12/04/2019
// Design Name:   test_VGA
// Project Name:  test_VGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_VGA_TB;

	// Inputs
	reg clk;
	reg rst;
//   reg [2:0] R=3'b000;
//	reg [2:0] G=3'b000;
//	reg [1:0] B=2'b00;

	// Outputs
	wire VGA_Hsync_n;
	wire VGA_Vsync_n;

	wire VGA_R;
	wire VGA_G;
	wire VGA_B;
   wire bntr;
	wire bntl;
	wire clkout;

	// Instantiate the Unit Under Test (UUT)
	test_VGA uut (
		.clk(clk), 
		.rst(rst), 
		.VGA_Hsync_n(VGA_Hsync_n), 
		.VGA_Vsync_n(VGA_Vsync_n), 
		.VGA_R(VGA_R), 
		.VGA_G(VGA_G), 
		.VGA_B(VGA_B),
		.bntr(bntr),
		.bntl(bntr),
		.clkout(clkout)
	
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		#200;
		rst = 0;
	end

	always #2 clk  = ~clk;
	
	
	reg [9:0]line_cnt=0;
	reg [9:0]row_cnt=0;
	
	
	/*************************************************************************
			INICIO DE  GENERACION DE ARCHIVO test_vga	
	**************************************************************************/

	/* log para cargar de archivo*/
	integer f;
	initial begin
      f = $fopen("file_test_vga.txt","w");
   end
	
	reg clk_w =0;
	always #1 clk_w  = ~clk_w;

	initial forever begin
	@(posedge clk_w)
	
		
		$fwrite(f,"%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, {VGA_R,2'b00},{VGA_G,2'b00},{VGA_B,1'b0});
		$display("%0t ps: %b %b %b %b %b\n",$time,VGA_Hsync_n, VGA_Vsync_n, {VGA_R,2'b00},{VGA_G,2'b00},{VGA_B,1'b0});
		
	end
	
endmodule
