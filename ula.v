/*
* Grupo: José de Lemos, João Pedro Martins, Letícia Medeiros, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: ula (Unidade Logica e Aritmetica)
* Descricao: executa operacoes aritmeticas, logicas, comparacoes, deslocamentos e LUI
*/

module ula (
    input  wire [31:0] In1,       // operando 1 (ReadData1 ou shamt)
    input  wire [31:0] In2,       // '        2 (ReadData2 ou imediato)
    input  wire [3:0]  OP,        // codigo da operacao fornecido pela ula_ctrl
    output reg  [31:0] result,    // resultado da operacao
    output wire        Zero_flag  // flag ativa em 1 quando result == 0
);

    // Seleciona a operacao conforme o codigo OP de 4 bits
    always @(*) begin
        case (OP)
            4'b0000: result = In1 + In2;                                       // ADD / ADDI / LW / SW
            4'b0001: result = In1 - In2;                                       // SUB / BEQ / BNE
            4'b0010: result = In1 & In2;                                       // AND / ANDI
            4'b0011: result = In1 | In2;                                       // OR / ORI
            4'b0100: result = In1 ^ In2;                                       // XOR / XORI
            4'b0101: result = ~(In1 | In2);                                    // NOR
            4'b0110: result = ($signed(In1) < $signed(In2)) ? 32'd1 : 32'd0;   // SLT / SLTI (com sinal)
            4'b0111: result = (In1 < In2) ? 32'd1 : 32'd0;                     // SLTU / SLTIU (sem sinal)
            4'b1000: result = In2 << In1[4:0];                                 // SLL / SLLV
            4'b1001: result = In2 >> In1[4:0];                                 // SRL / SRLV (logico)
            4'b1010: result = $signed(In2) >>> In1[4:0];                       // SRA / SRAV (aritmetico)
            4'b1011: result = {In2[15:0], 16'h0000};                           // LUI
            default: result = 32'h0000_0000;
        endcase  
    end      

    // Ativa Zero_flag quando o resultado for zero
    assign Zero_flag = (result == 32'h0000_0000);

endmodule    