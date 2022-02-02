//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date:    13:34:31 10/22/2019 
// Design Name: 	 Ferney alberto Beltran Molina
// Module Name:    VGA_Driver 
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
module VGA_Driver1024x768 (
	input rst,
	input clk, 				// 75MHz  para 60 hz de 1024x768
	input  [11:0] pixelIn, 	// entrada del valor de color  pixel 
	output  [11:0] pixelOut, // salida del valor pixel a la VGA 
	output  Hsync_n,		// seÃ±al de sincronizaciÃ³n en horizontal negada
	output  Vsync_n,		// seÃ±al de sincronizaciÃ³n en vertical negada 
	output  [11:0] posX, 	// posicion en horizontal del pixel siguiente
	output  [11:0] posY 		// posicion en vertical  del pixel siguiente
);

localparam SCREEN_X = 1024; 	// tamaño de la pantalla visible en horizontal 
localparam FRONT_PORCH_X =24;  
localparam SYNC_PULSE_X = 136;
localparam BACK_PORCH_X = 144;
localparam TOTAL_SCREEN_X = SCREEN_X+FRONT_PORCH_X+SYNC_PULSE_X+BACK_PORCH_X; 	// total pixel pantalla en horizontal 


localparam SCREEN_Y = 768s; 	// tamaño de la pantalla visible en Vertical 
localparam FRONT_PORCH_Y =3;  
localparam SYNC_PULSE_Y = 6;
localparam BACK_PORCH_Y = 29;
localparam TOTAL_SCREEN_Y = SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y+BACK_PORCH_Y; 	// total pixel pantalla en Vertical 


reg  [11:0] countX;
reg  [11:0] countY;

assign posX    = countX;
assign posY    = countY;

assign pixelOut = (countX<SCREEN_X) ? (pixelIn ) : (12'b000000000000) ;

assign Hsync_n = ~((countX>=SCREEN_X+FRONT_PORCH_X) && (countX<SCREEN_X+SYNC_PULSE_X+FRONT_PORCH_X)); 
assign Vsync_n = ~((countY>=SCREEN_Y+FRONT_PORCH_Y) && (countY<SCREEN_Y+FRONT_PORCH_Y+SYNC_PULSE_Y));


always @(posedge clk) begin
	if (rst) begin
		countX <= TOTAL_SCREEN_X- 10; /*para la simulación sea mas rapido*/
		countY <= TOTAL_SCREEN_Y-4;/*para la simulación sea mas rapido*/
	end
	else begin 
		if (countX >= (TOTAL_SCREEN_X)) begin
			countX <= 0;
			if (countY >= (TOTAL_SCREEN_Y)) begin
				countY <= 0;
			end 
			else begin
				countY <= countY + 1;
			end
		end 
		else begin
			countX <= countX + 1;
			countY <= countY;
		end
	end
end

endmodule
