module ALU16(s,a,b,o);
    input [3:0] s;     
    input [3:0] a, b;  
    output reg [3:0] o;

always @(*) begin
    case(s)
        4'b0000: o = a + b;
        4'b0001: o = a + b + 1;
        4'b0010: o = a - b;      
        4'b0011: o = a - b - 1;  
        4'b0100: o = a;
        4'b0101: o = a + 1;
        4'b0110: o = a - 1;
        4'b0111: o = a;
        4'b1000: o = a & b;
        4'b1001: o = a | b;
        4'b1010: o = a ^ b;
        4'b1011: o = ~a;
        4'b1100: o = ~(a & b);
        4'b1101: o = ~(a | b);
        4'b1110: o = a >> 1;
        4'b1111: o = a << 1;
        default: o = 0;
    endcase
end
endmodule
