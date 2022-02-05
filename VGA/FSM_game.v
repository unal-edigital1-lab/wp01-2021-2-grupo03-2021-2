`timescale 1ns / 1ps

module FSM_game #( 
	parameter AW = 8, // Cantidad de bits  de la direccin 
	parameter DW = 3 // cantidad de Bits de los datos 
)(
	input clk,
	input rst,
	input in1, //Botón right
	input in2, //Botón left
	
	output [AW-1:0] mem_px_addr,
	output [AW-1:0] mem_px_data,
	output px_wr
);

reg [20:0] count;
reg [AW:0] addr;
reg [AW:0] data;
reg write=0;

assign mem_px_addr = addr;
assign mem_px_data = data;
assign px_wr = write;

wire gameclk;

divisor_de_frecuencia #(50000000,100) GameClk(
	.clk(clk),
	.clk_out(gameclk)
);

always @ (posedge gameclk) begin
	if(in1) begin
		count = count+1;
		addr <= count;
		data <= 3'b111;
		write <= 1;
	end else if(in2) begin
		count = count+1;
		addr <= count;
		data <= 3'b000;
		write <= 1;
	end else
		write <=0;
end


endmodule
