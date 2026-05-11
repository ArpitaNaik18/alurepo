// `timescale 1ns / 1ps
`include "alu_ref.v"
//`include "alu.v"
module alu_tb;
  parameter N=8;
  reg [N-1:0] opa, opb;
reg clk, rst, ce, mode, cin;
  reg [(N/2)-1:0] cmd;
reg [1:0]inp_valid;

  wire [2*N-1:0] res_dut;
wire cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut;

  wire [2*N-1:0] res_ref;
wire cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref;

integer pass_count = 0;
integer fail_count = 0;
integer test_count = 0;

// DUT instantiation
  alu #(N) alu1 (
    .OPA(opa),
    .OPB(opb),
    .CIN(cin),
    .CLK(clk),
    .RST(rst),
    .CMD(cmd),
    .CE(ce),
    .MODE(mode),
    .INP_VALID(inp_valid),

    .COUT(cout_dut),
    .OFLOW(oflow_dut),
    .RES(res_dut),

    .G(g_dut),
    .E(e_dut),
    .L(l_dut),
    .ERR(err_dut)
);

// Reference model instantiation
  alu_ref #(N) alu2 (
    .opa(opa),
    .opb(opb),
    .cin(cin),
    .rst(rst),
    .ce(ce),
    .mode(mode),
    .cmd(cmd),

    .res(res_ref),
    .cout(cout_ref),
    .oflow(oflow_ref),
    .inp_valid(inp_valid),

    .g(g_ref),
    .e(e_ref),
    .l(l_ref),
    .err(err_ref)
);

initial
begin
clk=1'b0;
forever #5 clk=~clk;
end

initial
begin
rst=1;ce=1;cin=0;opa=0;opb=0;mode=0;cmd=0;inp_valid=0;
  $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
@(posedge clk)
rst=0;ce=0;
  $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
  @(posedge clk)
rst=0;rst=1;rst=1;
  $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
@(posedge clk)
$display("Testing all operations starting from MODE=1(Arithmatic)");
rst=0;ce=1;mode=1;
test_arithmatic();

$display("Testing all operations starting from MODE=0(Logical)");
mode=0;
test_logical();

 $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

#100;
$finish;
end

task test_arithmatic();
begin
apply_test(8'd25,8'd55,0,2'b11,4'd0,"CMD_ARITH_0");
apply_test(8'd25,8'd55,0,2'b11,4'd1,"CMD_ARITH_1");
apply_test(8'd15,8'd89,1,2'b11,4'd2,"CMD_ARITH_2");
apply_test(8'd67,8'd12,1,2'b11,4'd3,"CMD_ARITH_3");
apply_test(8'd25,8'd255,0,2'b01,4'd4,"CMD_ARITH_4_01");
apply_test(8'd25,8'd255,0,2'b11,4'd4,"CMD_ARITH_4_11");
apply_test(8'd56,8'd255,1,2'b01,4'd5,"CMD_ARITH_5_01");
apply_test(8'd56,8'd255,1,2'b11,4'd5,"CMD_ARITH_5_11");
apply_test(8'd255,8'd84,1,2'b10,4'd6,"CMD_ARITH_6_10");
apply_test(8'd255,8'd84,1,2'b11,4'd6,"CMD_ARITH_6_11");
apply_test(8'd255,8'd56,1,2'b10,4'd7,"CMD_ARITH_7_10");
apply_test(8'd25,8'd65,1,2'b11,4'd7,"CMD_ARITH_7_11");
apply_test(8'd255,8'd25,1,2'b11,4'd8,"CMD_ARITH_8_g");
apply_test(8'd55,8'd95,1,2'b11,4'd8,"CMD_ARITH_8_l");
apply_test(8'd255,8'd255,1,2'b11,4'd8,"CMD_ARITH_8_e");
apply_test(8'd25,8'd25,1,2'b11,4'd9,"CMD_ARITH_9_mul");
apply_test(8'd25,8'd55,1,2'b11,4'd10,"CMD_ARITH_10_mul");
apply_test(-8'd89,-8'd45,1,2'b11,4'd11,"CMD_ARITH_11_signed1-add");
apply_test(-8'd35,-8'd25,1,2'b11,4'd12,"CMD_ARITH_12signed-sub");
apply_test(8'd25,8'd55,0,2'b00,4'd0,"CMD_ARITH_0_00");
apply_test(8'd25,8'd55,0,2'b01,4'd0,"CMD_ARITH_0_01");
apply_test(8'd25,8'd55,0,2'b10,4'd0,"CMD_ARITH_0_10");
apply_test(8'd25,8'd55,0,2'b00,4'd1,"CMD_ARITH_1_00");
apply_test(8'd25,8'd55,0,2'b01,4'd1,"CMD_ARITH_1_01");
apply_test(8'd25,8'd55,0,2'b10,4'd1,"CMD_ARITH_1_10");
apply_test(8'd15,8'd89,1,2'b00,4'd2,"CMD_ARITH_2_00");
apply_test(8'd15,8'd89,1,2'b01,4'd2,"CMD_ARITH_2_01");
apply_test(8'd15,8'd89,1,2'b10,4'd2,"CMD_ARITH_2_10");
apply_test(8'd67,8'd12,1,2'b00,4'd3,"CMD_ARITH_3_00");
apply_test(8'd67,8'd12,1,2'b01,4'd3,"CMD_ARITH_3_01");
apply_test(8'd67,8'd12,1,2'b10,4'd3,"CMD_ARITH_3_10");
apply_test(8'd25,8'd255,0,2'b10,4'd4,"CMD_ARITH_4_10");
apply_test(8'd25,8'd255,0,2'b00,4'd4,"CMD_ARITH_4_00");
apply_test(8'd56,8'd255,1,2'b00,4'd5,"CMD_ARITH_5_00");
apply_test(8'd56,8'd255,1,2'b10,4'd5,"CMD_ARITH_5_10");
apply_test(8'd255,8'd84,1,2'b00,4'd6,"CMD_ARITH_6_00");
apply_test(8'd255,8'd84,1,2'b01,4'd6,"CMD_ARITH_6_01");
apply_test(8'd255,8'd56,1,2'b00,4'd7,"CMD_ARITH_7_00");
apply_test(8'd25,8'd65,1,2'b01,4'd7,"CMD_ARITH_7_01");
apply_test(8'd255,8'd25,1,2'b00,4'd8,"CMD_ARITH_8_00");
apply_test(8'd255,8'd25,1,2'b01,4'd8,"CMD_ARITH_8_01");
apply_test(8'd255,8'd25,1,2'b10,4'd8,"CMD_ARITH_8_10");

