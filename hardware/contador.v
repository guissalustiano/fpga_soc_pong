module contador #(
    parameter MODULO = 32,
    parameter WIDTH = $clog2(MODULO)
) (
    input clock,
    input zera,
    input conta,
    output reg [WIDTH:0] contagem,
    output reg fim
);

always @(posedge clock) begin
    fim = 0;
    if (!zera)
        if (conta) begin
            contagem = contagem + 1;
            if (contagem == MODULO) begin
                contagem = 0;
                fim = 1;
            end
        end
    else
        contagem = 0;
end
endmodule
