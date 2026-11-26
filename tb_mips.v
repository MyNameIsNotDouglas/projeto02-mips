/*
* Grupo: Jose de Lemos, Joao Pedro Martins,  Leticia Medeiras, Sarah Lima
* Atividade: Projeto 02 - 2VA
* Disciplina: Arquitetura e Organizacao de Computadores
* Semestre: 2026.2
* Modulo: tb_mips (Testbench do Processador MIPS)
* Descricao: aplica clock, reset e monitora a execucao completa dos 7 testes do arquivo .list
*/

module tb_mips;
    reg         clock;
    reg         reset;
    wire [31:0] PC_out;
    wire [31:0] ULA_out;
    wire [31:0] Mem_out;
    integer     ciclo;

    // Instancia o processador MIPS Top-Level
    mips_top dut (
        .clock(clock),
        .reset(reset),
        .PC_out(PC_out),
        .ULA_out(ULA_out),
        .Mem_out(Mem_out)
    );

    // Gerador de clock (periodo = 10ns)
    initial clock = 0;
    always #5 clock = ~clock;

    initial begin
        $dumpfile("dump_mips.vcd");
        $dumpvars(0, tb_mips);

        // Aplica reset inicial
        reset = 1;
        #2;
        reset = 0;

        $display("Ciclo |  PC |    ULA_out (dec) | Mem_out (hex)");
        $display("------+-----+------------------+--------------");

        // imprime os sinais no meio de cada ciclo (antes da borda de subida atualizar o PC)
        for (ciclo = 1; ciclo <= 72; ciclo = ciclo + 1) begin
            @(negedge clock);
            $display("  %2d  | %3d | %16d | %h", ciclo, PC_out, $signed(ULA_out), Mem_out);
        end

        $display("Simulacao concluida.");
        $finish;
    end 
endmodule   