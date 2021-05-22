module top();
	wire [15:0] instr;
	wire dcond, regWrite, memWrite;
	wire [5:0] mux_arr;
	wire [2:0] fsel_arr;
	wire [3:0] dsel;
	controller c(instr, dcond, regWrite, memWrite, mux_arr, fsel_arr, dsel);
	test t(instr, dcond);
endmodule

module controller(instr, dcond, regWrite, memWrite, mux_arr, fsel_arr, dsel);
	input [15:0] instr;
	wire [16:0] type_instr;
	output [5:0] mux_arr;
	output [2:0] fsel_arr; // fsel[2] = alu of sp, fsel[1:0] = alu for add, sub;
	output [3:0] dsel;
	wire t1,t2,t3,t4,t5, stack, branch, call, ret, alu;
	input dcond;
	output regWrite, memWrite;
	assign dsel = instr[15:12];
	nor Stack(stack, instr[15],instr[14],instr[13],instr[12]);
	and (type_instr[0], stack, ~instr[10]); // type_instr[0] = push;
	and (type_instr[1] ,stack, instr[10]); // type_instr[1] = pop;
	nor Alu(alu, instr[15], instr[14], instr[13], ~instr[12]);
	or RegWrite(regWrite, type_instr[1], alu);
	or MemWrite(memWrite, call, type_instr[0]); //happens only in push and call operations.
	or Alu1(fsel_arr[2], type_instr[0], call); // sp = sp-1 only in push and call operations.
	and T1(t1, ~instr[15], instr[14]);
	and T2(t2, instr[15], ~instr[14], ~instr[13]);
	and T3(t3, ~instr[14], instr[13], ~instr[12]);
	and T4(t4, ~instr[15], ~instr[14], instr[13]);
	or Branch(branch, t1,t2,t3,t4);
	and Call(call, instr[15], ~instr[14], instr[13], instr[12]);
	and Return(ret, instr[15], instr[14], ~instr[13], ~instr[12]);
	and F0(f0, branch, dcond);
	or Mux1(mux_arr[0], call, ret, f0);
	assign mux_arr[1] = mux_arr[0];
	assign mux_arr[2] = mux_arr[0];
	assign mux_arr[3] = type_instr[0];
	or MUX5(mux_arr[4], type_instr[1], ret);
	assign mux_arr[5] = type_instr[0];
	or bandc(t5, branch, call);
	and ALU_1(fsel_arr[1], ~t5, instr[11]);
	and ALU_0(fsel_arr[0], ~t5, instr[10]);
	always @(*)
		begin
			$display("regWrite - %b, memWrite - %b, mux_arr - %b, fsel_arr - %b, dsel - %b, f0- %b", regWrite, memWrite, mux_arr, fsel_arr, dsel, f0);
		end
endmodule

module test(instr, dcond);
	output [15:0] instr;
	output dcond;
	reg [15:0] instruc;
	assign instr = instruc;
	assign dcond = 0;
	initial
	begin
		instruc = 16'b1100100000000000;
	end
endmodule
