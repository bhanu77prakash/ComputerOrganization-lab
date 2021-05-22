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