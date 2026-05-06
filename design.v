module ALU #(
parameter WIDTH = 8,
parameter CMD_WIDTH = 4
)(
input [WIDTH-1:0] OPA,
input [WIDTH-1:0] OPB,
input CIN,
input CLK,
input RST,
input CE,
input MODE,
input [1:0] INP_VALID,
input [CMD_WIDTH-1:0] CMD,

output reg [2*WIDTH-1:0] RES,
output reg OFLOW,
output reg COUT,
output reg G, L, E,
output reg ERR
);

reg signed [WIDTH:0] temp;
reg [1:0] mul_cnt;
reg [WIDTH-1:0] opa_reg, opb_reg;
reg [2*WIDTH-1:0] mul_temp;
reg mode_reg;

always @(posedge CLK or posedge RST) begin
if (RST) begin
    RES   <= 0;
    OFLOW <= 0;
    COUT  <= 0;
    G <= 0;
    L <= 0;
    E <= 0;
    ERR <= 0;
    mul_cnt <= 0;
end

else if (CE) begin

    if (MODE == 1) begin

        if (INP_VALID == 2'b11) begin

            if (CMD != 4'b1001)
                mul_cnt <= 0;

            case (CMD)

            4'b0000: begin
                temp = OPA + OPB;
                RES <= temp;
                COUT <= temp[WIDTH];
            end

            4'b0001: begin
                RES <= OPA - OPB;
                OFLOW <= (OPB > OPA);
            end

            4'b0010: begin
                temp = OPA + OPB + CIN;
                RES <= temp;
                COUT <= temp[WIDTH];
            end

            4'b0011: begin
                RES <= OPA - OPB - CIN;
                OFLOW <= (OPB > OPA);
            end

            4'b1000: begin
                G <= 0; L <= 0; E <= 0;
                if (OPA > OPB) G <= 1;
                else if (OPA < OPB) L <= 1;
                else E <= 1;
            end

            4'b1001: begin
                case (mul_cnt)

                2'd0: begin
                    opa_reg <= OPA;
                    opb_reg <= OPB;
                    mode_reg <= MODE;
                    mul_cnt <= 1;
                    RES <= 0;
                end

                2'd1: begin
                    if (MODE != mode_reg) begin
                        RES <= 0;
                        mul_cnt <= 0;
                    end else begin
                        mul_cnt <= 2;
                        RES <= 0;
                    end
                end

                2'd2: begin
                    if (MODE != mode_reg) begin
                        RES <= 0;
                        mul_cnt <= 0;
                    end else begin
                        mul_temp = (opa_reg + 1) * (opb_reg + 1);
                        RES <= mul_temp;
                        COUT <= |mul_temp[2*WIDTH-1:WIDTH];
                        OFLOW <= COUT;

                        if (CMD == 4'b1001) begin
                            opa_reg <= OPA;
                            opb_reg <= OPB;
                            mul_cnt <= 1;
                        end else begin
                            mul_cnt <= 0;
                        end
                    end
                end

                endcase
            end

            4'b1011: begin
                temp = $signed(OPA) + $signed(OPB);
                RES <= temp;
                COUT <= temp[WIDTH];

                OFLOW <= (OPA[WIDTH-1] == OPB[WIDTH-1]) &&
                         (temp[WIDTH-1] != OPA[WIDTH-1]);

                G <= 0; L <= 0; E <= 0;
                if (temp[WIDTH-1:0] == 0) E <= 1;
                else if (temp[WIDTH-1]) L <= 1;
                else G <= 1;
            end

            4'b1100: begin
                temp = $signed(OPA) - $signed(OPB);
                RES <= temp;

                OFLOW <= (OPA[WIDTH-1] != OPB[WIDTH-1]) &&
                         (temp[WIDTH-1] != OPA[WIDTH-1]);

                G <= 0; L <= 0; E <= 0;
                if (temp[WIDTH-1:0] == 0) E <= 1;
                else if (temp[WIDTH-1]) L <= 1;
                else G <= 1;
            end

            endcase
        end

        else if (INP_VALID == 2'b01) begin
            case (CMD)
            4'b0100: RES <= OPA + 1;
            4'b0101: RES <= OPA - 1;
            endcase
        end

        else if (INP_VALID == 2'b10) begin
            case (CMD)
            4'b0110: RES <= OPB + 1;
            4'b0111: RES <= OPB - 1;
            endcase
        end

    end

    else begin
        case (CMD)

        4'b0000: RES <= OPA & OPB;
        4'b0001: RES <= ~(OPA & OPB);
        4'b0010: RES <= OPA | OPB;
        4'b0011: RES <= ~(OPA | OPB);
        4'b0101: RES <= OPA ^ OPB;
        4'b0110: RES <= ~(OPA ^ OPB);
        4'b0111: RES <= ~OPA;
        4'b1000: RES <= ~OPB;
        4'b1001: RES <= OPA >> 1;
        4'b1010: RES <= OPA << 1;
        4'b1011: RES <= OPB >> 1;
        4'b1100: RES <= OPB << 1;

        4'b1101: begin
            ERR <= |OPB[7:4];
            case (OPB[2:0])
                3'b000: RES <= OPA;
                3'b001: RES <= (OPA << 1) | (OPA >> (WIDTH-1));
                3'b010: RES <= (OPA << 2) | (OPA >> (WIDTH-2));
                3'b011: RES <= (OPA << 3) | (OPA >> (WIDTH-3));
                3'b100: RES <= (OPA << 4) | (OPA >> (WIDTH-4));
                3'b101: RES <= (OPA << 5) | (OPA >> (WIDTH-5));
                3'b110: RES <= (OPA << 6) | (OPA >> (WIDTH-6));
                3'b111: RES <= (OPA << 7) | (OPA >> (WIDTH-7));
            endcase
        end

        4'b1110: begin
            ERR <= |OPB[7:4];
            case (OPB[2:0])
                3'b000: RES <= OPA;
                3'b001: RES <= (OPA >> 1) | (OPA << (WIDTH-1));
                3'b010: RES <= (OPA >> 2) | (OPA << (WIDTH-2));
                3'b011: RES <= (OPA >> 3) | (OPA << (WIDTH-3));
                3'b100: RES <= (OPA >> 4) | (OPA << (WIDTH-4));
                3'b101: RES <= (OPA >> 5) | (OPA << (WIDTH-5));
                3'b110: RES <= (OPA >> 6) | (OPA << (WIDTH-6));
                3'b111: RES <= (OPA >> 7) | (OPA << (WIDTH-7));
            endcase
        end

        endcase
    end

end

else begin
    RES   <= 0;
    OFLOW <= 0;
    COUT  <= 0;
    G     <= 0;
    L     <= 0;
    E     <= 0;
    ERR   <= 0;
end

end

endmodule

