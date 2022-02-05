`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:46:19 11/04/2020
// Design Name: 
// Module Name:    test_VGA
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module test_VGA(
    input wire clk,           // board clock: 32 MHz quacho 100 MHz nexys4 
    input wire rst,         	// reset button

	// VGA input/output  
	 input wire [2:0] switch,
    output wire VGA_Hsync_n,  // horizontal sync output
    output wire VGA_Vsync_n,  // vertical sync output
    output wire VGA_R,	// 4-bit VGA red output
    output wire VGA_G,  // 4-bit VGA green output
    output wire VGA_B,  // 4-bit VGA blue output
    output wire clkout,  
 	
	// input/output
	
	
	input wire bntr,
	input wire bntl
		
);

// TAMAÑO DE visualización 
parameter CAM_SCREEN_X = 1024;
parameter CAM_SCREEN_Y = 768;

localparam AW = 8; // LOG2(CAM_SCREEN_X*CAM_SCREEN_Y)
localparam DW = 3; //Numero de bits RGB

// El color es RGB 111
localparam RED_VGA =   3'b100;
localparam GREEN_VGA = 3'b010;
localparam BLUE_VGA =  3'b001;


// Clk 
wire clk50M;

wire clk75M;

// Conexión dual por ram

wire  [AW-1: 0] DP_RAM_addr_in;  
wire  [DW-1: 0] DP_RAM_data_in;
wire DP_RAM_regW;

reg  [AW-1: 0] DP_RAM_addr_out;  
	
// Conexión VGA Driver
wire [DW-1:0]data_mem;	   // Salida de dp_ram al driver VGA
wire [DW-1:0]data_RGB111;  // salida del driver VGA al puerto
wire [11:0]VGA_posX;		   // Determinar la pos de memoria que viene del VGA
wire [11:0]VGA_posY;		   // Determinar la pos de memoria que viene del VGA


/* ****************************************************************************
la pantalla VGA es RGB 444, pero el almacenamiento en memoria se hace 332
por lo tanto, los bits menos significactivos deben ser cero
**************************************************************************** */
	assign VGA_R = data_RGB111[2];
	assign VGA_G = data_RGB111[1];
	assign VGA_B = data_RGB111[0];

assign clk50M=clk;

clock75 clk75(	
	.inclk0(clk50M),
	.c0(clk75M)
	
);

divisor_de_frecuencia(
	.clk(clk75M),
	.clk_out(clkout)
);

/* ****************************************************************************
buffer_ram_dp buffer memoria dual port y reloj de lectura y escritura separados
Se debe configurar AW  según los calculos realizados en el Wp01
se recomiendia dejar DW a 8, con el fin de optimizar recursos  y hacer RGB 111
**************************************************************************** */
buffer_ram_dp #( AW,DW,"C:/Users/diego/Documents/GitHub/wp01-2021-2-grupo03-2021-2/VGA/imagetxt.txt")
	DP_RAM(  
	.clk_w(clk75M), 
	.addr_in(DP_RAM_addr_in), 
	.data_in(DP_RAM_data_in),
	.regwrite(DP_RAM_regW), 
	
	.clk_r(clk75M), 
	.addr_out(DP_RAM_addr_out),
	.data_out(data_mem)
	);
	

/* ****************************************************************************
VGA_Driver640x480
**************************************************************************** */
VGA_Driver1024x768 VGA1024x768
(
	.rst(~rst),
	.clk(clk75M), 				// 25MHz  para 60 hz de 640x480
	.pixelIn(data_mem), 		// entrada del valor de color  pixel RGB 111 
//	.pixelIn(RED_VGA), 		// entrada del valor de color  pixel RGB 111 
	.pixelOut(data_RGB111), // salida del valor pixel a la VGA 
	.Hsync_n(VGA_Hsync_n),	// señal de sincronizaciÓn en horizontal negada
	.Vsync_n(VGA_Vsync_n),	// señal de sincronizaciÓn en vertical negada 
	.posX(VGA_posX), 			// posición en horizontal del pixel siguiente
	.posY(VGA_posY) 			// posición en vertical  del pixel siguiente

);

 
/* ****************************************************************************
LÓgica para actualizar el pixel acorde con la buffer de memoria y el pixel de 
VGA si la imagen de la camara es menor que el display  VGA, los pixeles 
adicionales seran iguales al color del último pixel de memoria 
**************************************************************************** */
reg [AW-1:0] countx;
reg [AW-1:0] county;

localparam px_scale = 64;
localparam width = CAM_SCREEN_X/px_scale;
localparam height = CAM_SCREEN_Y/px_scale;

always @ (VGA_posX, VGA_posY) begin
	
	if(VGA_posX % px_scale == px_scale-1) 
		countx = countx>=width ? 0 : countx + 1;
		
	if(VGA_posY % px_scale == px_scale-1) 
		county = county>=height ? 0 : county + 1;
	
	DP_RAM_addr_out = countx + county*width;
end
	
		
	/*if (countX >= width) begin
		countX = 0;
		if (countY >= height) begin
			countY = 0;
		end 
		else begin
			countY = (VGA_posY % px_scale == px_scale-1) ? countY : countY + 1;
		end
	end 
	else begin
		countX = (VGA_posX % px_scale == (px_scale-1)) ? countX : countX + 1;
	end*/
	
	/*case (switch)
		3'b000: DP_RAM_addr_out=3'b100;  
		3'b001: DP_RAM_addr_out=3'b010; 
		3'b010: DP_RAM_addr_out=3'b001; 
	endcase*/


endmodule