apply_test(8'd55,8'd95,1,2'b00,4'd8,"CMD_ARITH_8_00");
apply_test(8'd55,8'd95,1,2'b01,4'd8,"CMD_ARITH_8_01");
apply_test(8'd55,8'd95,1,2'b10,4'd8,"CMD_ARITH_8_10");

apply_test(8'd255,8'd255,1,2'b00,4'd8,"CMD_ARITH_8_00");
apply_test(8'd255,8'd255,1,2'b01,4'd8,"CMD_ARITH_8_01");
apply_test(8'd255,8'd255,1,2'b10,4'd8,"CMD_ARITH_8_10");
apply_test(8'd25,8'd25,1,2'b00,4'd9,"CMD_ARITH_9_00");
apply_test(8'd25,8'd25,1,2'b01,4'd9,"CMD_ARITH_9_01");
apply_test(8'd25,8'd25,1,2'b10,4'd9,"CMD_ARITH_9_10");
apply_test(8'd25,8'd55,1,2'b00,4'd10,"CMD_ARITH_10_00");
apply_test(8'd25,8'd55,1,2'b01,4'd10,"CMD_ARITH_10_01");
apply_test(8'd25,8'd55,1,2'b10,4'd10,"CMD_ARITH_10_10");
apply_test(-8'd89,-8'd45,1,2'b00,4'd11,"CMD_ARITH_11_00");
apply_test(-8'd89,-8'd45,1,2'b01,4'd11,"CMD_ARITH_11_01");
apply_test(-8'd89,-8'd45,1,2'b10,4'd11,"CMD_ARITH_11_10");
apply_test(-8'd35,-8'd25,1,2'b00,4'd12,"CMD_A+RITH_12_00");
apply_test(-8'd35,-8'd25,1,2'b01,4'd12,"CMD_ARITH_12_01");
apply_test(-8'd35,-8'd25,1,2'b10,4'd12,"CMD_ARITH_12_10");
apply_test(8'd255,8'd255,1,2'b11,4'd0,"ADD_with_all_bits_high");
apply_test(8'd127,8'd1,1,2'b11,4'd11,"ADD_signed_overflow");
apply_test(8'd0,8'd0,1,2'b11,4'd1,"Sub_signed_overflow");
apply_test(8'd0,8'd0,1,2'b11,4'd3,"Sub_signed_overflow");
apply_test(8'd0,8'd0,1,2'b11,4'd11,"Sub_signed_overflow");
apply_test(8'd0,8'd1,1,2'b11,4'd11,"Sub_signed_overflow");
apply_test(8'd46,8'd46,1,2'b11,4'd11,"Sub_same_operands");
apply_test(8'd255,8'd0,1,2'b11,4'd2,"cin add_boundary");
apply_test(8'd0,8'd0,1,2'b11,4'd3,"Sub_cin_boundary");
apply_test(8'd255,8'd0,1,2'b11,4'd4,"max_inc_a");
apply_test(8'd0,8'd0,1,2'b11,4'd5,"max_dec_a");
apply_test(8'd255,8'd0,1,2'b11,4'd6,"max_inc_b");
apply_test(8'd0,8'd0,1,2'b11,4'd7,"max_dec_b");
apply_test(8'd255,8'd246,1,2'b11,4'd2,"Add_cin_boundary");
apply_test(8'd25,8'd26,1,2'b11,4'd2,"cout=0");
apply_test(8'd255,8'd246,1,2'b11,4'd14,"CMD>4'd12");
apply_test(8'd255,8'd246,1,2'b11,4'd12,"CMD_ARITH_12_g");
apply_test(8'd25,8'd25,1,2'b11,4'd12,"CMD_ARITH_12_e");
apply_test(8'd25,8'd246,1,2'b11,4'd12,"CMD_ARITH_12_l");
apply_test(8'd255,8'd246,1,2'bxx,4'd14,"CMD>4'd12");
apply_test(8'd127,8'd1,1,2'b11,4'd11,"SIGNED_ADD_OVERFLOW");
apply_test(8'd127,8'd255,1,2'b11,4'd12,"SIGNED_SUB_OVERFLOW");
apply_test(-8'd128,-8'd1,1,2'b11,4'd12,"SIGNED_SUB_-127-(-1))");

