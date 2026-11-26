/*
* Grupo: José de Lemos, João Pedro Martins, Letícia Medeiros, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: i_mem (Memoria de Instrucoes)
* Descricao: ROM assincrona parametrizavel que carrega instrucoes binarias de instruction.list.
*/

module i_mem #(
    parameter DEPTH = 256,
    parameter INIT_FILE = "instruction.list"
)(
    input  wire [31:0] address, // Endereco em bytes fornecido pelo PC    
    output wire [31:0] i_out    // Instrucao de 32 bits lida
);

    // vetor de memoria para armazenar as instrucoes
    reg [31:0] memory [0:DEPTH-1];
    integer i;

    // preenche a ROM com NOP (0) para evitar 'xxxx' apos o fim do programa e carrega o .list
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            memory[i] = 32'h0000_0000;
        $readmemb(INIT_FILE, memory);   
    end     

    // leitura assincrona com protecao de limite (retorna NOP fora da faixa)
    assign i_out = (address[31:2] < DEPTH) ? memory[address[31:2]] : 32'h0000_0000;

endmodule    