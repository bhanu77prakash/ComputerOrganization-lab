`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:41:52 10/20/2017 
// Design Name: 
// Module Name:    behavior 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top;
	 
	//assign instr = instruction;
	wire [15:0] instr;
	wire [2:0] fsel;
	wire [3:0] dsel;
	wire readReg, writeReg, readMem, writeMem;
	wire [8:0] lArray;
	wire [10:0] tArray;
	wire clk;
	wire reset;
	wire dcond;
	wire [4:0] state, n_state;
	test_module test(instr, clk, reset, dcond);
	behavior beh(state,n_state, fsel, dsel, clk, reset, dcond,readReg,writeReg, readMem, writeMem, lArray, tArray, instr);
endmodule

module behavior(state,n_state, fsel, dsel, clk, reset, dcond,readReg,writeReg, readMem, writeMem, lArray, tArray, instr);
	input clk, reset, dcond;
	input [15:0] instr;
	//reg [15:0] instruction;
	//output [15:0] instr;
	output reg [2:0] fsel;
	output reg [4:0] state;
	output reg [4:0] n_state;
	//reg [3:0] opcode;
	//reg [1:0] ALU_instr;
	//reg [2:0] reg_no;
	//reg [11:0] label;
	//output opcode, ALU_instr,reg_no, label;
	output reg readReg, writeReg, readMem, writeMem;
	output reg [8:0] lArray;
	output reg [10:0] tArray;
	output reg [3:0] dsel;
	integer flag = 0;
	always @(posedge clk)
	begin
		state = n_state;
	end
	always @(state or reset)
		begin
		lArray = 0;
		tArray = 0;
		readReg = 0;
		readMem = 0;
		writeMem = 0;
		writeReg = 0;
		fsel = 0;
		dsel = 0;
		if(reset == 1)
			state = 0;
		else
		begin
			case (state)
				5'b00000: 
					begin
					// start state (making all values to start values)
						lArray = 9'b000000000;
						tArray = 11'b00000000000;
						n_state = 5'b00001;
						readReg = 0;
						readMem = 0;
						writeMem = 0;
						writeReg = 0;
						fsel = 0;
						dsel = 0;
					end
				1:
					begin
						// This state sets the control signals for (MAR <= PC) instruction
						lArray = 9'b000100000;
						tArray = 11'b00000000100;
						fsel = 6;
						n_state = 2;
						if(flag == 0)
							flag = 1;
						else
							n_state = 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				2:
					begin
						// This state sets the control signals for (IR <= M[MAR]) instruction
						// Here it is directly represented but after data path implementation,
						// it is decomposed to 
						// A-bus <= MAR, rd<=1
						// wait until MFC
						// IR <= D-bus
						tArray = 11'b00001000000;
						readMem = 1;
						lArray = 9'b001000000;
						n_state = 3;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				3:
					begin
						// This state sets the control signals for (T2 <= #2) instruction.
						tArray = 11'b00000000001;
						lArray = 9'b000000001;
						n_state = 4;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				4:
					begin
						// This state sets the control signals for (PC <= PC + T2) instruction.
						tArray = 11'b00000000100;
						fsel = 1;
						lArray = 9'b000000100;
						n_state = 5;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				5:
					begin
						// This is a branching state.
						// Goes to different state based on IR[15:12] i.e opcode.
						if(instr[15:10] ==6'b000000)
							begin
								// Push instruction
								n_state = 6;
							end
						else if(instr[15:10] == 6'b000001)
							begin
								//Pop instruction.
								n_state = 9;
							end
						else if(instr[15:12] == 4'b0001)
							begin
								//ALU instructions.
								n_state = 9;
							end
						else if(instr[15:12] == 4'b1100)
							begin
								//Return instruction.
								n_state = 9;
							end
						else if(instr[15:12] == 4'b1011)
							begin
								//Call instruction.
								n_state = 7;
							end
						else
							begin
								//Branch instruction.
								n_state = 8;
							end
					end
				6:
					begin
						// This state sets the control signals for (MDR <= rm) instruction.
						readReg = 1;
						lArray = 9'b100000000;
						fsel = 6;
						n_state = 14;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				7:
					begin
						// This state sets the control signals for (MDR <= PC) instruction.
						tArray = 4;
						lArray = 256;
						fsel = 6;
						n_state = 14;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				8:
					begin
						if(instr[15:12] == 4'b0010 || instr[15:12] == 4'b0011 || instr[15:12] == 4'b0100 || instr[15:12] == 4'b0101 || instr[15:12] == 4'b0110 || instr[15:12] == 4'b0111 || instr[15:12] == 4'b1000 || instr[15:12] == 4'b1001 || instr[15:12] == 4'b1010)
							begin
								// handling different brach instructions
								dsel = instr[15:12];
								$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
								if(dcond == 1)//if condition flag == 1 then pc <= pc+label else pc<=pc+2.
									n_state = 18;
								else
									n_state = 1;
							end
						else
							begin
								n_state = 1;
							end
					end
				9:
					begin
						// This state sets the control signals for (sp <= MAR) instruction.
						tArray = 8;
						lArray = 32;
						fsel = 6;
						n_state = 10;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				10:
					begin
						// This state sets the control signals for (MDR <= M[MAR]) instruction.
						readMem = 1;
						lArray = 128;
						n_state = 11;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				11:
					begin
						// This state sets the control signals for (T2 <= #2) instruction.
						tArray = 1;
						lArray = 1;
						n_state = 12;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				12:
					begin
						// This state sets the control signals for (sp <= sp + T2) instruction.
						tArray = 8;
						lArray = 8;
						fsel = 1;
						n_state = 13;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				13:
					begin
						// Conditional check for different ALU and stack operations
						tArray = 32; // These two lines sets the control signals for (T2 <= MDR) instruction. This is a common instruction for all.
						lArray = 1;
						if(instr[13:10] == 4'b0001)
							n_state = 20;
						else if(instr[13:10] == 4'b0011)
							n_state = 21;
						else if(instr[13:10] == 4'b0100)
							n_state = 22;
						else if(instr[13:10] == 4'b0101)
							n_state = 24;
						else if(instr[13:10] == 4'b0110)
							n_state = 25;
						else if(instr[13:10] == 4'b0111)
							n_state = 27;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				14:
					begin
						// This state sets the control signals for (T2 <= #2) instruction.
						tArray = 1;
						lArray = 1;
						n_state = 15;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				15:
					begin
						// This state sets the control signals for (sp <= sp - T2) instruction.
						fsel = 2;
						tArray = 8;
						lArray = 8;
						n_state = 16;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				16:
					begin
						// This state sets the control signals for (MAR <= sp) instruction.
						lArray = 32;
						tArray = 8;
						fsel = 6;
						n_state = 17;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				17:
					begin
						// This state sets the control signals for (M[MAR] <= MDR) instruction.
						tArray = 16;
						writeMem = 1;
						//lArray = 16;
						if(instr[15:12] == 4'b0000)//check condition for whether to do pc<= pc+label or pc <= pc+1
							n_state = 1;
						else
							n_state = 18;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				18:
					begin
						// This state sets the control signals for ( T2 <= PC) instruction.
						tArray = 4;
						lArray = 1;
						n_state = 19;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				19:
					begin
						// This state sets the control signals for (PC <= T2+IR[11:0]) instruction.
						tArray = 64;
						fsel = 1;
						lArray = 4;
						n_state = 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				20:
					begin
						// pop operation.
						// This state sets the control signals for ( rm <= T2) instruction.
						fsel = 7;
						writeReg = 1;
						n_state= 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				21:
					begin
						// Push operation. 
						// This state sets the control signals for (PC <= T2) instruction.
						lArray = 4;
						//n_state = //;
						fsel = 7;
						n_state= 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				22:
					begin
						// This state sets the control signals for (T <= rm) instruction.
						readReg = 1;
						lArray = 2;
						fsel = 6;
						n_state = 23;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				23:
					begin
						// Addition operation.
						// This state sets the control signals for (rm <= T + T2) instruction.
						tArray = 2;
						fsel = 1;
						writeReg = 1;
						n_state= 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				24:
					begin
						// Negation operation.
						// This state sets the control signals for (rm <= -T2) instruction.
						fsel = 3;
						writeReg = 1;
						n_state= 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				25:
					begin
						// This state sets the control signals for ( T <= rm) instruction.
						readReg = 1;
						lArray = 2;
						fsel = 6;
						n_state = 26;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				26:
					begin
						// OR operaiton.
						// This state sets the control signals for (rm <= T|T2) instruction.
						tArray = 2;
						fsel = 5;
						writeReg = 1;
						n_state= 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
				27:
					begin
						// NOT operation.
						// This state sets the control signals for ( rm <= !T2) instruction.
						fsel = 4;
						writeReg = 1;
						n_state= 1;
						$display("state - %d , fnsel - %b , dsel - %b , load - %b , transmit - %b , writeReg - %b , readReg - %b , writeMem - %b , readMem - %b " , state,fsel,dsel,lArray,tArray,writeReg,readReg,writeMem,readMem);
					end
			endcase
		end
		end
endmodule

module test_module(instr, clk, reset, dcond);
	output  clk, reset,dcond;
	output [15:0] instr;
	reg clk,reset,dcond;
	reg [15:0] instr;
	reg [15:0] instruction;
	integer t;
	//assign instr[15:0] = instruction[15:0];
	initial
		begin
			reset = 0;
			#1 
			reset = 1;
			
			#1 reset = 0;
			#10
			clk = 0;
			//#10 clk = ~clk;
			instr = 16'b0001001110000000;
			dcond = 1;
			t = 0;
			while(t<60)
			begin
				#10
				clk = ~clk;
				t = t+1;
			end
		end
endmodule
