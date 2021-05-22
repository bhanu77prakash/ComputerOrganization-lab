`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Harsha Vattem, Bhanu Prakash Reddy
// 
// Create Date:    16:03:33 07/27/2017 
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
// Additional Comments: This is the structural model.
//
//////////////////////////////////////////////////////////////////////////////////
module top;
	wire z;
	wire x;
	wire clk;
	wire reset;
	assign  reset = 0;
	
	fsm_beh m1 (reset,x, clk, z);
	testBench m2 (x,clk);
endmodule

module fsm_beh(reset, x, clk, z);
	reg y1=0,y0=0;
	wire a,b;
	input clk, x, reset;
	wire t1,t2,t3,t4;
	output z;
	wire z;
	stateTransFn_beh2 m3 (a, b, x,t1,t2,t3,t4);
	outputFn_beh m4(t1,t2,b,a,x,z);
	delayElem_beh m5(reset, clk, t4,a,b,x);
endmodule 

module stateTransFn_beh(a,b,x,t1,t2,t3,t4);
	input a, b, x, t1, t2;
	output t3,t4;
	xor(t3, x, b);
	or (t4, t3,!a);
endmodule

module outputFn_beh(t1,t2, b,a, x, z);
	input  b, a,x;
	output t2, t1,z;
	wire z;
	
	and ag2(t1, a, !b, x);
	and ag1(t2, !x, b, !a);
	or og2(z, t2, t1);
endmodule

module delayElem_beh(reset, clk,t4,a,b,x);
	input clk,t4,x, reset;
	output a,b;
	wire Q0, Q1, Q0bar, Q1bar,D0,D1;
	wire reset;
	assign D1 = x;
	assign D0 = t4;
	DFF1 m7(D1, clk, reset,b, Q1, Q1bar);
	DFF0 m8(D0, clk, reset,a, Q0, Q0bar);
endmodule

module DFF1(D1, clk, reset, b, Q1, Q1bar);
	input D1, clk, reset;
	output reg Q1 = 0;
	output Q1bar,b;
	assign Q1bar = ~Q1;
	
	assign b = Q1;
	always @(posedge clk or posedge reset)
	begin
		if(reset)
			Q1 <= 0;
		else
			Q1 <= D1;
	end
endmodule

module DFF0(D0, clk, reset,a, Q0, Q0bar);
	input D0, clk, reset;
	output reg Q0 = 0;
	output Q0bar,a;
	assign a = Q0;
	assign Q0bar = ~Q0;
	always @(posedge clk or posedge reset)
	begin
		if(reset)
			Q0 <= 0;
		else
			Q0 <= D0;
	end
endmodule

module testBench(x, clk);
	output clk, x;
	reg x;
	reg	clk;
	initial begin
		// Initialize Inputs
		x = 0;
		clk = 0;

		//TEST CASE: 01011101100
		#10 clk = !clk;
		#10 clk = !clk;
		x = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 1;
		#10 clk = !clk;
		#10 clk = !clk;
		x = 0;
		#10 clk = !clk;
		#10 clk = !clk;
		x  = 0; 

	end

endmodule

