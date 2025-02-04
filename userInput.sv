module userInput (clk, reset, In, Out);
	input logic clk, reset, In;
	output logic Out;
	enum {A, B} ps, ns;
	
	logic i1, i2;
	D_FF d1 (.d(In), .q(i1), .clk, .reset);
	D_FF d2 (.d(i1), .q(i2), .clk, .reset);
	
	always_comb begin
		case (ps)
			A: if (i2) ns = B;
				else ns = A;
			B: if (i2) ns = B;
				else ns = A;
		endcase
	end
	
	always_comb begin
		if (ps == A && ns == B) Out = 1;
		else Out = 0;
	end
			
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= A;
		else
			ps <= ns;
	end
	
endmodule

module userInput_testbench();
	logic clk, reset;
	logic In, Out;

	userInput dut (.clk, .reset, .In, .Out);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
													@(posedge clk);
		reset <= 1; 		  					@(posedge clk); // Always reset FSMs at start
		reset <= 0; In <= 1; repeat(3)   @(posedge clk);
						In <= 0; repeat(3)   @(posedge clk);
						In <= 1; repeat(3)   @(posedge clk);
									repeat(2)   @(posedge clk);
		$stop; // End the simulation.
	end
endmodule