apply_test(8'd254,8'd254,1,2'b11,4'd9,"CMD_ARITH_9_mul_op_high");
apply_test(8'd251,8'd255,1,2'b11,4'd10,"CMD_ARITH_10_mul_op_high");
apply_test(8'd25,8'd25,1,2'b11,4'd9,"CMD_ARITH_9_mul");
apply_test(8'd25,8'd55,1,2'b11,4'd10,"CMD_ARITH_10_mul");
apply_test(8'd6,-8'd8,1,2'b11,4'd12,"SIGNED_SUB_(+)_(-)))");
apply_test(-8'd123,8'd2,1,2'b11,4'd11,"SIGNED_ADD_(-)+(+)");
apply_test(8'd74,8'd46,1,3'b100,4'd1,"DEFAULT_INP_VALID");
apply_test(8'd255,8'd246,1,2'bxx,4'd14,"CMD>4'd12");
apply_test(8'd255,8'd255,1,2'b11,4'd0,"MAX_ADD");
apply_test(8'd255,8'd255,1,2'b11,4'd2,"MAX_ADD_CIN");
  end
endtask

task test_logical();
  begin
apply_test(8'd25,8'd15,1,2'b11,4'd0,"CMD_LOGIC_0");
apply_test(8'd25,8'd13,1,2'b11,4'd1,"CMD_LOGIC_1");
apply_test(8'd25,8'd19,1,2'b11,4'd2,"CMD_LOGIC_2");
apply_test(8'd45,8'd55,1,2'b11,4'd3,"CMD_LOGIC_3");
apply_test(8'd52,8'd155,1,2'b11,4'd4,"CMD_LOGIC_4");
apply_test(8'd56,8'd73,1,2'b11,4'd5,"CMD_LOGIC_5");
apply_test(8'd87,8'd23,1,2'b01,4'd6,"CMD_LOGIC_6_01");
apply_test(8'd64,8'd48,1,2'b11,4'd6,"CMD_LOGIC_6_11");
apply_test(8'd66,8'd26,1,2'b10,4'd7,"CMD_LOGIC_7_10");
apply_test(8'd23,8'd43,1,2'b11,4'd7,"CMD_LOGIC_7_11");
apply_test(8'd90,8'd76,1,2'b01,4'd8,"CMD_LOGIC_8_01");
apply_test(8'd95,8'd12,1,2'b11,4'd8,"CMD_LOGIC_8_11");
apply_test(8'd65,8'd98,1,2'b01,4'd9,"CMD_LOGIC_9_01");
apply_test(8'd55,8'd75,1,2'b11,4'd9,"CMD_LOGIC_9_11");
apply_test(8'd60,8'd76,1,2'b10,4'd10,"CMD_LOGIC_10_10");
apply_test(8'd55,8'd66,1,2'b11,4'd10,"CMD_LOGIC_10_11");
apply_test(8'd43,8'd11,1,2'b10,4'd11,"CMD_LOGIC_11_10");
apply_test(8'd76,8'd67,1,2'b11,4'd11,"CMD_LOGIC_11_11");
apply_test(8'd31,8'd73,1,2'b11,4'd12,"CMD_LOGIC_12");
apply_test(8'd75,8'd205,1,2'b11,4'd12,"CMD_LOGIC_12_err");
apply_test(8'd87,8'd55,1,2'b11,4'd13,"CMD_LOGIC_13");
apply_test(8'd23,8'd125,1,2'b11,4'd13,"CMD_LOGIC_13_err");
apply_test(8'd25,8'd15,1,2'b00,4'd0,"CMD_LOGIC_0_00");
apply_test(8'd25,8'd15,1,2'b01,4'd0,"CMD_LOGIC_0_01");
apply_test(8'd25,8'd15,1,2'b10,4'd0,"CMD_LOGIC_0_10");

apply_test(8'd25,8'd15,1,2'b00,4'd1,"CMD_LOGIC_1_00");
apply_test(8'd25,8'd15,1,2'b01,4'd1,"CMD_LOGIC_1_01");
apply_test(8'd25,8'd15,1,2'b10,4'd1,"CMD_LOGIC_1_10");

apply_test(8'd25,8'd15,1,2'b00,4'd2,"CMD_LOGIC_2_00");
apply_test(8'd25,8'd15,1,2'b01,4'd2,"CMD_LOGIC_2_01");
apply_test(8'd25,8'd15,1,2'b10,4'd2,"CMD_LOGIC_2_10");

apply_test(8'd25,8'd55,1,2'b00,4'd3,"CMD_LOGIC_3_00");
apply_test(8'd25,8'd55,1,2'b01,4'd3,"CMD_LOGIC_3_01");
apply_test(8'd25,8'd55,1,2'b10,4'd3,"CMD_LOGIC_3_10");

apply_test(8'd25,8'd155,1,2'b00,4'd4,"CMD_LOGIC_4_00");
apply_test(8'd25,8'd155,1,2'b01,4'd4,"CMD_LOGIC_4_01");
apply_test(8'd25,8'd155,1,2'b10,4'd4,"CMD_LOGIC_4_10");

apply_test(8'd25,8'd55,1,2'b00,4'd5,"CMD_LOGIC_5_00");
apply_test(8'd25,8'd55,1,2'b01,4'd5,"CMD_LOGIC_5_01");
apply_test(8'd25,8'd55,1,2'b10,4'd5,"CMD_LOGIC_5_10");

apply_test(8'd25,8'd55,1,2'b00,4'd6,"CMD_LOGIC_6_00");
apply_test(8'd25,8'd55,1,2'b10,4'd6,"CMD_LOGIC_6_10");

apply_test(8'd25,8'd55,1,2'b00,4'd7,"CMD_LOGIC_7_00");
apply_test(8'd25,8'd55,1,2'b01,4'd7,"CMD_LOGIC_7_01");

apply_test(8'd25,8'd55,1,2'b00,4'd8,"CMD_LOGIC_8_00");
apply_test(8'd25,8'd55,1,2'b10,4'd8,"CMD_LOGIC_8_10");

