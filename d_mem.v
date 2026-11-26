/*
* Grupo: Jose de Lemos, Joao Pedro Martins,  Leticia Medeiras, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: d_mem (Memoria de Dados)
* Descricao: RAM parametrizavel com leitura assincrona (alta impedancia se MemRead=0) e escrita sincrona
*/

module d_mem #(
    parameter DEPTH = 256
)(
    input  wire        Clock,     // clock para escrita segura no monociclo
    input  wire [31:0] Address,   // endereco em bytes fornecido pela ULA
    input  wire [31:0] WriteData, // dado a ser escrito (vindo do regfile)
    input  wire        MemWrite,  // Habilitacao de escrita
    input  wire        MemRead,   // '           '  leitura
    output wire [31:0] ReadData   // dado lido (ou alta impedancia se MemRead=0)
);

    reg [31:0] memory [0:DEPTH-1];
    wire [31:0] word_index;

    // converte endereco em bytes para indice de palavra (Address >> 2)
    assign word_index = Address >> 2;

    // escrita sincrona na borda de subida do clock
    always @(posedge Clock) begin
        if (MemWrite && (word_index < DEPTH)) begin
            memory[word_index] <= WriteData;
        end   
    end     

    // leitura assincrona: retorna alta impedancia quando MemRead == 0
    assign ReadData = (MemRead && (word_index < DEPTH)) ? memory[word_index] : 32'hzzzz_zzzz;

endmodule    