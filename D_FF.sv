module D_FF (q, d, reset, clk);
	output logic q;
	input logic d, reset, clk;

	always_ff @(posedge clk) begin
		if (reset)
			q <= 0;
		else
			q <= d;
	end

endmodule
