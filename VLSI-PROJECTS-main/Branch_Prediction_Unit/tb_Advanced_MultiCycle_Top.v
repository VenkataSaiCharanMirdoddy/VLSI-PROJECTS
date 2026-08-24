`timescale 1ns/1ps
module tb_Advanced_MultiCycle_Top();
    reg clk;
    reg reset;
    wire prediction_out;
    wire flush_out;
    wire [31:0] total_branches;
    wire [31:0] correct_predictions;
    wire [31:0] flush_count;

    Advanced_MultiCycle_Top uut (
        .clk(clk),
        .reset(reset),
        .prediction_out(prediction_out),
        .flush_out(flush_out),
        .total_branches(total_branches),
        .correct_predictions(correct_predictions),
        .flush_count(flush_count)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        $dumpfile("branch_predictor.vcd");
        $dumpvars(0, tb_Advanced_MultiCycle_Top);

        #50; reset = 0;
        $display("Simulation Started. Waiting for 150 resolved branches...");
        wait(total_branches == 150);

        @(posedge clk);

        $display("\n==================================================");
        $display(" FINAL SIMULATION RESULTS ");
        $display("==================================================");
        $display("Total Branches Resolved : %d", total_branches);
        $display("Correct Predictions     : %d", correct_predictions);
        $display("Total Pipeline Flushes  : %d", flush_count);

        if (total_branches > 0) begin
            $display("Overall Accuracy : %0d%%", (correct_predictions * 100) / total_branches);
        end else begin
            $display("Overall Accuracy : N/A (0 branches)");
        end
        $display("==================================================\n");
        $finish;
    end
endmodule
