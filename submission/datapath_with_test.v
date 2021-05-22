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
