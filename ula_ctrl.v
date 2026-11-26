/*
* Grupo: José de Lemos, João Pedro Martins, Letícia Medeiros, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: ula_ctrl (Unidade de Controle da ULA)
* Descricao: define o codigo OP da ULA, controla shifts por shamt e detecta a instrucao JR
*/

module ula_ctrl (
    input  wire [3:0] ALUOp,    // sinal vindo da unidade de controle principal
    input  wire [5:0] funct,    // campo funct (Instruction[5:0])
    output reg  [3:0] OP,       // operacao final para a ULA
    output reg        ShiftSrc, // 1 se a instrucao usar shamt (sll, srl, sra)
    output reg        JumpReg   // 1 se a instrucao for JR
);

    always @(*) begin
        OP       = ALUOp;
        ShiftSrc = 1'b0;
        JumpReg  = 1'b0;

        // Se for instrucao Tipo R (ALUOp == 4'b1111), decodifica o campo funct
        if (ALUOp == 4'b1111) begin
            case (funct)
                6'b100000: OP = 4'b0000; // add
                6'b100010: OP = 4'b0001; // sub
                6'b100100: OP = 4'b0010; // and
                6'b100101: OP = 4'b0011; // or
                6'b100110: OP = 4'b0100; // xor
                6'b100111: OP = 4'b0101; // nor
                6'b101010: OP = 4'b0110; // slt
                6'b101011: OP = 4'b0111; // sltu
                6'b000000: begin OP = 4'b1000; ShiftSrc = 1'b1; end // sll
                6'b000010: begin OP = 4'b1001; ShiftSrc = 1'b1; end // srl
                6'b000011: begin OP = 4'b1010; ShiftSrc = 1'b1; end // sra
                6'b000100: OP = 4'b1000; // sllv
                6'b000110: OP = 4'b1001; // srlv
                6'b000111: OP = 4'b1010; // srav
                6'b001000: begin OP = 4'b0000; JumpReg = 1'b1; end  // jr
                default:   OP = 4'b0000;
            endcase  
        end
    end  

endmodule            