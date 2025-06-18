module MUL_tb;
reg clk, start;
reg [15:0] data_in;
wire done;
control c1(lda, ldp, ldb, clrp, decb, done, eqz, start, clk);
datapath d1(eqz, lda, ldp, ldb, clrp, decb, clk, data_in);

initial begin
    clk = 0;
    #3 start = 1;
    #500 $finish;
end
always #5 clk = ~clk;

initial begin
    #17 data_in = 17;
    #10 data_in = 5;
end
initial begin
    $monitor($time,"%d  %b",d1.P, done);
    $dumpfile("MUL.vcd");
    $dumpvars(0, MUL_tb);
end

endmodule

module control(output reg lda,ldp,ldb,clrp,decb,done, input eqz,start,clk);
reg [2:0] state;
parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100,S5= 3'b101;

always @(posedge clk) begin
    case (state)
        S0: if(start) state <= S1;
        S1: state <= S2;
        S2: state <= S3;
        S3: #2 if(eqz) state<=S4;
        S4: state <= S4;
        default: state <= S0;
    endcase
end

always @(state) begin
    case (state)
        S0: begin
            #1 lda = 0; ldp = 0; ldb = 0; clrp = 0; decb = 0; done = 0;
        end
        S1: begin
            #1 lda = 1;
        end
        S2: begin
            #1 lda =0; ldb = 1; clrp = 1;
        end
        S3: begin
            #1 ldp = 1; ldb = 0; clrp = 0; decb = 1;
        end
        S4: begin
            #1 done = 1; ldp = 0; ldb = 0; clrp = 0; decb = 0;
        end
    endcase
end
endmodule

module datapath(output eqz, input lda,ldp,ldb,clrp,decb,clk, input[15:0] data_in);
wire [15:0] A,B,P,Y;

pipo p1(.dout(A),.din(data_in),.ld(lda),.clr(1'b0),.clk(clk));
pipo p2(.dout(P),.din(Y),.ld(ldp),.clr(clrp),.clk(clk));
cntr c1(.dout(B),.din(data_in),.ld(ldb),.dec(decb),.clk(clk));
equ e1(.eqz(eqz),.din(B));
adder a1(.sum(Y),.add1(A),.add2(P));

endmodule

module pipo(output reg [15:0] dout, input [15:0] din, input ld, clr, clk);
always @(posedge clk or posedge clr)
    if (clr)
        dout <= 16'b0;
    else if (ld)
        dout <= din;
endmodule

module cntr(output reg [15:0] dout, input [15:0] din, input ld, dec, clk);
always @(posedge clk)
    if (ld)
        dout <= din;
    else if (dec)
        dout <= dout - 1;
endmodule

module equ(output eqz, input [15:0] din);
assign eqz = (din == 16'b0);
endmodule

module adder(output reg[15:0] sum, input [15:0] add1, add2, input clk);
always @(*)
    sum <= add1 + add2;
endmodule