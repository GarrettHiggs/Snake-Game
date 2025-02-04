module clock_counter(clk, reset, out);
	input logic clk, reset;
	output logic out;
	logic [7:0] count;
	
	always_ff @(posedge clk) begin
		if (reset)
			count <= 8'b00000000;
		else
			count <= count + 1;
	end
	
	assign out = (count == 8'b11111111);
	
endmodule
			