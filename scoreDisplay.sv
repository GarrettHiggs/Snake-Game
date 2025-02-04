module scoreDisplay (score, HEX0, HEX1, HEX2);
	input logic [15:0] score;
	output logic [6:0] HEX0, HEX1, HEX2;
	logic [3:0] digit2, digit1, digit0;
	
	always_comb begin
		// Extract hundreds place
      digit2 = (score / 100) % 10;  
      // Extract tens place
      digit1 = (score / 10) % 10;  
      // Extract ones place
      digit0 = score % 10;          
	end
	
	seg7 s2 (.bcd(digit2), .leds(HEX2));
	seg7 s1 (.bcd(digit1), .leds(HEX1));
	seg7 s0 (.bcd(digit0), .leds(HEX0));
	
endmodule

module scoreDisplay_testbench ();
	logic [15:0] score;
	logic [6:0] HEX0, HEX1, HEX2;
	
	scoreDisplay dut (.score, .HEX0, .HEX1, .HEX2);
	
	integer i;
	initial begin
		for(i = 0; i <256; i++) begin
			score = i; #10;
		end
	end
endmodule
	
	