apply_test(8'd25,8'd55,1,2'b00,4'd9,"CMD_LOGIC_9_00");
apply_test(8'd25,8'd55,1,2'b10,4'd9,"CMD_LOGIC_9_10");

apply_test(8'd25,8'd55,1,2'b00,4'd10,"CMD_LOGIC_10_00");
apply_test(8'd25,8'd55,1,2'b01,4'd10,"CMD_LOGIC_10_01");

apply_test(8'd25,8'd55,1,2'b00,4'd11,"CMD_LOGIC_11_00");
apply_test(8'd25,8'd55,1,2'b01,4'd11,"CMD_LOGIC_11_01");

apply_test(8'd31,8'd25,1,2'b00,4'd12,"CMD_LOGIC_12_00");
apply_test(8'd31,8'd25,1,2'b01,4'd12,"CMD_LOGIC_12_01");
apply_test(8'd31,8'd25,1,2'b10,4'd12,"CMD_LOGIC_12_10");

apply_test(8'd25,8'd205,1,2'b00,4'd12,"CMD_LOGIC_12_ERR_00");
apply_test(8'd25,8'd205,1,2'b01,4'd12,"CMD_LOGIC_12_ERR_01");
apply_test(8'd25,8'd205,1,2'b10,4'd12,"CMD_LOGIC_12_ERR_10");

apply_test(8'd25,8'd55,1,2'b00,4'd13,"CMD_LOGIC_13_00");
apply_test(8'd25,8'd55,1,2'b01,4'd13,"CMD_LOGIC_13_01");
apply_test(8'd25,8'd55,1,2'b10,4'd13,"CMD_LOGIC_13_10");

apply_test(8'd25,8'd125,1,2'b00,4'd13,"CMD_LOGIC_13_ERR_00");
apply_test(8'd25,8'd125,1,2'b01,4'd13,"CMD_LOGIC_13_ERR_01");
apply_test(8'd25,8'd125,1,2'b10,4'd13,"CMD_LOGIC_13_ERR_10");
//other cases
apply_test(8'd255,8'd255,1,2'b11,4'd15,"All inputs high");
apply_test(8'd0,8'd0,1,2'b00,4'd0,"All inputs low");
apply_test(8'd25,8'd55,1,2'b10,4'd5,"Random inputs");
apply_test(8'd255,8'd246,1,2'b11,4'd14,"CMD>4'd13");
apply_test(8'd55,8'd2,1,2'b11,4'd12,"CMD_LOGIC12_010");
apply_test(8'd95,8'd0,1,2'b11,4'd12,"CMD_LOGIC_12_000");

apply_test(8'd95,8'd3,1,2'b11,4'd12,"CMD_LOGIC_12_011");
apply_test(8'd95,8'd4,1,2'b11,4'd12,"CMD_LOGIC_12_100");
apply_test(8'd95,8'd6,1,2'b11,4'd12,"CMD_LOGIC_12_110");
apply_test(8'd95,8'd7,1,2'b11,4'd12,"CMD_LOGIC_12_111");
//apply_test(8'd95,8'dxxx,1,2'b11,4'd12,"CMD_LOGIC_12_xxx");
apply_test(8'd95,8'd0,1,2'b11,4'd13,"CMD_LOGIC_13_000");
apply_test(8'd95,8'd1,1,2'b11,4'd13,"CMD_LOGIC_13_001");
apply_test(8'd95,8'd2,1,2'b11,4'd13,"CMD_LOGIC_13_010");
apply_test(8'd95,8'd3,1,2'b11,4'd13,"CMD_LOGIC_13_011");
apply_test(8'd95,8'd4,1,2'b11,4'd13,"CMD_LOGIC_13_100");
apply_test(8'd95,8'd6,1,2'b11,4'd13,"CMD_LOGIC_13_110");
apply_test(8'd95,8'd7,1,2'b11,4'd12,"CMD_LOGIC_12_111");
apply_test(8'd74,8'd46,1,3'b100,4'd1,"DEFAULT_INP_VALID");
apply_test(8'd255,3'd15,1,2'b11,4'd13,"INVALID_OPB_13");
apply_test(8'd255,3'd15,1,2'b11,4'd12,"INVALID_OPB_12");

  end
endtask

task apply_test(input [7:0]a,input [7:0]b,input c,input [1:0]valid,input [3:0]cm,input [8*80:1]test_name);
begin
opa=a;
opb=b;
cmd=cm;
cin=c;
inp_valid=valid;
test_count=test_count+1;
//first give delay and then compare with dut
if((cm==9 || cm==10) && mode==1 && valid==2'b11)
begin
@(posedge clk);//captures input
opa=a;
opb=b;
@(posedge clk);
@(posedge clk);//compares with the result
end
else
  begin
@(posedge clk); //captures input
@(posedge clk);//compares with the result
@(posedge clk);
  end

if(res_dut==res_ref && cout_dut==cout_ref && oflow_dut==oflow_ref && g_dut==g_ref && e_dut==e_ref && l_dut==l_ref && err_dut==err_ref)
begin
  $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                         test_name, a, b, cm);
                pass_count = pass_count + 1;
            end
 else
 begin
                $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                         test_name, a, b, cm);
                display_mismatch();
                fail_count = fail_count + 1;
end
end
endtask


task display_mismatch;
begin
$display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
end
endtask

endmodule


[arpitanaik@feserver alu_project]$ cat alu_tb.v
// `timescale 1ns / 1ps
`include "alu_ref.v"
//`include "alu.v"
module alu_tb;
  parameter N=8;
  reg [N-1:0] opa, opb;
