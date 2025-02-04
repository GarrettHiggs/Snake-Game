module redled (gameOver, sys, i_head, j_head, i, j, i_apple, j_apple, lightOn, clk, reset);
	input logic clk, reset, sys, gameOver;
	input logic [4:0] i_head, j_head, i, j;
	input logic [3:0] i_apple, j_apple;
	output logic lightOn;
	
	enum {Off, On} ps, ns;
	
	always_comb begin
		case (ps)
			Off: if (i == i_apple & j == j_apple) ns = On;
				  else ns = Off;
			On:  if (i_head == i & j_head == j) ns = Off;
				  else ns = On;
		endcase
	end
	
	assign lightOn = ((ps == On) & gameOver == 0);
	
	always_ff @(posedge clk) begin
		if (reset) begin
			if (i == i_apple & j == j_apple)
				ps <= On;
			else
				ps <= Off;
		end
		else
			if (sys) ps <= ns;
	end
	
endmodule

module redled_testbench ();
	logic clk, reset, sys, gameOver;
	logic [4:0] i_head, j_head, i, j;
	logic [3:0] i_apple, j_apple;
	logic lightOn;
	
	redled dut (.gameOver, .sys, .i_head, .j_head, .i, .j, .i_apple, .j_apple, .lightOn, .clk, .reset);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		
																																																	   @(posedge clk);
		reset <= 1; 		  																																									   @(posedge clk);
		reset <= 0; sys <= 1; i <= 5'b01010; j <= 5'b01110; i_head <= 5'b01010; j_head <= 5'b00111; i_apple <= 5'b01010; j_apple <= 5'b01110; repeat(2) @(posedge clk);
									 i <= 5'b01010; j <= 5'b01110; i_head <= 5'b01010; j_head <= 5'b01110; i_apple <= 5'b01010; j_apple <= 5'b01110; repeat(2) @(posedge clk);
									 i <= 5'b01010; j <= 5'b01110; i_head <= 5'b01010; j_head <= 5'b00111; i_apple <= 5'b01010; j_apple <= 5'b01110; repeat(2) @(posedge clk);
									 i <= 5'b01010; j <= 5'b01000; i_head <= 5'b01010; j_head <= 5'b00111; i_apple <= 5'b01110; j_apple <= 5'b01110; repeat(2) @(posedge clk);
	

		$stop;
	end
	
endmodule
