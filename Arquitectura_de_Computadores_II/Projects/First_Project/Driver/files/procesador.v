`timescale 1ns / 1ps
module procesador(
	input rst,
	input clk,
	input clk_f,
	input [31:0] dataMem,
	output [31:0] prueba,
	output [31:0] memAddress,
	output [31:0] memDataInput,
	output readEn,
	output writeEn
);


//OUTPUTS fetchStage
	wire [47:0] inst_out_fe, pc_out_fecthStage;
	
	//OUTPUTS IFIDreg
	wire [47:0] pc1_out_ifid_reg;
	wire [31:0] immediate_out_ifid_reg;
	wire [5:0] opcode_out_ifid_reg;
	wire [4:0] rd_out_ifid_reg, rt_out_ifid_reg, rs_out_ifid_reg;
	wire [3:0] flagsALU_out_ifid_reg;
	wire [2:0] flagsMEM_out_ifid_reg;
	wire [1:0] flagsWB_out_ifid_reg;
	wire flagsDECO_out_ifid_reg;
	
	//OUTPUTS decoStage
	wire [47:0] pc1_out_decoStage;
	wire [31:0] immediate_out_decoStage, dataOne_out_decoStage, dataTwo_out_decoStage;
	wire [5:0] opcode_out_decoStage;
	wire [4:0] rd_out_decoStage;
	wire [3:0] flagsALU_out_decoStage;
	wire [2:0] flagsMEM_out_decoStage;
	wire [1:0] flagsWB_out_decoStage;

	//OUTPUTS IDEXreg
	wire [47:0] pc1_out_idex_reg;
	wire [31:0] immediate_out_idex_reg, dataOne_out_idex_reg, dataTwo_out_idex_reg;
	wire [5:0] opcode_out_idex_reg;
	wire [4:0] rd_out_idex_reg;
	wire [3:0] flagsALU_out_idex_reg;
   wire [2:0] flagsMEM_out_idex_reg;
   wire [1:0] flagsWB_out_idex_reg;
	
	//OUTPUTS ExeStage
	wire [47:0] pc1_out_exeStage, immediate_out_exeStage, datainput_out_exeStage, result_out_exeStage;
	wire [5:0] opcode_out_exeStage;
	wire [4:0] rd_out_exeStage;
	wire [2:0] flagsMEM_out_exeStage;
	wire [1:0] flagsWB_out_exeStage;

	//OUTPUTS EXMEMreg
	wire [47:0] pc1_out_exmem_reg, immediate_out_exmem_reg, result_out_exmem_reg, datainput_out_exmem_reg;
	wire [5:0] opcode_out_exmem_reg;
	wire [4:0] rd_out_exmem_reg;
	wire [2:0] flagsMEM_out_exmem_reg;
	wire [1:0] flagsWB_out_exmem_reg;

	//OUTPUTS memStage
	wire [31:0] mem_data_memStage, direction_memStage;
	wire [4:0] rd_out_memStage;
	wire [1:0] flagsWB_out_memStage;
	
	//OUTPUTS MEMWBreg
	wire [31:0] mem_data_out_memwb_reg, direction_out_memwb_reg;
	wire [4:0] rd_out_memwb_reg;
	wire [1:0] flagsWB_out_memwb_reg;
	
	//OUTPUT WBStage
	wire [31:0] data_out_wbStage;
   

	fetchStage FS(
		.clk(clk),
		.clk_faster(clk_f),
		.rst(rst),
		.pc1_in(pc1_out_exmem_reg),
		.branch(immediate_out_exmem_reg[25:0]),
		.sel_pc(opcode_out_exmem_reg[5] & flagsMEM_out_exmem_reg[2] & ~opcode_out_exmem_reg[2]),
		.pc1(pc_out_fecthStage),
		.instruction(inst_out_fe)
	);
	
	IFIDreg ifreg(
		.clk(clk),
		.instruction(inst_out_fe),
		.pc1(pc_out_fecthStage),
		.opcode(opcode_out_ifid_reg),
		.rd(rd_out_ifid_reg),
		.rs(rs_out_ifid_reg),
		.rt(rt_out_ifid_reg),
		.immediate(immediate_out_ifid_reg),
		.flagsDECO(flagsDECO_out_ifid_reg),
		.flagsALU(flagsALU_out_ifid_reg),
		.flagsMEM(flagsMEM_out_ifid_reg),
		.flagsWB(flagsWB_out_ifid_reg),
		.pc1_out(pc1_out_ifid_reg)
	);
	
	
	decoStage DS(
		.clk(clk),
		.rst(rst),
		.pc1(pc1_out_ifid_reg),
		.opcode(opcode_out_ifid_reg),
		.rd(rd_out_ifid_reg),
		.rs(rs_out_ifid_reg),
		.rt(rt_out_ifid_reg),
		.immediate(immediate_out_ifid_reg),
		.flagsDECO(flagsDECO_out_ifid_reg),
		.flagsALU(flagsALU_out_ifid_reg),
		.flagsMEM(flagsMEM_out_ifid_reg),
		.flagsWB(flagsWB_out_ifid_reg),
		.dir_wr(rd_out_memwb_reg),
		.data_input(data_out_wbStage),
		.reg_wr(flagsWB_out_memwb_reg[1]),
		.pc1_out(pc1_out_decoStage),
		.flagsALU_out(flagsALU_out_decoStage),
		.flagsMEM_out(flagsMEM_out_decoStage),
		.flagsWB_out(flagsWB_out_decoStage),
		.opcode_out(opcode_out_decoStage),
		.dataOne(dataOne_out_decoStage),
		.dataTwo(dataTwo_out_decoStage),
		.immediate_out(immediate_out_decoStage),
		.rd_out(rd_out_decoStage),
		.prueba(prueba)
	);
	
	IDEXreg idreg(
		.clk(clk),
		.dataOne(dataOne_out_decoStage),
		.dataTwo(dataTwo_out_decoStage),
		.immediate(immediate_out_decoStage),
		.flagsALU(flagsALU_out_decoStage),
		.flagsMEM(flagsMEM_out_decoStage),
		.flagsWB(flagsWB_out_decoStage),
		.pc1(pc1_out_decoStage),
		.rd_dir(rd_out_decoStage),
		.opcode(opcode_out_decoStage),
		.dataOne_out(dataOne_out_idex_reg),
		.dataTwo_out(dataTwo_out_idex_reg),
		.immediate_out(immediate_out_idex_reg),
		.flagsALU_out(flagsALU_out_idex_reg),
		.flagsMEM_out(flagsMEM_out_idex_reg),
		.flagsWB_out(flagsWB_out_idex_reg),
		.pc1_out(pc1_out_idex_reg),
		.rd_out(rd_out_idex_reg),
		.opcode_out(opcode_out_idex_reg)
	);
	
	exeStage ES(
		.clk(clk),
		.pc1(pc1_out_idex_reg),
		.flagsALU(flagsALU_out_idex_reg),
		.flagsMEM(flagsMEM_out_idex_reg),
		.flagsWB(flagsWB_out_idex_reg),
		.opcode(opcode_out_idex_reg),
		.dataOne(dataOne_out_idex_reg),
		.dataTwo(dataTwo_out_idex_reg),
		.immediate(immediate_out_idex_reg),
		.rd(rd_out_idex_reg),
		.pc1_out(pc1_out_exeStage),
		.flagsMEM_out(flagsMEM_out_exeStage),
		.flagsWB_out(flagsWB_out_exeStage),
		.opcode_out(opcode_out_exeStage),
		.immediate_out(immediate_out_exeStage),
		.result_out(result_out_exeStage),
		.datainput_out(datainput_out_exeStage),
		.rd_out(rd_out_exeStage),
		.pixel1_out(pixel1_out),
		.pixel2_out(pixel2_out),
		.pixel3_out(pixel3_out),
		.pixel4_out(pixel4_out)
	);
	
	EXMEMreg exreg(
		.clk(clk),
		.pc1(pc1_out_exeStage),
		.flagsMEM(flagsMEM_out_exeStage),
		.flagsWB(flagsWB_out_exeStage),
		.opcode(opcode_out_exeStage),
		.immediate(immediate_out_exeStage),
		.result(result_out_exeStage),
		.datainput(datainput_out_exeStage),
		.rd(rd_out_exeStage),
		.pc1_out(pc1_out_exmem_reg),
		.flagsMEM_out(flagsMEM_out_exmem_reg),
		.flagsWB_out(flagsWB_out_exmem_reg),
		.opcode_out(opcode_out_exmem_reg),
		.immediate_out(immediate_out_exmem_reg),
		.result_out(result_out_exmem_reg),
		.datainput_out(datainput_out_exmem_reg),
		.rd_out(rd_out_exmem_reg)
	);
	
	
	memStage MS(
		.clk(clk),
		.alu_result(result_out_exmem_reg),
		.datainput(datainput_out_exmem_reg),
		.rd(rd_out_exmem_reg),
		.flagsMEM(flagsMEM_out_exmem_reg),
		.flagsWB(flagsWB_out_exmem_reg),
		.flagsWB_out(flagsWB_out_memStage),
		.mem_data(),
		.direction(direction_memStage),
		.rd_out(rd_out_memStage)
	);
	
	MEMWBreg memreg(
		.clk(clk),
		.flagsWB(flagsWB_out_exmem_reg),
		.mem_data(dataMem),
		.direction(direction_memStage),
		.rd(rd_out_memStage),
		.flagsWB_out(flagsWB_out_memwb_reg),
		.mem_data_out(mem_data_out_memwb_reg),
		.direction_out(direction_out_memwb_reg),
		.rd_out(rd_out_memwb_reg)
	);
	
	wbStage WS(
		.flagsWB(flagsWB_out_memwb_reg),
		.mem_data(mem_data_out_memwb_reg),
		.direction(direction_out_memwb_reg),
		.data_out(data_out_wbStage)
	);
	
	assign memAddress = result_out_exmem_reg;
	assign memDataInput = datainput_out_exmem_reg;
	assign readEn = flagsMEM_out_exmem_reg[1];
	assign writeEn = flagsMEM_out_exmem_reg[0];
	

endmodule