reg clk, rst, ce, mode, cin;
  reg [(N/2)-1:0] cmd;
reg [1:0]inp_valid;

  wire [2*N-1:0] res_dut;
wire cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut;

  wire [2*N-1:0] res_ref;
wire cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref;

integer pass_count = 0;
integer fail_count = 0;
integer test_count = 0;

// DUT instantiation
  alu #(N) alu1 (
    .OPA(opa),
    .OPB(opb),
    .CIN(cin),
    .CLK(clk),
    .RST(rst),
    .CMD(cmd),
    .CE(ce),
    .MODE(mode),
    .INP_VALID(inp_valid),

    .COUT(cout_dut),
    .OFLOW(oflow_dut),
    .RES(res_dut),

    .G(g_dut),
    .E(e_dut),
    .L(l_dut),
    .ERR(err_dut)
);

// Reference model instantiation
  alu_ref #(N) alu2 (
    .opa(opa),
    .opb(opb),
    .cin(cin),
    .rst(rst),
    .ce(ce),
    .mode(mode),
    .cmd(cmd),

    .res(res_ref),
    .cout(cout_ref),
    .oflow(oflow_ref),
    .inp_valid(inp_valid),

    .g(g_ref),
    .e(e_ref),
    .l(l_ref),
    .err(err_ref)
);

initial
begin
clk=1'b0;
forever #5 clk=~clk;
end

initial
begin
rst=1;ce=1;cin=0;opa=0;opb=0;mode=0;cmd=0;inp_valid=0;
  $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
@(posedge clk)
rst=0;ce=0;
  $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
  @(posedge clk)
rst=0;rst=1;rst=1;
  $display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
@(posedge clk)
$display("Testing all operations starting from MODE=1(Arithmatic)");
rst=0;ce=1;mode=1;
test_arithmatic();

$display("Testing all operations starting from MODE=0(Logical)");
mode=0;
test_logical();

 $display("\n=== TEST SUMMARY ===");
        $display("Total Tests: %0d", test_count);
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

#100;
$finish;
end

task test_arithmatic();
begin
apply_test(8'd25,8'd55,0,2'b11,4'd0,"CMD_ARITH_0");
apply_test(8'd25,8'd55,0,2'b11,4'd1,"CMD_ARITH_1");
apply_test(8'd15,8'd89,1,2'b11,4'd2,"CMD_ARITH_2");
apply_test(8'd67,8'd12,1,2'b11,4'd3,"CMD_ARITH_3");
apply_test(8'd25,8'd255,0,2'b01,4'd4,"CMD_ARITH_4_01");
apply_test(8'd25,8'd255,0,2'b11,4'd4,"CMD_ARITH_4_11");
apply_test(8'd56,8'd255,1,2'b01,4'd5,"CMD_ARITH_5_01");
apply_test(8'd56,8'd255,1,2'b11,4'd5,"CMD_ARITH_5_11");
apply_test(8'd255,8'd84,1,2'b10,4'd6,"CMD_ARITH_6_10");
apply_test(8'd255,8'd84,1,2'b11,4'd6,"CMD_ARITH_6_11");
apply_test(8'd255,8'd56,1,2'b10,4'd7,"CMD_ARITH_7_10");
apply_test(8'd25,8'd65,1,2'b11,4'd7,"CMD_ARITH_7_11");
apply_test(8'd255,8'd25,1,2'b11,4'd8,"CMD_ARITH_8_g");
apply_test(8'd55,8'd95,1,2'b11,4'd8,"CMD_ARITH_8_l");
apply_test(8'd255,8'd255,1,2'b11,4'd8,"CMD_ARITH_8_e");
apply_test(8'd25,8'd25,1,2'b11,4'd9,"CMD_ARITH_9_mul");
apply_test(8'd25,8'd55,1,2'b11,4'd10,"CMD_ARITH_10_mul");
apply_test(-8'd89,-8'd45,1,2'b11,4'd11,"CMD_ARITH_11_signed1-add");
apply_test(-8'd35,-8'd25,1,2'b11,4'd12,"CMD_ARITH_12signed-sub");
apply_test(8'd25,8'd55,0,2'b00,4'd0,"CMD_ARITH_0_00");
apply_test(8'd25,8'd55,0,2'b01,4'd0,"CMD_ARITH_0_01");
apply_test(8'd25,8'd55,0,2'b10,4'd0,"CMD_ARITH_0_10");
apply_test(8'd25,8'd55,0,2'b00,4'd1,"CMD_ARITH_1_00");
apply_test(8'd25,8'd55,0,2'b01,4'd1,"CMD_ARITH_1_01");
apply_test(8'd25,8'd55,0,2'b10,4'd1,"CMD_ARITH_1_10");
apply_test(8'd15,8'd89,1,2'b00,4'd2,"CMD_ARITH_2_00");
apply_test(8'd15,8'd89,1,2'b01,4'd2,"CMD_ARITH_2_01");
apply_test(8'd15,8'd89,1,2'b10,4'd2,"CMD_ARITH_2_10");
apply_test(8'd67,8'd12,1,2'b00,4'd3,"CMD_ARITH_3_00");
apply_test(8'd67,8'd12,1,2'b01,4'd3,"CMD_ARITH_3_01");
apply_test(8'd67,8'd12,1,2'b10,4'd3,"CMD_ARITH_3_10");
apply_test(8'd25,8'd255,0,2'b10,4'd4,"CMD_ARITH_4_10");
apply_test(8'd25,8'd255,0,2'b00,4'd4,"CMD_ARITH_4_00");
apply_test(8'd56,8'd255,1,2'b00,4'd5,"CMD_ARITH_5_00");
apply_test(8'd56,8'd255,1,2'b10,4'd5,"CMD_ARITH_5_10");
apply_test(8'd255,8'd84,1,2'b00,4'd6,"CMD_ARITH_6_00");
apply_test(8'd255,8'd84,1,2'b01,4'd6,"CMD_ARITH_6_01");
apply_test(8'd255,8'd56,1,2'b00,4'd7,"CMD_ARITH_7_00");
apply_test(8'd25,8'd65,1,2'b01,4'd7,"CMD_ARITH_7_01");
apply_test(8'd255,8'd25,1,2'b00,4'd8,"CMD_ARITH_8_00");
apply_test(8'd255,8'd25,1,2'b01,4'd8,"CMD_ARITH_8_01");
apply_test(8'd255,8'd25,1,2'b10,4'd8,"CMD_ARITH_8_10");

