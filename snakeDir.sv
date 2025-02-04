module snakeDir (clk, reset, Lin, Uin, Din, Rin, Lout, Uout, Dout, Rout);
	input logic clk, reset, Lin, Uin, Din, Rin;
	output logic Lout, Uout, Dout, Rout;
	enum {L, U, D, R} ps, ns;
	
	always_comb begin
		case (ps)
			L: if (Din & ~(Lin | Uin | Rin)) ns = D;
				else if (Uin & ~(Din | Lin | Rin)) ns = U;
				else ns = L;
			U: if (Rin & ~(Din | Uin | Lin)) ns = R;
				else if (Lin & ~(Din | Uin | Rin)) ns = L;
				else ns = U;
			D: if (Rin & ~(Din | Uin | Lin)) ns = R;
				else if (Lin & ~(Din | Uin | Rin)) ns = L;
				else ns = D;
			R: if (Din & ~(Lin | Uin | Rin)) ns = D;
				else if (Uin & ~(Din | Lin | Rin)) ns = U;
				else ns = R;
		endcase
	end
	
	always_comb begin
		Lout = (ps == L);
		Uout = (ps == U);
		Dout = (ps == D);
		Rout = (ps == R);
	end
			
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= L;
		else
			ps <= ns;
	end
	
endmodule

module snakeDir_testbench();
	logic clk, reset;
	logic Lin, Uin, Din, Rin, Lout, Uout, Dout, Rout;

	snakeDir dut (.clk, .reset, .Lin, .Uin, .Din, .Rin, .Lout, .Uout, .Dout, .Rout);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
																							 @(posedge clk);
		reset <= 1; 		  															 @(posedge clk); // Always reset FSMs at start
		reset <= 0; Lin <= 1; Uin <= 1; Din <= 1; Rin <= 1; repeat(2)   @(posedge clk);
						Lin <= 1; Uin <= 0; Din <= 0; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 0; Din <= 0; Rin <= 1; repeat(2)   @(posedge clk);
						Lin <= 1; Uin <= 0; Din <= 0; Rin <= 1; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 1; Din <= 0; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 1; Din <= 1; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 0; Din <= 1; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 0; Din <= 0; Rin <= 1; repeat(2)   @(posedge clk);
						Lin <= 1; Uin <= 0; Din <= 0; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 0; Din <= 1; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 1; Din <= 0; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 1; Uin <= 0; Din <= 0; Rin <= 0; repeat(2)   @(posedge clk);
						Lin <= 0; Uin <= 0; Din <= 0; Rin <= 0; repeat(2)   @(posedge clk);
																			 repeat(2)   @(posedge clk);
		$stop; // End the simulation.
	end
endmodule
