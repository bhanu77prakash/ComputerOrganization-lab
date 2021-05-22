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
	wire [7:0] check,check1, check2;
	wire [4:0] state, n_state;
	wire [15:0] rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22;
	test_module test(clk, reset, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
	datapath data (clk,check,check1, check2, reset,tArray, lArray, readReg, writeReg, readMem, writeMem, dsel, fsel, instr , dcond, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
	controller beh(state,n_state, fsel, dsel, clk, reset, dcond,readReg,writeReg, readMem, writeMem, lArray, tArray, instr);
endmodule

module controller(state,n_state, fsel, dsel, clk, reset, dcond,readReg,writeReg, readMem, writeMem, lArray, tArray, instr);
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
							flag = 0;
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
						// This state sets the control signals for (MAR <= sp) instruction.
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
						//tArray = 16;
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

module test_module(clk, reset, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
	output  clk, reset;
	output [15:0] rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22;
	reg clk,reset;
	reg [15:0] rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22;
	//reg [15:0] instruction;
	integer t;
	//assign instr[15:0] = instruction[15:0];
	initial
		begin
			reset = 0;
			#5
			rom_mem0 = 16'b0000010000000000;
			rom_mem1 = 16'b0001000000000000;
			rom_mem20 = 16'b0000000000000100;
			rom_mem21 = 16'b0000000000000110;
			rom_mem22 = 16'b0000000000000001;
			rom_mem2 = 16'b0001010010000000;
			rom_mem3 = 16'b0000000010000000;
			rom_mem4 = 16'b0001000000000000;
			rom_mem5 = 16'b0000000000000000;
			rom_mem6 = 16'b0000010000000000;
			reset = 1;
			//sp_init = 42;
			#1 reset = 0;
			#1
			clk = 0;
			//#10 clk = ~clk;
			//rom_mem0 = 16'b0001001110000000;
			//dcond = 1;
			t = 0;
			while(t<1000)
			begin
				#1
				clk = ~clk;
				t = t+1;
			end
		end
endmodule


module datapath(clk,check,check1, check2, reset,tArray, lArray, readReg, writeReg, readMem, writeMem, dsel, fsel, instr , out, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
	input wire [10:0] tArray;
	output [7:0] check,check1, check2;
	input [3:0] dsel;
	input clk, reset;
	input [15:0] rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22;
	input wire [8:0] lArray;
	wire [15:0] XYBUS, Y;
	wire [15:0] ZBUS, DBUS, I_BUS, PADDING;
	input [2:0] fsel;
	wire zin, vin, cin, sin;
	output  out;
	input wire readReg, writeReg, readMem, writeMem;
	wire [15:0] mar_reg, pc_reg, sp_reg, t_reg, t2_reg, mdr_reg, MEMwritebus;
	wire [2:0] pa;
	wire zout, zout1, vout, vout1, cout, cout1, sout, sout1;
	output [15:0] instr;
	assign Y = t2_reg;
	assign PADDING[11:0] = instr[11:0];
	assign PADDING[12] = PADDING[11];
	assign PADDING[13] = PADDING[11];
	assign PADDING[14] = PADDING[11];
	assign PADDING[15] = PADDING[11];
	assign pa = instr[9:7];
	//assign check = ZBUS;
	//assign check1 = XYBUS;
	assign check2 = mdr_reg;
	reg_16 PC(ZBUS, clk, lArray[2], reset, pc_reg);
	reg_16_1 SP(ZBUS, clk, lArray[3], reset, sp_reg);
	reg_16 T(ZBUS, clk, lArray[1], reset, t_reg);
	reg_16 T2(XYBUS, clk, lArray[0], reset, t2_reg);
	reg_16 MAR(ZBUS, clk, lArray[5], reset, mar_reg);
	wire out_mem;
	or(out_mem, lArray[7], lArray[8]);
	reg_16 MDR(I_BUS, clk, out_mem, reset, mdr_reg);
	reg_16 IR(DBUS, clk, lArray[6], reset, instr);
	reg_bank BANK(ZBUS, check, check1, check2, clk, reset, XYBUS, pa, writeReg, readReg);
	reg [15:0] const2_1;
	wire [15:0] const2;
	initial
		begin
			const2_1 =2;
			//pc_reg = 0;
		end
	assign const2 = const2_1;
	tristate PC_tri(pc_reg, XYBUS, tArray[2]);
	tristate SP_tri(sp_reg, XYBUS, tArray[3]);
	tristate T_tri(t_reg, XYBUS, tArray[1]);
	tristate MDR_tri1(ZBUS, I_BUS, lArray[8]);
	tristate MDR_tri2(DBUS, I_BUS, lArray[7]);
	tristate MDR_tri_out1(mdr_reg, XYBUS, tArray[5]);
	tristate MDR_tri_out2(mdr_reg, MEMwritebus, tArray[4]);
	tristate IR_tri(PADDING, XYBUS, tArray[7]);
	tristate const2_tri(const2, XYBUS, tArray[0]);
	ALU alu(XYBUS, Y, check, ZBUS, fsel, cin, zin, vin, sin);
	//status_det status(ZBUS, ci, ci_1, clk ,reset, zout, zout1, vout, vout1, cout, cout1, sout, sout1);
	dflipflop zero(zin, zout, zout1, clk, reset);
	dflipflop carry(cin, cout, cout1, clk, reset);
	dflipflop over(vin, vout, vout1, clk, reset);
	dflipflop sign(sin, sout, sout1, clk, reset);
	selection select_1 (dsel, zout, zout1, cout, cout1, vout, vout1, sout, sout1, out);
	Memory memory(mar_reg,check, readMem, writeMem, clk, MEMwritebus, DBUS, reset, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
endmodule

module selection ( dsel, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out);
	input zin, zin1, cin, cin1, vin, vin1, sin, sin1;
	input [3:0] dsel;
	wire uncond;
	output out;
	assign uncond = 1;
	mux_921 select(uncond, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out);
endmodule

module mux_921(uncond, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out, dsel);
	input [3:0] dsel;
	input zin, zin1, cin, cin1, vin, vin1, sin, sin1, uncond;
	output reg out;
	always @*
		begin
			case (dsel)
				2:
					begin
						out = uncond;
					end
				3:
					begin
						out  = cin;
					end
				4:
					begin
						out = cin1;
					end
				5:
					begin
						out = zin;
					end
				6:
					begin
						out = zin1;
					end
				7:
					begin
						out = vin;
					end
				8:
					begin
						out = vin1;
					end
				9:
					begin
						out = sin;
					end
				10:
					begin
						out = sin1;
					end
			endcase
		end
endmodule

module reg_16(in, clk, ld, reset, out);
	input wire [15:0] in;
	input clk, ld, reset;
	output reg [15:0] out;
	always @(posedge clk or  posedge reset )
		begin
			if(reset)
				out = 16'b0;
			else
				begin
					if(ld)
						out = in;
					else
						out = out;
				end	
		end
endmodule

module reg_16_1(in, clk, ld, reset, out);
	input wire [15:0] in;
	input clk, ld, reset;
	output reg [15:0] out;
	always @(posedge clk or  posedge reset )
		begin
			if(reset)
				out = 16'b1111111111111000;
			else
				begin
					if(ld)
						out = in;
					else
						out = out;
				end	
		end
endmodule

module tristate(in, out, t);
	input wire[15:0] in;
	output [15:0] out;
	input t;
	/*always @(t)
		begin
			if(t)
				out = in;
			else
				out = 16'bz;
		end*/
	assign out[0]=(t) ? in[0] : 1'bZ;
	assign out[1]=(t) ? in[1] : 1'bZ;
	assign out[2]=(t) ? in[2] : 1'bZ;
	assign out[3]=(t) ? in[3] : 1'bZ;
	assign out[4]=(t) ? in[4] : 1'bZ;
	assign out[5]=(t) ? in[5] : 1'bZ;
	assign out[6]=(t) ? in[6] : 1'bZ;
	assign out[7]=(t) ? in[7] : 1'bZ;
	assign out[8]=(t) ? in[8] : 1'bZ;
	assign out[9]=(t) ? in[9] : 1'bZ;
	assign out[10]=(t) ? in[10] : 1'bZ;
	assign out[11]=(t) ? in[11] : 1'bZ;
	assign out[12]=(t) ? in[12] : 1'bZ;
	assign out[13]=(t) ? in[13] : 1'bZ;
	assign out[14]=(t) ? in[14] : 1'bZ;
	assign out[15]=(t) ? in[15] : 1'bZ;
endmodule


module reg_bank(in, check, check1, check2, clk, reset, out, wpa, wrr, read);
	wire [15:0] out_arr1,out_arr2,out_arr3,out_arr4,out_arr5,out_arr6,out_arr7,out_arr8,check,check1,check2;
	input [15:0] in;
	output [15:0] check, check1, check2;
	input clk, reset;
	wire [7:0] wr;
	input [2:0] wpa;
	input wrr, read;
	output [15:0] out;
	wire [15:0] out1;
	assign check1 = out_arr1;
	assign check = out_arr2;
	decoder3to8 write(wpa, wr, wrr);
	reg_16 r0(in, clk, wr[0], reset, out_arr1);
	reg_16 r1(in, clk, wr[1], reset, out_arr2);
	reg_16 r2(in, clk, wr[2], reset, out_arr3);
	reg_16 r3(in, clk, wr[3], reset, out_arr4);
	reg_16 r4(in, clk, wr[4], reset, out_arr5);
	reg_16 r5(in, clk, wr[5], reset, out_arr6);
	reg_16 r6(in, clk, wr[6], reset, out_arr7);
	reg_16 r7(in, clk, wr[7], reset, out_arr8);
	mux_821 read_mod(out1, wpa, read, out_arr1,out_arr2,out_arr3,out_arr4,out_arr5,out_arr6, out_arr7, out_arr8);
	tristate gate(out1, out, read);
endmodule


module decoder3to8(wpa, wr, wrr);
	input [2:0] wpa;
	output reg[7:0] wr;
	input wrr;
	always @(wpa or wrr)
		begin
			wr = 0;
			if(wrr)
			begin
				case(wpa)
					3'b000:wr = 1;
					3'b001:wr = 2;
					3'b010:wr = 4;
					3'b011:wr = 8;
					3'b100:wr = 16;
					3'b101:wr = 32;
					3'b110:wr = 64;
					3'b111:wr = 128;
				endcase
			end
			else
				wr=0;
		end
endmodule


module mux_821(out, sel, read,reg0,reg1, reg2,reg3,reg4,reg5,reg6,reg7);
	input [15:0] reg0,reg1, reg2,reg3,reg4,reg5,reg6,reg7;
	input read;
	input [2:0] sel;
	output reg [15:0] out;
	//assign out1 = out; 
	always @(read or sel or reg0 or reg1 or reg2 or reg3 or reg4 or reg5 or reg6 or reg7)
		begin
			//out = out;
			if(read)
				begin
					case(sel)
						3'b000:out = reg0;
						3'b001:out = reg1;
						3'b010:out = reg2;
						3'b011:out = reg3;
						3'b100:out = reg4;
						3'b101:out = reg5;
						3'b110:out = reg6;
						3'b111:out = reg7;
					endcase
				end
			else
				out = out;
		end
endmodule

module Memory(address,check, read, write, clk, in_data, out_data, reset, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
	input [15:0] address, in_data, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22;
	input read, write, clk, reset;
	output reg [15:0] out_data;
	reg[7:0] memory[65535:0];
	output [7:0] check;
	//assign check = out_data[7:0];
	always @(negedge clk or posedge reset)
		begin
			if(reset)
				begin
					memory[0]=rom_mem0[15:8];
					memory[1]=rom_mem0[7:0];
					memory[2]=rom_mem1[15:8];
					memory[3]=rom_mem1[7:0];
					memory[4]=rom_mem2[15:8];
					memory[5]=rom_mem2[7:0];
					memory[6]=rom_mem3[15:8];
					memory[7]=rom_mem3[7:0];
					memory[8]=rom_mem4[15:8];
					memory[9]=rom_mem4[7:0];
					memory[10]=rom_mem5[15:8];
					memory[11]=rom_mem5[7:0];
					memory[12]=rom_mem6[15:8];
					memory[13]=rom_mem6[7:0];
					memory[14]=rom_mem7[15:8];
					memory[15]=rom_mem7[7:0];
					memory[16]=rom_mem8[15:8];
					memory[17]=rom_mem8[7:0];
					memory[18]=rom_mem9[15:8];
					memory[19]=rom_mem9[7:0];
					memory[20]=rom_mem10[15:8];
					memory[21]=rom_mem10[7:0];
					memory[22]=rom_mem11[15:8];
					memory[23]=rom_mem11[7:0];
					memory[24]=rom_mem12[15:8];
					memory[25]=rom_mem12[7:0];
					memory[26]=rom_mem13[15:8];
					memory[27]=rom_mem13[7:0];
					memory[28]=rom_mem14[15:8];
					memory[29]=rom_mem14[7:0];
					memory[30]=rom_mem15[15:8];
					memory[31]=rom_mem15[7:0];
					memory[32]=rom_mem16[15:8];
					memory[33]=rom_mem16[7:0];
					memory[34]=rom_mem17[15:8];
					memory[35]=rom_mem17[7:0];
					memory[36]=rom_mem18[15:8];
					memory[37]=rom_mem18[7:0];
					memory[38]=rom_mem19[15:8];
					memory[39]=rom_mem19[7:0];
					memory[65532] = rom_mem20[15:8];
					memory[65533] = rom_mem20[7:0];
					memory[65530] = rom_mem21[15:8];
					memory[65531] = rom_mem21[7:0];
					memory[65528] = rom_mem22[15:8];
					memory[65529] = rom_mem22[7:0];
				end
			if(read)
				begin
					out_data = {memory[address],memory[{address[15:1],1'b1}]};
					
				end
			if(write)
				begin
					memory[address] = in_data[15:8];
					memory[{address[15:1],1'b1}] = in_data[7:0];
					$display("memory[%h]=%h%h",address,memory[address],memory[{address[15:1],1'b1}]);
				end
		end
endmodule

module ALU(XYBUS, Y, check, ZBUS, fsel, cin, zin, vin, sin);
	input [15:0] XYBUS, Y;
	input [2:0] fsel;
	output [15:0]check;
	output reg [15:0] ZBUS;
	//assign check = Y;
	output cin, zin, vin, sin;
	reg  ci, ci_1;
	reg [16:0] temp;
	reg [15:0] temp1;
	assign cin = ci;
	wire cin_1;
	assign cin_1 = ci_1;
	assign sin = ZBUS[15];
	//wire zout, zout1, vout, vout1, cout, cout1, sout, sout1;
	always @*
		begin
			case (fsel)
				3'b001: 
							begin
							temp = XYBUS + Y;
							temp1 = XYBUS[14:0] + Y[14:0];
							ci_1 = temp1[15];
							ZBUS  = XYBUS+Y;
							ci = temp[16];
							end
				3'b010: 
							begin
							ZBUS = XYBUS - Y;
							end
				3'b011: 
							begin
							ZBUS = (Y^16'b1111111111111111) + 1;
							ci = 0;
							end
				3'b100: 
							begin
							ZBUS = ~Y;
							ci = 0;
							end
				3'b101: 
							begin
							ZBUS = XYBUS|Y;
							ci = 0;
							end
				3'b110: 
							begin
							ZBUS = XYBUS;
							end
				3'b111:
							begin
							ZBUS = Y;
							end
			endcase
		end
	//status_det status(ZBUS, ci, ci_1, clk ,reset, vin ,zin);
	nor zero_det(zin,ZBUS[0],ZBUS[1],ZBUS[2],ZBUS[3],ZBUS[4],ZBUS[5],ZBUS[6],ZBUS[7],ZBUS[8],ZBUS[9],ZBUS[10],ZBUS[11],ZBUS[12],ZBUS[13],ZBUS[14],ZBUS[15]); 
	xor over_flow(vin, cin, cin_1);
endmodule


//module status_det(ZBUS, ci, ci_1, clk, reset, vin, zin);
//	input ci, ci_1, clk, reset;
//	input [15:0] ZBUS;
//	output wire zin, vin;
//	//output zout, zout1, cout, cout1, vout, vout1,sout, sout1; 
//	nor zero_det(zin,ZBUS[0],ZBUS[1],ZBUS[2],ZBUS[3],ZBUS[4],ZBUS[5],ZBUS[6],ZBUS[7],ZBUS[8],ZBUS[9],ZBUS[10],ZBUS[11],ZBUS[12],ZBUS[13],ZBUS[14],ZBUS[15]);
//	xor over_flow(vin, ci, ci_1);
//	
//endmodule


module dflipflop ( in, qout, qout1, clk, reset);
	output reg qout, qout1;
	input in;
	input clk, reset;
	always @(posedge clk or posedge reset)
		begin
			if(reset)
				begin
					qout=0;
					qout1 = 1;
				end
			else
				begin
					qout= in;
					qout1 = ~in;
				end
		end
endmodule
