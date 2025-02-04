module snakehead (clk, reset, i_head, j_head, L, U, D, R, eaten, RedPixels, sys, gameOver, GrnPixels);
	input logic clk, reset, sys;
	input logic L, U, D, R;
	input logic [15:0][15:0] RedPixels, GrnPixels;
	output logic [4:0] i_head, j_head;
	output logic eaten, gameOver;
	
	//enum {On, Off} ps, ns;
	enum {Ld, Ud, Dd, Rd, O} ps, ns;
	
	always_comb begin
		case (ps)
			Ld: if (D) ns = Dd;
				else if (U) ns = Ud;
				else if (j_head + 1 > 5'b01111 | GrnPixels[i_head][j_head + 1]) ns = O;
				else ns = Ld;
			Ud: if (R) ns = Rd;
				else if (L) ns = Ld;
				else if (i_head - 1 > 5'b01111 | GrnPixels[i_head - 1][j_head]) ns = O;
				else ns = Ud;
			Dd: if (R) ns = Rd;
				else if (L) ns = Ld;
				else if (i_head + 1 > 5'b01111 | GrnPixels[i_head + 1][j_head]) ns = O;
				else ns = Dd;
			Rd: if (D) ns = Dd;
				else if (U) ns = Ud;
				else if (j_head - 1 > 5'b01111 | GrnPixels[i_head][j_head - 1]) ns = O;
				else ns = Rd;
			O: ns = O;
		endcase
	end
	
//	always_comb begin
//		if(eaten)
//			eaten = 0;
//		else 
//			eaten = (ps != O & RedPixels[i_head][j_head]);
//	end
	
	assign gameOver = (ps == O);
	
	//assign newEaten = (ps != O & RedPixels[i_head][j_head] & ~eaten);
	enum {E, N} ps1, ns1;
	
	always_comb begin
		case (ps1)
			N: if (ps != O & RedPixels[i_head][j_head]) ns1 = E;
				else ns1 = N;
			E: if (sys) ns1 = N;
				else if (ps != O & RedPixels[i_head][j_head]) ns1 = E;
				else ns1 = N;
		endcase
	end
	
	assign eaten = (ps1 == N & ns1 == E);
//	always_comb begin
//		if ((i_head > 5'b01111) | (j_head > 5'b01111))
//			gameOver = 1;
//		else begin
//			gameOver = ;
//		end
//		if (gameOver) eaten = 0;
//		else
//			eaten = RedPixels[i_head][j_head];
//			//eaten = (L & RedPixels[i_head][j_head + 1]) | (U & RedPixels[i_head - 1][j_head]) | (D & RedPixels[i_head+1][j_head]) | (R & RedPixels[i_head][j_head - 1]);
//	end
//	
//	always_comb begin
//		if ((i_head > 5'b01111) | (j_head > 5'b01111))
//			gameOver = 1;
//		else begin
//			gameOver = GrnPixels[i_head][j_head];
//		end
//		if (!gameOver)
//			eaten = RedPixels[i_head][j_head];
//		else eaten = 0;
//	end
	
	always_ff @(posedge clk) begin
		if (reset) begin
			i_head <= 5'b01010;
			j_head <= 5'b00111;
			ps <= Ld;
			ps1 <= N;
		end
		ps1 <= ns1;
		if (sys) begin
			ps <= ns;
			case (ps)
				Ld: begin
					i_head <= i_head;
					j_head <= j_head + 1;
				end
				Ud: begin
					i_head <= i_head - 1;
					j_head <= j_head;
				end
				Dd: begin
					i_head <= i_head + 1;
					j_head <= j_head;
				end
				Rd: begin
					i_head <= i_head;
					j_head <= j_head - 1;
				end
				O: begin
					i_head <= i_head;
					j_head <= j_head;
				end
			endcase
		end
	end
endmodule

module snakehead_testbench();
	logic clk, reset, sys;
	logic L, U, D, R;
	logic [4:0] i_head, j_head;
	logic [15:0][15:0] RedPixels, GrnPixels;
	logic eaten, gameOver;
	

	snakehead dut (.GrnPixels, .gameOver, .clk, .reset, .L, .U, .D, .R, .i_head, .j_head, .RedPixels, .eaten, .sys);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
																																	  @(posedge clk);
		reset <= 1; 		  															 							  			  @(posedge clk); // Always reset FSMs at start
		reset <= 0; sys <= 1; i_head <= 5'b01010; j_head <= 5'b00111; L <= 1; U <= 0; D <= 0; R <= 0;
						GrnPixels[00] = 16'b0000000000000000;
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
						GrnPixels[15] = 16'b0000000000000000;												repeat(3)   @(posedge clk);
						i_head <= 5'b01010; j_head <= 5'b01000; L <= 0; U <= 1; D <= 0; R <= 0; repeat(3)   @(posedge clk);
						i_head <= 5'b01010; j_head <= 5'b00111; L <= 0; U <= 0; D <= 1; R <= 0; repeat(3)   @(posedge clk);
						i_head <= 5'b01010; j_head <= 5'b00111; L <= 0; U <= 0; D <= 0; R <= 1; repeat(3)   @(posedge clk);
						i_head <= 5'b01010; j_head <= 5'b00111; L <= 0; U <= 0; D <= 0; R <= 0; repeat(1)   @(posedge clk);
						i_head <= 5'b01010; j_head <= 5'b00111; L <= 1; U <= 0; D <= 0; R <= 0; repeat(1)   @(posedge clk);
						RedPixels[00] = 16'b0000000000000000;
						RedPixels[01] = 16'b0000000000000000;
						RedPixels[02] = 16'b0000000000000000;
						RedPixels[03] = 16'b0000000000000000;
						RedPixels[04] = 16'b0000000000000000;
						RedPixels[05] = 16'b0000000000000000;
						RedPixels[06] = 16'b0000000000000000;
						RedPixels[07] = 16'b0000000000000000;
						RedPixels[08] = 16'b0000000000000000;
						RedPixels[09] = 16'b0000000000000000;
						RedPixels[10] = 16'b0000001000000000;
						RedPixels[11] = 16'b0000000000000000;
						RedPixels[12] = 16'b0000000000000000;
						RedPixels[13] = 16'b0000000000000000;
						RedPixels[14] = 16'b0000000000000000;
						RedPixels[15] = 16'b0000000000000000; 												repeat(6)   @(posedge clk);
						i_head <= 5'b01010; j_head <= 5'b00111; L <= 0; U <= 0; D <= 0; R <= 1; repeat(3)   @(posedge clk);
						i_head <= 5'b01110; j_head <= 5'b00111; L <= 0; U <= 0; D <= 1; R <= 0; repeat(6)   @(posedge clk);
																													  repeat(2)   @(posedge clk);
		$stop; // End the simulation.
	end
endmodule

