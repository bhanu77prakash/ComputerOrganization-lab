`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Harsha Vattem, Bhanu Prakash Reddy
// 
// Create Date:    15:18:41 07/28/2017 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: This is the behavioural model.
//
//////////////////////////////////////////////////////////////////////////////////
module top;
	final_beh m1(in, clk, out,state);
	testBench m2(in, clk);
endmodule


module final_beh(in, clk, out,state);
	input in, clk;
	wire a,b;
	wire out;
	output out;
	output state;
	stateTransFn_beh m3(a,b, in, clk,state);
	outputFn_beh m4(a,b, clk, in, out);
endmodule

module stateTransFn_beh(a,b, in , clk,state);
	parameter S0=0, S1=1, S2=2, S3=3;
	reg[1:0] state = S0;
	input in ,clk;
	output a,b,state;
	assign a = state[0];
	assign b = state[1];
	always @(negedge clk)	
		case(state)
			S0:
				begin
					if (in)
						begin
						state <= S3;
						end
					else
						begin 
						state <= S1;
						end
				end
			S1:
				begin
					if (in)
						begin
						state <= S3;
						end
					else
						begin
						state <= S0;
						end
				end
			S2:
				begin
					if (in)
						begin
						state <= S3;
						end
					else
						begin
						state <= S1;
						end
				end
			S3:
				begin
					if (in)
					begin
						state <= S2;
						end
					else
						begin
						state <= S1;
						end
				end
			endcase
endmodule

module outputFn_beh(a,b, clk, in, out);
	input a,b,clk,in;
	output out;
	reg [1:0] state1;
	always @(a or b)
	begin 
	state1[1] <= b;
	state1[0] <= a;
	end
	reg out = 0;
	
	
	parameter S0=0, S1=1, S2=2, S3=3;
	always @(negedge clk)	
		case(state1)
			S0:
				begin
					if (in)
						begin
						out <= 0;
						end
					else
						begin 
						out <= 0;
						end
				end
			S1:
				begin
					if (in)
						begin
						out <= 1;
						end
					else
						begin
						out <= 0;
						end
				end
			S2:
				begin
					if (in)
						begin
						out <= 0;
						end
					else
						begin
						out <= 1;
						end
				end
			S3:
				begin
					if (in)
					begin
						out <= 0;
						end
					else
						begin
						out <= 0;
						end
				end
			endcase
endmodule

//module testBench(in, clk);
//	output clk, in;
//	reg in;
//	reg clk;
//	initial begin
//		// Initialize Inputs
//		in = 0;
//		clk = 0;
//
//		//TEST CASE: 01011101100
//		#10 clk = !clk;
//
//		in = 0;
//		#10 clk = !clk;
//		
//		in = 1;
//		#10 clk = !clk;
//		
//		in = 0;
//		#10 clk = !clk;
//		
//		in = 1;
//		#10 clk = !clk;
//		
//		in = 1;
//		#10 clk = !clk;
//		
//		in = 1;
//		#10 clk = !clk;
//		
//		in = 0;
//		#10 clk = !clk;
//		
//		in = 1;
//		#10 clk = !clk;
//		
//		in = 1;
//		#10 clk = !clk;
//		
//		in = 0;
//		#10 clk = !clk;
//		
//		in  = 0; 
//
//	end
//
//endmodule
//
//
//	

module testBench(in, clk);
	output clk, in;
	reg in;
	reg	clk;
	initial begin
		// Initialize Inputs
		in = 0;
		clk = 0;

		//TEST CASE: 01011101100
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		#1 in  = 0; 

	end

endmodule