apply_test(8'd55,8'd95,1,2'b00,4'd8,"CMD_ARITH_8_00");
apply_test(8'd55,8'd95,1,2'b01,4'd8,"CMD_ARITH_8_01");
apply_test(8'd55,8'd95,1,2'b10,4'd8,"CMD_ARITH_8_10");

apply_test(8'd255,8'd255,1,2'b00,4'd8,"CMD_ARITH_8_00");
apply_test(8'd255,8'd255,1,2'b01,4'd8,"CMD_ARITH_8_01");
apply_test(8'd255,8'd255,1,2'b10,4'd8,"CMD_ARITH_8_10");
apply_test(8'd25,8'd25,1,2'b00,4'd9,"CMD_ARITH_9_00");
apply_test(8'd25,8'd25,1,2'b01,4'd9,"CMD_ARITH_9_01");
apply_test(8'd25,8'd25,1,2'b10,4'd9,"CMD_ARITH_9_10");
apply_test(8'd25,8'd55,1,2'b00,4'd10,"CMD_ARITH_10_00");
apply_test(8'd25,8'd55,1,2'b01,4'd10,"CMD_ARITH_10_01");
apply_test(8'd25,8'd55,1,2'b10,4'd10,"CMD_ARITH_10_10");
apply_test(-8'd89,-8'd45,1,2'b00,4'd11,"CMD_ARITH_11_00");
apply_test(-8'd89,-8'd45,1,2'b01,4'd11,"CMD_ARITH_11_01");
apply_test(-8'd89,-8'd45,1,2'b10,4'd11,"CMD_ARITH_11_10");
apply_test(-8'd35,-8'd25,1,2'b00,4'd12,"CMD_A+RITH_12_00");
apply_test(-8'd35,-8'd25,1,2'b01,4'd12,"CMD_ARITH_12_01");
apply_test(-8'd35,-8'd25,1,2'b10,4'd12,"CMD_ARITH_12_10");
apply_test(8'd255,8'd255,1,2'b11,4'd0,"ADD_with_all_bits_high");
apply_test(8'd127,8'd1,1,2'b11,4'd11,"ADD_signed_overflow");
apply_test(8'd0,8'd0,1,2'b11,4'd1,"Sub_signed_overflow");
apply_test(8'd0,8'd0,1,2'b11,4'd3,"Sub_signed_overflow");
apply_test(8'd0,8'd0,1,2'b11,4'd11,"Sub_signed_overflow");
apply_test(8'd0,8'd1,1,2'b11,4'd11,"Sub_signed_overflow");
apply_test(8'd46,8'd46,1,2'b11,4'd11,"Sub_same_operands");
apply_test(8'd255,8'd0,1,2'b11,4'd2,"cin add_boundary");
apply_test(8'd0,8'd0,1,2'b11,4'd3,"Sub_cin_boundary");
apply_test(8'd255,8'd0,1,2'b11,4'd4,"max_inc_a");
apply_test(8'd0,8'd0,1,2'b11,4'd5,"max_dec_a");
apply_test(8'd255,8'd0,1,2'b11,4'd6,"max_inc_b");
apply_test(8'd0,8'd0,1,2'b11,4'd7,"max_dec_b");
apply_test(8'd255,8'd246,1,2'b11,4'd2,"Add_cin_boundary");
apply_test(8'd25,8'd26,1,2'b11,4'd2,"cout=0");
apply_test(8'd255,8'd246,1,2'b11,4'd14,"CMD>4'd12");
apply_test(8'd255,8'd246,1,2'b11,4'd12,"CMD_ARITH_12_g");
apply_test(8'd25,8'd25,1,2'b11,4'd12,"CMD_ARITH_12_e");
apply_test(8'd25,8'd246,1,2'b11,4'd12,"CMD_ARITH_12_l");
apply_test(8'd255,8'd246,1,2'bxx,4'd14,"CMD>4'd12");
apply_test(8'd127,8'd1,1,2'b11,4'd11,"SIGNED_ADD_OVERFLOW");
apply_test(8'd127,8'd255,1,2'b11,4'd12,"SIGNED_SUB_OVERFLOW");
apply_test(-8'd128,-8'd1,1,2'b11,4'd12,"SIGNED_SUB_-127-(-1))");

apply_test(8'd254,8'd254,1,2'b11,4'd9,"CMD_ARITH_9_mul_op_high");
apply_test(8'd251,8'd255,1,2'b11,4'd10,"CMD_ARITH_10_mul_op_high");
apply_test(8'd25,8'd25,1,2'b11,4'd9,"CMD_ARITH_9_mul");
apply_test(8'd25,8'd55,1,2'b11,4'd10,"CMD_ARITH_10_mul");
apply_test(8'd6,-8'd8,1,2'b11,4'd12,"SIGNED_SUB_(+)_(-)))");
apply_test(-8'd123,8'd2,1,2'b11,4'd11,"SIGNED_ADD_(-)+(+)");
apply_test(8'd74,8'd46,1,3'b100,4'd1,"DEFAULT_INP_VALID");
apply_test(8'd255,8'd246,1,2'bxx,4'd14,"CMD>4'd12");
apply_test(8'd255,8'd255,1,2'b11,4'd0,"MAX_ADD");
apply_test(8'd255,8'd255,1,2'b11,4'd2,"MAX_ADD_CIN");
  end
