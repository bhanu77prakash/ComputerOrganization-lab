`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:50:45 08/24/2017
// Design Name:   radix_4booth
// Module Name:   C:/Users/Shubham/radix4_booth/temp_test.v
// Project Name:  radix4_booth
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: radix_4booth
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg [7:0] mplier;
	reg [7:0] mpcand;
	reg go;
	reg clk;
	reg reset;

	// Outputs
	wire [15:0] prod;
	wire over;
	
	wire [1:0] check_state;
	// Instantiate the Unit Under Test (UUT)
	booth_radix4 uut (
		.mplier(mplier), 
		.mpcand(mpcand), 
		.go(go), 
		.clk(clk), 
		.prod(prod), 
		.over(over), 
		.reset(reset),
		.check_state(check_state)
	);

	initial begin
		// Initialize Inputs
		mplier = 5;
		mpcand = 3;
		go = 1;
		clk = 0;
		reset = 1;
		#10
		reset=0;
		// Wait 100 ns for global reset to finish
		#100;
			go=0;
		#20;
			mpcand=10;
		#100;
			go=1;
		#200;
			go=0;
		// Add stimulus here

	end
      always 
       #5  clk =  ! clk; 
endmodule

