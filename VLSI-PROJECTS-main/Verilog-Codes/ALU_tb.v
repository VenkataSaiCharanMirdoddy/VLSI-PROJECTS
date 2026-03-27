module ALU16_tb;
    reg [3:0] s;
    reg [3:0] a, b;
    wire [3:0] o;

    // Instantiate the ALU
    ALU16 uut(.s(s), .a(a), .b(b), .o(o));

    initial begin
        a = 4'b0101; // 5
        b = 4'b0110; // 6

        // Test all ALU operations
        s = 4'b0000; #10;
        s = 4'b0001; #10;
        s = 4'b0010; #10;
        s = 4'b0011; #10;
        s = 4'b0100; #10;
        s = 4'b0101; #10;
        s = 4'b0110; #10;
        s = 4'b0111; #10;
        s = 4'b1000; #10;
        s = 4'b1001; #10;
        s = 4'b1010; #10;
        s = 4'b1011; #10;
        s = 4'b1100; #10;
        s = 4'b1101; #10;
        s = 4'b1110; #10;
        s = 4'b1111; #10;

        #50 $stop;
    end

    // Display values in waveform and console
    initial
        $monitor("%t | s=%b | a=%b | b=%b | o=%b", $time, s, a, b, o);
endmodule
