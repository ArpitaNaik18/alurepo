`timescale 1ns / 1ps
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

reg [WIDTH-1:0] opa_d, opb_d;
reg cin_d;
reg mode_d;
reg [1:0] inp_valid_d;
reg [CMD_WIDTH-1:0] cmd_d;

always @(posedge CLK or posedge RST)
begin



if (RST)
begin
    RES <= 0;
    OFLOW <= 0;
    COUT <= 0;
    G <= 0;
    L <= 0;
    E <= 0;
    ERR <= 0;

    mul_cnt <= 0;

    opa_d <= 0;
    opb_d <= 0;
    cin_d <= 0;
    mode_d <= 0;
    inp_valid_d <= 0;
    cmd_d <= 0;
end



else if (CE)
begin



    opa_d <= OPA;
    opb_d <= OPB;
    cin_d <= CIN;
    mode_d <= MODE;
    inp_valid_d <= INP_VALID;
    cmd_d <= CMD;


    OFLOW <= 0;
    COUT <= 0;
    G <= 0;
    L <= 0;
    E <= 0;
    ERR <= 0;



    if (mode_d)
    begin



        if (inp_valid_d == 2'b11)
        begin

            if (cmd_d != 4'b1001)
                mul_cnt <= 0;

            case(cmd_d)



            4'b0000:
            begin
                temp = opa_d + opb_d;
                RES <= temp;
                COUT <= temp[WIDTH];
            end



            4'b0001:
            begin
                RES <= opa_d - opb_d;
                OFLOW <= (opb_d > opa_d);
            end



            4'b0010:
            begin
                temp = opa_d + opb_d + cin_d;
                RES <= temp;
                COUT <= temp[WIDTH];
            end



            4'b0011:
            begin
                RES <= opa_d - opb_d - cin_d;
                OFLOW <= (opb_d > opa_d);
            end



            4'b1000:
            begin
                if (opa_d > opb_d)
                    G <= 1;

                else if (opa_d < opb_d)
                    L <= 1;

                else
                    E <= 1;
            end



            4'b1001:
            begin

                case(mul_cnt)

                2'd0:
                begin
                    opa_reg <= opa_d;
                    opb_reg <= opb_d;
                    mode_reg <= mode_d;

                    mul_cnt <= 1;

                    RES <= 0;
                end

                2'd1:
                begin

                    if (mode_d != mode_reg)
                    begin
                        RES <= 0;
                        mul_cnt <= 0;
                    end

                    else
                    begin
                        mul_cnt <= 2;
                        RES <= 0;
                    end
                end

                2'd2:
                begin

                    if (mode_d != mode_reg)
                    begin
                        RES <= 0;
                        mul_cnt <= 0;
                    end

                    else
                    begin

                        mul_temp = (opa_reg + 1) * (opb_reg + 1);

                        RES <= mul_temp;

                        COUT <= |mul_temp[2*WIDTH-1:WIDTH];

                        OFLOW <= |mul_temp[2*WIDTH-1:WIDTH];

                        if (cmd_d == 4'b1001)
                        begin
                            opa_reg <= opa_d;
                            opb_reg <= opb_d;

                            mul_cnt <= 1;
                        end

                        else
                        begin
                            mul_cnt <= 0;
                        end
                    end
                end

                endcase
            end



            4'b1011:
            begin

                temp = $signed(opa_d) + $signed(opb_d);

                RES <= temp;

                COUT <= temp[WIDTH];

                OFLOW <=
                (opa_d[WIDTH-1] == opb_d[WIDTH-1]) &&
                (temp[WIDTH-1] != opa_d[WIDTH-1]);

                if (temp[WIDTH-1:0] == 0)
                    E <= 1;

                else if (temp[WIDTH-1])
                    L <= 1;

                else
                    G <= 1;
            end



            4'b1100:
            begin

                temp = $signed(opa_d) - $signed(opb_d);

                RES <= temp;

                OFLOW <=
                (opa_d[WIDTH-1] != opb_d[WIDTH-1]) &&
                (temp[WIDTH-1] != opa_d[WIDTH-1]);

                if (temp[WIDTH-1:0] == 0)
                    E <= 1;

                else if (temp[WIDTH-1])
                    L <= 1;

                else
                    G <= 1;
            end

            default:
            begin
                RES <= 0;
                ERR <= 1;
            end

            endcase
        end



        else if (inp_valid_d == 2'b01)
        begin

            case(cmd_d)

            4'b0100:
                RES <= opa_d + 1;

            4'b0101:
                RES <= opa_d - 1;

            default:
                ERR <= 1;

            endcase
        end



        else if (inp_valid_d == 2'b10)
        begin

            case(cmd_d)

            4'b0110:
                RES <= opb_d + 1;

            4'b0111:
                RES <= opb_d - 1;

            default:
                ERR <= 1;

            endcase
        end

        else
        begin
            ERR <= 1;
        end

    end



    else
    begin

        case(cmd_d)

        4'b0000: RES <= opa_d & opb_d;

        4'b0001: RES <= ~(opa_d & opb_d);

        4'b0010: RES <= opa_d | opb_d;

        4'b0011: RES <= ~(opa_d | opb_d);

        4'b0101: RES <= opa_d ^ opb_d;

        4'b0110: RES <= ~(opa_d ^ opb_d);

        4'b0111: RES <= ~opa_d;

        4'b1000: RES <= ~opb_d;

        4'b1001: RES <= opa_d >> 1;

        4'b1010: RES <= opa_d << 1;

        4'b1011: RES <= opb_d >> 1;

        4'b1100: RES <= opb_d << 1;



        4'b1101:
        begin

            ERR <= |opb_d[7:4];

            case(opb_d[2:0])

            3'b000: RES <= opa_d;
            3'b001: RES <= (opa_d << 1) | (opa_d >> (WIDTH-1));
            3'b010: RES <= (opa_d << 2) | (opa_d >> (WIDTH-2));
            3'b011: RES <= (opa_d << 3) | (opa_d >> (WIDTH-3));
            3'b100: RES <= (opa_d << 4) | (opa_d >> (WIDTH-4));
            3'b101: RES <= (opa_d << 5) | (opa_d >> (WIDTH-5));
            3'b110: RES <= (opa_d << 6) | (opa_d >> (WIDTH-6));
            3'b111: RES <= (opa_d << 7) | (opa_d >> (WIDTH-7));

            endcase
        end



        4'b1110:
        begin

            ERR <= |opb_d[7:4];

            case(opb_d[2:0])

            3'b000: RES <= opa_d;
            3'b001: RES <= (opa_d >> 1) | (opa_d << (WIDTH-1));
            3'b010: RES <= (opa_d >> 2) | (opa_d << (WIDTH-2));
            3'b011: RES <= (opa_d >> 3) | (opa_d << (WIDTH-3));
            3'b100: RES <= (opa_d >> 4) | (opa_d << (WIDTH-4));
            3'b101: RES <= (opa_d >> 5) | (opa_d << (WIDTH-5));
            3'b110: RES <= (opa_d >> 6) | (opa_d << (WIDTH-6));
            3'b111: RES <= (opa_d >> 7) | (opa_d << (WIDTH-7));

            endcase
        end

        default:
        begin
            RES <= 0;
            ERR <= 1;
        end

        endcase
    end
end



else
begin
    RES <= 0;
    OFLOW <= 0;
    COUT <= 0;
    G <= 0;
    L <= 0;
    E <= 0;
    ERR <= 0;
end

end

endmodule

