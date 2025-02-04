module scoreCounter (clk, reset, length, score, eaten, gameOver);
	input logic clk, reset, eaten, gameOver;
	output logic [15:0] score, length;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			length <= 16'b0000000000000011;
			score <= 16'b0000000000000000;
		end
		else if (eaten & ~gameOver) begin
			length <= length + 1;
			score <= score + 1;
		end
	end
endmodule

module scoreCounter_testbench ();
	logic clk, reset, eaten, gameOver;
	logic [15:0] score, length;
	
	scoreCounter dut (.clk, .reset, .length, .score, .eaten, .gameOver);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
	
		reset <= 1; 		  																											   @(posedge clk);
		reset <= 0; eaten <= 0; gameOver <= 0;	repeat(4) @(posedge clk);
						eaten <= 1;						repeat(4) @(posedge clk);
									   gameOver <= 1; repeat(4) @(posedge clk);
						eaten <= 0;					   repeat(4) @(posedge clk);

		
		$stop;
	end
endmodule