endtask

task test_logical();
  begin
apply_test(8'd25,8'd15,1,2'b11,4'd0,"CMD_LOGIC_0");
apply_test(8'd25,8'd13,1,2'b11,4'd1,"CMD_LOGIC_1");
apply_test(8'd25,8'd19,1,2'b11,4'd2,"CMD_LOGIC_2");
apply_test(8'd45,8'd55,1,2'b11,4'd3,"CMD_LOGIC_3");
apply_test(8'd52,8'd155,1,2'b11,4'd4,"CMD_LOGIC_4");
apply_test(8'd56,8'd73,1,2'b11,4'd5,"CMD_LOGIC_5");
apply_test(8'd87,8'd23,1,2'b01,4'd6,"CMD_LOGIC_6_01");
apply_test(8'd64,8'd48,1,2'b11,4'd6,"CMD_LOGIC_6_11");
apply_test(8'd66,8'd26,1,2'b10,4'd7,"CMD_LOGIC_7_10");
apply_test(8'd23,8'd43,1,2'b11,4'd7,"CMD_LOGIC_7_11");
apply_test(8'd90,8'd76,1,2'b01,4'd8,"CMD_LOGIC_8_01");
apply_test(8'd95,8'd12,1,2'b11,4'd8,"CMD_LOGIC_8_11");
apply_test(8'd65,8'd98,1,2'b01,4'd9,"CMD_LOGIC_9_01");
apply_test(8'd55,8'd75,1,2'b11,4'd9,"CMD_LOGIC_9_11");
apply_test(8'd60,8'd76,1,2'b10,4'd10,"CMD_LOGIC_10_10");
apply_test(8'd55,8'd66,1,2'b11,4'd10,"CMD_LOGIC_10_11");
apply_test(8'd43,8'd11,1,2'b10,4'd11,"CMD_LOGIC_11_10");
apply_test(8'd76,8'd67,1,2'b11,4'd11,"CMD_LOGIC_11_11");
apply_test(8'd31,8'd73,1,2'b11,4'd12,"CMD_LOGIC_12");
apply_test(8'd75,8'd205,1,2'b11,4'd12,"CMD_LOGIC_12_err");
apply_test(8'd87,8'd55,1,2'b11,4'd13,"CMD_LOGIC_13");
apply_test(8'd23,8'd125,1,2'b11,4'd13,"CMD_LOGIC_13_err");
apply_test(8'd25,8'd15,1,2'b00,4'd0,"CMD_LOGIC_0_00");
apply_test(8'd25,8'd15,1,2'b01,4'd0,"CMD_LOGIC_0_01");
apply_test(8'd25,8'd15,1,2'b10,4'd0,"CMD_LOGIC_0_10");

apply_test(8'd25,8'd15,1,2'b00,4'd1,"CMD_LOGIC_1_00");
apply_test(8'd25,8'd15,1,2'b01,4'd1,"CMD_LOGIC_1_01");
apply_test(8'd25,8'd15,1,2'b10,4'd1,"CMD_LOGIC_1_10");

apply_test(8'd25,8'd15,1,2'b00,4'd2,"CMD_LOGIC_2_00");
apply_test(8'd25,8'd15,1,2'b01,4'd2,"CMD_LOGIC_2_01");
apply_test(8'd25,8'd15,1,2'b10,4'd2,"CMD_LOGIC_2_10");

apply_test(8'd25,8'd55,1,2'b00,4'd3,"CMD_LOGIC_3_00");
apply_test(8'd25,8'd55,1,2'b01,4'd3,"CMD_LOGIC_3_01");
apply_test(8'd25,8'd55,1,2'b10,4'd3,"CMD_LOGIC_3_10");

apply_test(8'd25,8'd155,1,2'b00,4'd4,"CMD_LOGIC_4_00");
apply_test(8'd25,8'd155,1,2'b01,4'd4,"CMD_LOGIC_4_01");
apply_test(8'd25,8'd155,1,2'b10,4'd4,"CMD_LOGIC_4_10");

apply_test(8'd25,8'd55,1,2'b00,4'd5,"CMD_LOGIC_5_00");
apply_test(8'd25,8'd55,1,2'b01,4'd5,"CMD_LOGIC_5_01");
apply_test(8'd25,8'd55,1,2'b10,4'd5,"CMD_LOGIC_5_10");

apply_test(8'd25,8'd55,1,2'b00,4'd6,"CMD_LOGIC_6_00");
apply_test(8'd25,8'd55,1,2'b10,4'd6,"CMD_LOGIC_6_10");

apply_test(8'd25,8'd55,1,2'b00,4'd7,"CMD_LOGIC_7_00");
apply_test(8'd25,8'd55,1,2'b01,4'd7,"CMD_LOGIC_7_01");

apply_test(8'd25,8'd55,1,2'b00,4'd8,"CMD_LOGIC_8_00");
apply_test(8'd25,8'd55,1,2'b10,4'd8,"CMD_LOGIC_8_10");

apply_test(8'd25,8'd55,1,2'b00,4'd9,"CMD_LOGIC_9_00");
apply_test(8'd25,8'd55,1,2'b10,4'd9,"CMD_LOGIC_9_10");

