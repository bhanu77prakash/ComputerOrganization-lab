`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:28:56 11/10/2017 
// Design Name: 
// Module Name:    datapath 
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
module datapath(clk, reset);
	input clk, reset;
	wire [11:0] label;
	assign label = instr[11:0];
	reg_16 PC(pc_in, clk, ld_always, reset, pc_out);
	reg_16 SP(sp_in, clk, ld_always, reset, sp_out);
	reg_bank REGISTER_BANK(regbank_in, check, check1, check2, clk, reset, regbank_out, wpa, wrr);
	
	data_Memory memory(mar_reg,check, readMem, writeMem, clk, MEMwritebus, DBUS, reset, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
endmodule


module alu1(a,c);
	input [15:0] a;
	output reg [15:0] c;
	always @(*)
		begin
			c = a+2;
		end
endmodule

module alu2(a,c,fsel);
	input [15:0] a;
	input fsel;
	always @(*)
		begin
			case (fsel)
				1: begin
						c = a-2;
					end
				0: begin
						c = a+2;
					end
			endcase
		end
endmodule

module mux2to1(in1,in2,out, fsel);
	input [15:0] in1, in2;
	input fsel;
	output [15:0] out;
	always @(*)
		begin
			case (fsel)
				0:	begin
						out = in1;
					end
				1:	begin
						out = in2;
					end
			endcase
		end
endmodule

module padding (in, out);
	input [11:0] in;
	output [15:0] out;
	assign out[11:0] = in[11:0];
	assign out[12] = in[11];
	assign out[13] = in[11];
	assign out[14] = in[11];
	assign out[15] = in[11];
endmodule

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

module reg_bank(in, check, check1, check2, clk, reset, out, wpa, wrr);
	wire [15:0] out_arr1,out_arr2,out_arr3,out_arr4,out_arr5,out_arr6,out_arr7,out_arr8,check,check1,check2;
	input [15:0] in;
	output [15:0] check, check1, check2;
	input clk, reset;
	wire [7:0] wr;
	input [2:0] wpa;
	input wrr;
	wire read;
	assign read = 1;
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
	tristate gate(out1, out,read);
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

module selection ( dsel, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out);
	input zin, zin1, cin, cin1, vin, vin1, sin, sin1;
	input [3:0] dsel;
	wire uncond;
	output out;
	assign uncond = 1;
	mux_921 select(uncond, zin, zin1, cin, cin1, vin, vin1, sin, sin1, out);
endmodule

module data_Memory(address,check, write, clk, in_data, out_data, reset, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22);
	input [15:0] address, in_data, rom_mem0,rom_mem1,rom_mem2,rom_mem3,rom_mem4,rom_mem5,rom_mem6,rom_mem7,rom_mem8,rom_mem9, rom_mem10, rom_mem11,rom_mem12,rom_mem13,rom_mem14,rom_mem15,rom_mem16,rom_mem17,rom_mem18,rom_mem19, rom_mem20, rom_mem21, rom_mem22;
	input  write, clk, reset;
	output [15:0] out_data;
	reg[7:0] memory[65535:0];
	output [7:0] check;
	//assign check = out_data[7:0];
	assign out_data = {memory[address],memory[{address[15:1],1'b1}]};
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

