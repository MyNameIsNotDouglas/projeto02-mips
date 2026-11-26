/*
* Grupo: Jose de Lemos, Joao Pedro Martins,  Leticia Medeiras, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: mips_top (Top-Level do Nucleo MIPS Monociclo)
* Descricao: integra PC, i_mem, regfile, ula, d_mem, ctrl, ula_ctrl e logica auxiliar (MUXes/somadores)
*/

module mips_top (
    input  wire        clock,   // Clock principal do processador
    input  wire        reset,   // Reset global (PC e regfile)
    output wire [31:0] PC_out,  // Saida: valor atual do PC
    output wire [31:0] ULA_out, // Saida: resultado atual da ULA
    output wire [31:0] Mem_out  // Saida: dado atual lido da memoria de dados
);

    // Fios internos do datapath
    wire [31:0] pc_curr, pc_plus4, next_pc;
    wire [31:0] instr;
    wire [31:0] read_data1, read_data2, write_data_reg;
    wire [31:0] imm_ext, ula_in1, ula_in2, ula_res, mem_read_data;
    wire [31:0] branch_target, jump_target, pc_branch_mux, pc_jump_mux;
    wire [4:0]  write_reg_addr;

    // Sinais de controle
    wire [1:0]  RegDst, MemtoReg;
    wire [3:0]  ALUOp, ula_op;
    wire        Branch, BranchNE, Jump, MemRead, MemWrite, ALUSrc, RegWrite, ExtOp;
    wire        ShiftSrc, JumpReg, zero_flag, take_branch, reg_write_en;

    // 1. Contador de Programa (PC) e somador PC + 4
    PC pc_inst (
        .clock(clock),
        .reset(reset),
        .nextPC(next_pc),
        .PC(pc_curr)
    );
    assign pc_plus4 = pc_curr + 32'd4;

    // 2. Memoria de Instrucoes (ROM)
    i_mem #(.DEPTH(256), .INIT_FILE("instruction.list")) imem_inst (
        .address(pc_curr),
        .i_out(instr)
    );

    // 3. Unidade de Controle Principal
    ctrl ctrl_inst (
        .opcode(instr[31:26]),
        .RegDst(RegDst),
        .Branch(Branch),
        .BranchNE(BranchNE),
        .Jump(Jump),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ExtOp(ExtOp)
    );

    // 4. Unidade de Controle da ULA
    ula_ctrl ula_ctrl_inst (
        .ALUOp(ALUOp),
        .funct(instr[5:0]),
        .OP(ula_op),
        .ShiftSrc(ShiftSrc),
        .JumpReg(JumpReg)
    );

    // MUX de destino do registrador (rt, rd ou $ra=31)
    assign write_reg_addr = (RegDst == 2'b00) ? instr[20:16] :
                            (RegDst == 2'b01) ? instr[15:11] : 5'd31;

    // Bloqueia escrita no regfile caso a instrucao seja JR     
    assign reg_write_en = RegWrite & ~JumpReg;        

    // 5. Banco de Registradores      
    regfile regfile_inst (
        .Clock(clock),
        .Reset(reset),
        .RegWrite(reg_write_en),
        .ReadAddr1(instr[25:21]),
        .ReadAddr2(instr[20:16]),
        .WriteAddr(write_reg_addr),
        .WriteData(write_data_reg),
        .ReadData1(read_data1),
        .ReadData2(read_data2)
    );   

    // Extensor de Imediato (Sign-Extend se ExtOp=1, Zero-Extend se ExtOp=0)  
    assign imm_ext = ExtOp ? {{16{instr[15]}}, instr[15:0]} : {16'h0000, instr[15:0]};

    // MUXes das entradas da ULA (In1 suporta shamt; In2 suporta imediato)
    assign ula_in1 = ShiftSrc ? {27'b0, instr[10:6]} : read_data1;
    assign ula_in2 = ALUSrc   ? imm_ext              : read_data2;

    // 6. Unidade Logica e Aritmetica (ULA)
    ula ula_inst (
        .In1(ula_in1),
        .In2(ula_in2),
        .OP(ula_op),
        .result(ula_res),
        .Zero_flag(zero_flag)
    );

    // 7. Memoria de Dados (RAM)
    d_mem #(.DEPTH(256)) dmem_inst (
        .Clock(clock),
        .Address(ula_res),
        .WriteData(read_data2),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ReadData(mem_read_data)
    );

    // MUX de Write-Back (ULA, Memoria ou PC+4 para JAL)
    assign write_data_reg = (MemtoReg == 2'b00) ? ula_res :
                            (MemtoReg == 2'b01) ? mem_read_data : pc_plus4;
    
    // Logica de proximo PC (Branch, Jump e Jump Register)
    assign take_branch   = (Branch & zero_flag) | (BranchNE & ~zero_flag);
    assign branch_target = pc_plus4 + (imm_ext << 2);
    assign jump_target   = {pc_plus4[31:28], instr[25:0], 2'b00};

    assign pc_branch_mux = take_branch ? branch_target : pc_plus4;
    assign pc_jump_mux   = Jump        ? jump_target   : pc_branch_mux;
    assign next_pc       = JumpReg     ? read_data1    : pc_jump_mux;

    // Saidas expostas na interface Top-Level
    assign PC_out  = pc_curr;
    assign ULA_out = ula_res;
    assign Mem_out = mem_read_data;

endmodule    