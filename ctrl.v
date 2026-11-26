/*
* Grupo: José de Lemos, João Pedro Martins, Letícia Medeiros, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: ctrl (Unidade de Controle)
* Descricao: decodifica o opcode (bits 31-26) e gera todos os sinais de controle do datapath
*/

module ctrl (
    input  wire [5:0] opcode,   // Instruction[31:26]
    output reg  [1:0] RegDst,   // 00: rt | 01: rd | 10: $ra (31)
    output reg        Branch,   // 1 para BEQ
    output reg        BranchNE, // 1 para BNE
    output reg        Jump,     // 1 para J e JAL
    output reg        MemRead,  // 1 para LW
    output reg  [1:0] MemtoReg, // 00: ULA | 01: Mem | 10: PC+4 (JAL)
    output reg  [3:0] ALUOp,    // Controle enviado para ula_ctrl
    output reg        MemWrite, // 1 para SW
    output reg        ALUSrc,   // 0: ReadData2 | 1: Imediato estendido
    output reg        RegWrite, // 1 para habilitar escrita no regfile
    output reg        ExtOp     // 1: Sign-Extend | 0: Zero-Extend
);

    always @(*) begin
        // Valores padrao seguros (evita latches)
        RegDst   = 2'b00;
        Branch   = 1'b0;
        BranchNE = 1'b0;
        Jump     = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 2'b00;
        ALUOp    = 4'b0000;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;
        ExtOp    = 1'b1;

        case (opcode)
            6'b000000: begin // Tipo R
                RegDst   = 2'b01;
                RegWrite = 1'b1;
                ALUOp    = 4'b1111; // Indica para ula_ctrl decodificar funct
            end    
            6'b001000: begin // ADDI
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 4'b0000; // ADD
            end    
            6'b001100: begin // ANDI (Zero-Extend)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ExtOp    = 1'b0;
                ALUOp    = 4'b0010; // AND
            end    
            6'b001101: begin // ORI (Zero-Extend)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ExtOp    = 1'b0;
                ALUOp    = 4'b0011; // OR
            end    
            6'b001110: begin // XORI (Zero-Extend)
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ExtOp    = 1'b0;
                ALUOp    = 4'b0100; // XOR
            end    
            6'b001010: begin // SLTI
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 4'b0110; // SLT
            end    
            6'b001011: begin // SLTIU
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 4'b0111; // SLTU
            end    
            6'b001111: begin // LUI
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 4'b1011; // LUI
            end    
            6'b100011: begin // LW
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 2'b01;
                RegWrite = 1'b1;
                ALUOp    = 4'b0000; // ADD
            end    
            6'b101011: begin // SW
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 4'b0000; // ADD
            end
            6'b000100: begin // BEQ
                Branch   = 1'b1;
                ALUOp    = 4'b0001; // SUB
            end    
            6'b000101: begin // BNE
                BranchNE = 1'b1;
                ALUOp    = 4'b0001; // SUB
            end    
            6'b000010: begin // J
                Jump     = 1'b1;
            end    
            6'b000011: begin // JAL
                Jump     = 1'b1;
                RegDst   = 2'b10; // Escreve em $ra (31)
                MemtoReg = 2'b10; // Salva PC+4
                RegWrite = 1'b1;
            end   
        endcase   
    end      
endmodule    