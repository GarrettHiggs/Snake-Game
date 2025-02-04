module appleSpawner (clk, reset, GrnPixels, eaten, i_apple, j_apple);
	input logic clk, reset, eaten;
	input logic [15:0][15:0] GrnPixels;
	output logic [3:0] i_apple, j_apple;
	logic [3:0] i_rand, j_rand;
	logic [4:0] int_i;
	logic [5:0] int_j;
	
	lsfr5 l5 (clk, reset, int_i);
	lsfr6 l6 (clk, reset, int_j);
	assign i_rand = int_i % 16;
	assign j_rand = int_j % 16;
	
	always_ff @(posedge clk) begin
		if (reset) begin
			i_apple <= 4'b1010;
			j_apple <= 4'b1110;
		end
		else if (eaten) begin
			if (GrnPixels[i_rand][j_rand]) begin
				i_apple <= i_rand + 1;
				j_apple <= j_rand + 1;
			end 
			else begin
				i_apple <= i_rand;
				j_apple <= j_rand;
			end
		end
	end
endmodule

module appleSpawner_testbench ();
	logic clk, reset, eaten;
	logic [3:0] i_apple, j_apple;
	logic [15:0][15:0] GrnPixels;
	
	appleSpawner dut (.clk, .reset, .GrnPixels, .eaten, .i_apple, .j_apple);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		
		reset <= 1;														 				 repeat(1)   @(posedge clk);
		reset <= 0;	eaten <= 0; GrnPixels[00] = 16'b0000000000000000;
										GrnPixels[01] = 16'b0000000000000000;
										GrnPixels[02] = 16'b0000000000000000;
										GrnPixels[03] = 16'b0000000000000000;
										GrnPixels[04] = 16'b0000000000000000;
										GrnPixels[05] = 16'b0000000000000000;
										GrnPixels[06] = 16'b0000000000000000;
										GrnPixels[07] = 16'b0000000000000000;
										GrnPixels[08] = 16'b0000000000000000;
										GrnPixels[09] = 16'b0000000000000000;
										GrnPixels[10] = 16'b0000000010000000;
										GrnPixels[11] = 16'b0000000000000000;
										GrnPixels[12] = 16'b0000000000000000;
										GrnPixels[13] = 16'b0000000000000000;
										GrnPixels[14] = 16'b0000000000000000;
										GrnPixels[15] = 16'b0000000000000000;	 repeat(2)   @(posedge clk);
						eaten <= 1;											 			 repeat(1)   @(posedge clk);
						eaten <= 0;														 repeat(6)   @(posedge clk);
		
		$stop;
	end
	
endmodule
