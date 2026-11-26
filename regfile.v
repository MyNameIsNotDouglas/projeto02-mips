/*
* Grupo: José de Lemos, João Pedro Martins, Letícia Medeiros, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: regfile (Banco de Registradores)
* Descricao: 32 registradores de 32 bits com leitura dupla assincrona, escrita sincrona e $0 fixo em 0
*/

module regfile (
    input  wire        Clock,     // clock para sincronizar escritas
    input  wire        Reset,     // reset assincrono (zera todos os registradores)
    input  wire        RegWrite,  // habilitacao de escrita
    input  wire [4:0]  ReadAddr1, // endereco da porta de leitura 1 ($rs)
    input  wire [4:0]  ReadAddr2, // '        '  '     '  '       2 ($rt)
    input  wire [4:0]  WriteAddr, // '        do registrador de destino
    input  wire [31:0] WriteData, // dado a ser escrito
    output wire [31:0] ReadData1, // '    lido da porta 1
    output wire [31:0] ReadData2  // '    lido da porta 2
);

    reg [31:0] registers [0:31];
    integer i;

    // Escrita sincrona na borda de subida e reset assincrono
    always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'h0000_0000;
        end else if (RegWrite && (WriteAddr != 5'd0)) begin      
            // Impede sobrescrita no registrador $0
            registers[WriteAddr] <= WriteData;
        end    
    end   

    // Leituras assincronas continuas com $0 sempre retornando zero 
    assign ReadData1 = (ReadAddr1 == 5'd0) ? 32'h0000_0000 : registers[ReadAddr1];
    assign ReadData2 = (ReadAddr2 == 5'd0) ? 32'h0000_0000 : registers[ReadAddr2];

endmodule    