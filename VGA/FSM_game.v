`timescale 1ns / 1ps

module FSM_game #( 
	parameter AW = 8, // Cantidad de bits  de la direccin 
	parameter DW = 3 // cantidad de Bits de los datos 
)(
	input clk,
	input rst,
	input clr, //Limpia pizarra
	input in1, //Botón right
	input in2, //Botón left
	input [DW-1:0] switch,
	
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

divisor_de_frecuencia #(75000000,7) GameClk(
	.clk(clk),
	.clk_out(gameclk)
);

always @ (posedge gameclk) begin
	if(in1) begin
		addr = count;
		count = count>=192 ? 0 : count+1;
		case(switch)
			0: data = 3'b000;
			1: data = 3'b001;
			2:	data = 3'b010;
			3:	data = 3'b011;
			4: data = 3'b100;
			5: data = 3'b101;
			6: data = 3'b110;
			7: data = 3'b111;
		endcase
		write=1;
	end else if(in2) begin
		count = count>=192 ? 0 : count+1;
	end else if(clr) begin
		addr = count;
		count = count>=192 ? 0 : count+1;
		data = 3'b111;
		write=1;
	end else
		write=0;
		
	if(rst) begin 
		count<=0;
		write<=0;
	end
end

endmodule
