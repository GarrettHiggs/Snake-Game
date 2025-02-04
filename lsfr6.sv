module lsfr6 (clk, reset, num);
	input logic clk, reset;
	output logic [5:0] num;
	logic [5:0] num2;
	
	D_FF d0 (.clk, .reset, .d(num2[5] ~^ num2[4]), .q(num2[0]));
	D_FF d1 (.clk, .reset, .d(num2[0]), .q(num2[1]));
	D_FF d2 (.clk, .reset, .d(num2[1]), .q(num2[2]));
	D_FF d3 (.clk, .reset, .d(num2[2]), .q(num2[3]));
	D_FF d4 (.clk, .reset, .d(num2[3]), .q(num2[4]));
	D_FF d5 (.clk, .reset, .d(num2[4]), .q(num2[5]));
	
	assign num = num2;

	
endmodule

module lsfr6_testbench();
	logic clk, reset;
	logic [5:0] num;
	
	lsfr6 dut (.clk, .reset, .num);
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin																				 
										  @(posedge clk);
		reset <= 1; 		  		  @(posedge clk); 
		reset <= 0; repeat(100)   @(posedge clk);
		$stop;
	end
endmodule
	