apply_test(8'd25,8'd55,1,2'b00,4'd10,"CMD_LOGIC_10_00");
apply_test(8'd25,8'd55,1,2'b01,4'd10,"CMD_LOGIC_10_01");

apply_test(8'd25,8'd55,1,2'b00,4'd11,"CMD_LOGIC_11_00");
apply_test(8'd25,8'd55,1,2'b01,4'd11,"CMD_LOGIC_11_01");

apply_test(8'd31,8'd25,1,2'b00,4'd12,"CMD_LOGIC_12_00");
apply_test(8'd31,8'd25,1,2'b01,4'd12,"CMD_LOGIC_12_01");
apply_test(8'd31,8'd25,1,2'b10,4'd12,"CMD_LOGIC_12_10");

apply_test(8'd25,8'd205,1,2'b00,4'd12,"CMD_LOGIC_12_ERR_00");
apply_test(8'd25,8'd205,1,2'b01,4'd12,"CMD_LOGIC_12_ERR_01");
apply_test(8'd25,8'd205,1,2'b10,4'd12,"CMD_LOGIC_12_ERR_10");

apply_test(8'd25,8'd55,1,2'b00,4'd13,"CMD_LOGIC_13_00");
apply_test(8'd25,8'd55,1,2'b01,4'd13,"CMD_LOGIC_13_01");
apply_test(8'd25,8'd55,1,2'b10,4'd13,"CMD_LOGIC_13_10");

apply_test(8'd25,8'd125,1,2'b00,4'd13,"CMD_LOGIC_13_ERR_00");
apply_test(8'd25,8'd125,1,2'b01,4'd13,"CMD_LOGIC_13_ERR_01");
apply_test(8'd25,8'd125,1,2'b10,4'd13,"CMD_LOGIC_13_ERR_10");
//other cases
apply_test(8'd255,8'd255,1,2'b11,4'd15,"All inputs high");
apply_test(8'd0,8'd0,1,2'b00,4'd0,"All inputs low");
apply_test(8'd25,8'd55,1,2'b10,4'd5,"Random inputs");
apply_test(8'd255,8'd246,1,2'b11,4'd14,"CMD>4'd13");
apply_test(8'd55,8'd2,1,2'b11,4'd12,"CMD_LOGIC12_010");
apply_test(8'd95,8'd0,1,2'b11,4'd12,"CMD_LOGIC_12_000");

apply_test(8'd95,8'd3,1,2'b11,4'd12,"CMD_LOGIC_12_011");
apply_test(8'd95,8'd4,1,2'b11,4'd12,"CMD_LOGIC_12_100");
apply_test(8'd95,8'd6,1,2'b11,4'd12,"CMD_LOGIC_12_110");
apply_test(8'd95,8'd7,1,2'b11,4'd12,"CMD_LOGIC_12_111");
//apply_test(8'd95,8'dxxx,1,2'b11,4'd12,"CMD_LOGIC_12_xxx");
apply_test(8'd95,8'd0,1,2'b11,4'd13,"CMD_LOGIC_13_000");
apply_test(8'd95,8'd1,1,2'b11,4'd13,"CMD_LOGIC_13_001");
apply_test(8'd95,8'd2,1,2'b11,4'd13,"CMD_LOGIC_13_010");
apply_test(8'd95,8'd3,1,2'b11,4'd13,"CMD_LOGIC_13_011");
apply_test(8'd95,8'd4,1,2'b11,4'd13,"CMD_LOGIC_13_100");
apply_test(8'd95,8'd6,1,2'b11,4'd13,"CMD_LOGIC_13_110");
apply_test(8'd95,8'd7,1,2'b11,4'd12,"CMD_LOGIC_12_111");
apply_test(8'd74,8'd46,1,3'b100,4'd1,"DEFAULT_INP_VALID");
apply_test(8'd255,3'd15,1,2'b11,4'd13,"INVALID_OPB_13");
apply_test(8'd255,3'd15,1,2'b11,4'd12,"INVALID_OPB_12");

  end
endtask

task apply_test(input [7:0]a,input [7:0]b,input c,input [1:0]valid,input [3:0]cm,input [8*80:1]test_name);
begin
opa=a;
opb=b;
cmd=cm;
cin=c;
inp_valid=valid;
test_count=test_count+1;
//first give delay and then compare with dut
if((cm==9 || cm==10) && mode==1 && valid==2'b11)
begin
@(posedge clk);//captures input
opa=a;
opb=b;
@(posedge clk);
@(posedge clk);//compares with the result
end
else
  begin
@(posedge clk); //captures input
@(posedge clk);//compares with the result
@(posedge clk);
  end

if(res_dut==res_ref && cout_dut==cout_ref && oflow_dut==oflow_ref && g_dut==g_ref && e_dut==e_ref && l_dut==l_ref && err_dut==err_ref)
begin
  $display("[PASS] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                         test_name, a, b, cm);
                pass_count = pass_count + 1;
            end
 else
 begin
                $display("[FAIL] %s: OPA=0x%h OPB=0x%h CMD=0x%h",
                         test_name, a, b, cm);
                display_mismatch();
                fail_count = fail_count + 1;
end
end
endtask


task display_mismatch;
begin
$display("  DUT: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_dut, cout_dut, oflow_dut, g_dut, e_dut, l_dut, err_dut);

$display("  REF: RES=0x%h COUT=%b OFLOW=%b G=%b E=%b L=%b ERR=%b",
         res_ref, cout_ref, oflow_ref, g_ref, e_ref, l_ref, err_ref);
end
endtask

endmodule
