/*
* Grupo: José de Lemos, João Pedro Martins, Letícia Medeiros, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: PC (Contador de Programa)
* Descricao: registrador sincrono de 32 bits que armazena o endereco da instrucao atual
*/

module PC (
    input  wire        clock,  // sinal de clock, atualiza na borda de subida
    input  wire        reset,  // reset assincrono para inicializar o PC em 0
    input  wire [31:0] nextPC, // proximo endereco de instrucao
    output reg  [31:0] PC      // endereco atual da instrucao
);  

    // Atualiza o PC na borda de subida do clock ou zera no reset
    always @(posedge clock or posedge reset) begin
       if (reset)
           PC <= 32'h0000_0000;
       else    
           PC <= nextPC;
    end
endmodule           