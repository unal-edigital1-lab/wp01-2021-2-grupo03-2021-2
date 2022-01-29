module divisor_de_frecuencia(
	//Entradas
	input clk,
	
	//Salidas
	output reg clk_out
);

localparam f_0 = 75000000; //Frecuencia del clk de entrada
localparam f_out = 1; //Frecuencia de salida deseada
localparam max = f_0/(2*f_out); //Máximo valor del contador
reg [25:0] count; //Contador

initial begin
	count=0;
	clk_out=0;
end

always @(posedge clk) begin
	if(count==max)begin
		clk_out=~clk_out;
		count=0;
	end else begin
		count=count+1;
	end
end
endmodule