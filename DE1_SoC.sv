// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;

	 // Turn off HEX displays
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
	 
	 
	 /* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	    ===========================================================*/
	 logic reset;                   // reset - toggle this on startup
	 
	 assign reset = SW[9];
	 logic SYSTEM_CLOCK;
	 
	 logic [31:0] div_clk;
	 parameter whichClk = 14; 
	 clock_divider cdiv (.clock(CLOCK_50), .divided_clocks(div_clk));
	
	// Detect when we're in Quartus and use the divided clock,
   // otherwise assume we're in ModelSim and use the fast clock
   `ifdef ALTERA_RESERVED_QIS
      assign SYSTEM_CLOCK = div_clk[whichClk]; // for board
   `else
		assign SYSTEM_CLOCK = CLOCK_50; // for simulation
   `endif
	 	 
	 /* If you notice flickering, set SYSTEM_CLOCK faster.
	    However, this may reduce the brightness of the LED board. */
	
	 
	 /* Set up LED board driver
	    ================================================================== */
	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	 
	 /* Standard LED Driver instantiation - set once and 'forget it'. 
	    See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	 LEDDriver Driver (.CLK(SYSTEM_CLOCK), .RST(reset), .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
	 
	 
	 /* LED board test submodule - paints the board with a static pattern.
	    Replace with your own code driving RedPixels and GrnPixels.
		 
	 	 KEY0      : Reset
		 =================================================================== */
	 // LED_test test (.RST(reset), .RedPixels, .GrnPixels);
	 logic Lin, Uin, Din, Rin;
	 logic Lout, Uout, Dout, Rout;
	 logic sys, eaten, gameOver;
	 logic [4:0] i_head, j_head;
	 logic [15:0] score, length;
	 logic [3:0] i_apple, j_apple;
	 
	 clock_counter sc (.clk(SYSTEM_CLOCK), .reset, .out(sys));
	 
	 userInput uL (.In(~KEY[3]), .Out(Lin), .clk(SYSTEM_CLOCK), .reset);
	 userInput uU (.In(~KEY[2]), .Out(Uin), .clk(SYSTEM_CLOCK), .reset);
	 userInput uD (.In(~KEY[1]), .Out(Din), .clk(SYSTEM_CLOCK), .reset);
	 userInput uR (.In(~KEY[0]), .Out(Rin), .clk(SYSTEM_CLOCK), .reset);
	 
	 snakeDir dir (.clk(SYSTEM_CLOCK), .reset, .Lin, .Uin, .Din, .Rin, .Lout, .Uout, .Dout, .Rout);
	 
	 snakehead head (.sys, .clk(SYSTEM_CLOCK), .reset, .i_head, .j_head, .L(Lout), .U(Uout), .D(Dout), .R(Rout), .eaten, .RedPixels, .gameOver, .GrnPixels);
	 
	 scoreDisplay sd (.HEX0, .HEX1, .HEX2, .score);
	 
	 scoreCounter sctr (.clk(SYSTEM_CLOCK), .reset, .length, .score, .eaten, .gameOver);
	 
	 appleSpawner as (.clk(SYSTEM_CLOCK), .reset, .GrnPixels, .eaten, .i_apple, .j_apple);
	 
	 logic [4:0] id [15:0];
	 logic [4:0] jd [15:0];
	 genvar i, j;
	 generate
		for (j = 0; j < 16; j++) begin : loadj
			assign jd[j] = j;
		end
		for (i = 0; i < 16; i++) begin : ledrows
			assign id[i] = i;
			for (j = 0; j < 16; j++) begin : ledcolumns
				greenled g (.gameOver, .sys, .i_head, .j_head, .i(id[i]), .j(jd[j]), .length, .lightOn(GrnPixels[i][j]), .clk(SYSTEM_CLOCK), .reset);	
				redled r (.gameOver, .sys, .i_head, .j_head, .i(id[i]), .j(jd[j]), .i_apple, .j_apple, .lightOn(RedPixels[i][j]), .clk(SYSTEM_CLOCK), .reset);
			end
		end
	 endgenerate
	 
endmodule

module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_1;

	DE1_SoC dut (.CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .GPIO_1);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end

	// Test the design.
	initial begin
																						  repeat(255) @(posedge CLOCK_50);
		SW[9] <= 1; 								  								  repeat(255) @(posedge CLOCK_50); // Always reset FSMs at start
		SW[9] <= 0; KEY[3] <= 1; KEY[2] = 1; KEY[1] = 1; KEY[0] <= 1; repeat(1785) @(posedge CLOCK_50);
      KEY[3] <= 1; KEY[2] = 0; KEY[1] = 1; KEY[0] <= 1; repeat(765) @(posedge CLOCK_50);
		KEY[3] <= 1; KEY[2] = 1; KEY[1] = 1; KEY[0] <= 0; repeat(765) @(posedge CLOCK_50);
		KEY[3] <= 0; KEY[2] = 1; KEY[1] = 1; KEY[0] <= 1; repeat(765) @(posedge CLOCK_50);
		KEY[3] <= 1; KEY[2] = 1; KEY[1] = 0; KEY[0] <= 1; repeat(765) @(posedge CLOCK_50);
		KEY[3] <= 1; KEY[2] = 1; KEY[1] = 1; KEY[0] <= 0; repeat(765) @(posedge CLOCK_50);
		
		$stop; // End the simulation.
	end 
endmodule 