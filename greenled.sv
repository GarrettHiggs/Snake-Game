module greenled (i_head, j_head, i, j, length, lightOn, clk, reset, sys, gameOver);
	input logic clk, reset, sys, gameOver;
	input logic [4:0] i_head, j_head, i, j;
	input logic [15:0] length;
	output logic lightOn;
	
	logic [15:0] count;
	
	enum {Off, On} ps, ns;
	
	always_comb begin
		case (ps)
			Off: if (i_head == i & j_head == j) ns = On;
				  else ns = Off;
			On:  if (count + 1 == length) ns = Off;
				  else ns = On;
		endcase
	end
	
	assign lightOn = ((ns == On) & gameOver == 0);
	
	always_ff @(posedge clk) begin
		if (reset) begin
			if ((i == 10 & j == 7) | (i==10 & j==6) | (i==10 & j==5)) ps <= On;
			else ps <= Off;
		end
		else
			if (sys)
				ps <= ns;
	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			if (i == 10 & j == 6) count <= 16'b0000000000000000;
			else if (i==10 & j==5) count <= 16'b0000000000000001;
			else count <= 16'b0000000000000000;
		end
		else if (sys & (ps == On))
			count <= count + 1;
		else if (sys & (ps == Off))
			count <= 16'b0000000000000000;
	end
	
endmodule

module greenled_testbench();
	logic clk, reset, lightOn, sys, gameOver;
	logic [4:0] i_head, j_head, i, j;
	logic [15:0] length;

	greenled dut (.gameOver, .sys, .i, .j, .i_head, .j_head, .length, .lightOn, .clk, .reset);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
																																											  @(posedge clk);
		reset <= 1; 		  													 											 											  @(posedge clk); // Always reset FSMs at start
		reset <= 0; length <= 16'b0000000000000011;  i <= 5'b01010; j <= 5'b00111; i_head <= 5'b01010; j_head <= 5'b00111; repeat(1)   @(posedge clk);
																	i <= 5'b01010; j <= 5'b00111; i_head <= 5'b01010; j_head <= 5'b01000; repeat(2)   @(posedge clk);
																	i <= 5'b01010; j <= 5'b00111; i_head <= 5'b01010; j_head <= 5'b00111; repeat(2)   @(posedge clk);
																	i <= 5'b01010; j <= 5'b00111; i_head <= 5'b01010; j_head <= 5'b00111; repeat(4)   @(posedge clk);
																	
		$stop; // End the simulation.
	end
endmodule
