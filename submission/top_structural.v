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