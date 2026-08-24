`timescale 1ns/1ps
// ============================================================================
// 1. TOP LEVEL MODULE
// ============================================================================
module Advanced_MultiCycle_Top(
 input clk,
 input reset,

 // Outputs for monitoring
 output prediction_out,
 output flush_out,
 output [31:0] total_branches,
 output [31:0] correct_predictions,
 output [31:0] flush_count);

 // -- Fetch Stage Signals --
 wire actual_branch_fetch;
 wire [3:0] fetch_index;
 wire fetch_valid;
 wire prediction_fetch;
 wire [3:0] history_fetch;

 // -- Resolved (Execute) Stage Signals --
 wire resolved_valid;
 wire resolved_prediction;
 wire resolved_actual;
 wire [3:0] resolved_history;
 wire [3:0] resolved_index;

 // -- Control Signals --
 wire flush;
 wire [3:0] recovery_index;

 branch_pattern_generator gen(
 .clk(clk),
 .reset(reset),
 .flush(flush),
 .recovery_index(recovery_index),
 .branch_actual(actual_branch_fetch),
 .current_index(fetch_index),
 .valid(fetch_valid)
 );

 Advanced_Predictor predictor(
 .clk(clk),
 .reset(reset),
 .valid_in(fetch_valid),
 .prediction(prediction_fetch),
 .history_out(history_fetch),
 .update_en(resolved_valid),
 .update_actual(resolved_actual),
 .update_prediction(resolved_prediction),
 .update_history(resolved_history)
 );

 multi_cycle_pipeline pipe(
 .clk(clk),
 .reset(reset),
 .flush(flush),
 .valid_in(fetch_valid),
 .prediction_in(prediction_fetch),
 .actual_in(actual_branch_fetch),
 .history_in(history_fetch),
 .index_in(fetch_index),
 .valid_out(resolved_valid),
 .prediction_out(resolved_prediction),
 .actual_out(resolved_actual),
 .history_out(resolved_history),
 .index_out(resolved_index)
 );

 flush_controller fc(
 .valid_resolved(resolved_valid),
 .prediction_resolved(resolved_prediction),
 .actual_resolved(resolved_actual),
 .resolved_index(resolved_index),
 .flush(flush),
 .recovery_index(recovery_index)
 );

 accuracy_counter acc(
 .clk(clk),
 .reset(reset),
 .valid_resolved(resolved_valid),
 .prediction(resolved_prediction),
 .actual(resolved_actual),
 .total(total_branches),
 .correct(correct_predictions),
 .flushes(flush_count)
 );

 assign prediction_out = resolved_prediction;
 assign flush_out = flush;
endmodule


// ============================================================================
// 2. ADVANCED PREDICTOR (4-bit History)
// ----------------------------------------------------------------------------
// NOTE: The 16-entry 2-bit prediction table (originally "reg [1:0] pht [0:15]")
// is unrolled into 16 individual registers (p0..p15). Yosys's memory-inference
// pass (mem2reg) cannot cleanly synthesize an array that is BOTH read with a
// variable index in a combinational process AND written with a variable index
// in a separate clocked process -- it throws "Multiple edge sensitive events
// found for this signal!" during the PROC_DFF pass. Unrolling into discrete
// registers with explicit case statements avoids Yosys's memory-array
// inference path entirely.
// ============================================================================
module Advanced_Predictor(
 input clk,
 input reset,

 input valid_in,
 output reg prediction,
 output [3:0] history_out,
 input update_en,
 input update_actual,
 input update_prediction,
 input [3:0] update_history
);
 reg [3:0] ghr;
 reg [1:0] p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15;

 assign history_out = ghr;

 // Combinational read: select counter based on ghr
 always @(*) begin
   case (ghr)
     4'd0:  prediction = p0[1];
     4'd1:  prediction = p1[1];
     4'd2:  prediction = p2[1];
     4'd3:  prediction = p3[1];
     4'd4:  prediction = p4[1];
     4'd5:  prediction = p5[1];
     4'd6:  prediction = p6[1];
     4'd7:  prediction = p7[1];
     4'd8:  prediction = p8[1];
     4'd9:  prediction = p9[1];
     4'd10: prediction = p10[1];
     4'd11: prediction = p11[1];
     4'd12: prediction = p12[1];
     4'd13: prediction = p13[1];
     4'd14: prediction = p14[1];
     4'd15: prediction = p15[1];
     default: prediction = 1'b0;
   endcase
 end

 always @(posedge clk or posedge reset) begin
   if (reset) begin
     ghr <= 4'b0000;
     p0<=2'b10; p1<=2'b10; p2<=2'b10; p3<=2'b10;
     p4<=2'b10; p5<=2'b10; p6<=2'b10; p7<=2'b10;
     p8<=2'b10; p9<=2'b10; p10<=2'b10; p11<=2'b10;
     p12<=2'b10; p13<=2'b10; p14<=2'b10; p15<=2'b10;
   end else begin
     if (update_en && (update_actual != update_prediction)) begin
       ghr <= {update_history[2:0], update_actual};
     end else if (valid_in) begin
       ghr <= {ghr[2:0], prediction};
     end

     if (update_en) begin
       case (update_history)
         4'd0:  p0  <= update_actual ? (p0  < 2'b11 ? p0+1  : p0 ) : (p0  > 2'b00 ? p0-1  : p0 );
         4'd1:  p1  <= update_actual ? (p1  < 2'b11 ? p1+1  : p1 ) : (p1  > 2'b00 ? p1-1  : p1 );
         4'd2:  p2  <= update_actual ? (p2  < 2'b11 ? p2+1  : p2 ) : (p2  > 2'b00 ? p2-1  : p2 );
         4'd3:  p3  <= update_actual ? (p3  < 2'b11 ? p3+1  : p3 ) : (p3  > 2'b00 ? p3-1  : p3 );
         4'd4:  p4  <= update_actual ? (p4  < 2'b11 ? p4+1  : p4 ) : (p4  > 2'b00 ? p4-1  : p4 );
         4'd5:  p5  <= update_actual ? (p5  < 2'b11 ? p5+1  : p5 ) : (p5  > 2'b00 ? p5-1  : p5 );
         4'd6:  p6  <= update_actual ? (p6  < 2'b11 ? p6+1  : p6 ) : (p6  > 2'b00 ? p6-1  : p6 );
         4'd7:  p7  <= update_actual ? (p7  < 2'b11 ? p7+1  : p7 ) : (p7  > 2'b00 ? p7-1  : p7 );
         4'd8:  p8  <= update_actual ? (p8  < 2'b11 ? p8+1  : p8 ) : (p8  > 2'b00 ? p8-1  : p8 );
         4'd9:  p9  <= update_actual ? (p9  < 2'b11 ? p9+1  : p9 ) : (p9  > 2'b00 ? p9-1  : p9 );
         4'd10: p10 <= update_actual ? (p10 < 2'b11 ? p10+1 : p10) : (p10 > 2'b00 ? p10-1 : p10);
         4'd11: p11 <= update_actual ? (p11 < 2'b11 ? p11+1 : p11) : (p11 > 2'b00 ? p11-1 : p11);
         4'd12: p12 <= update_actual ? (p12 < 2'b11 ? p12+1 : p12) : (p12 > 2'b00 ? p12-1 : p12);
         4'd13: p13 <= update_actual ? (p13 < 2'b11 ? p13+1 : p13) : (p13 > 2'b00 ? p13-1 : p13);
         4'd14: p14 <= update_actual ? (p14 < 2'b11 ? p14+1 : p14) : (p14 > 2'b00 ? p14-1 : p14);
         4'd15: p15 <= update_actual ? (p15 < 2'b11 ? p15+1 : p15) : (p15 > 2'b00 ? p15-1 : p15);
       endcase
     end
   end
 end
endmodule


// ============================================================================
// 3. MULTI-CYCLE PIPELINE
// ----------------------------------------------------------------------------
// NOTE: The reset branch originally combined "if (reset || flush)" in a
// block sensitive to "posedge clk or posedge reset". Yosys's PROC_ARST pass
// expects the first branch of an async-sensitive process to correspond
// exactly to the signal(s) in the sensitivity list. Combining an async
// reset with a synchronous flush condition in the same top-level branch
// caused Yosys to throw "Multiple edge sensitive events found for this
// signal!" during PROC_DFF. Splitting them into separate "if (reset) ...
// else if (flush) ..." branches (functionally identical -- both clear all
// registers to zero) resolves this cleanly.
// ============================================================================
module multi_cycle_pipeline(
 input clk,
 input reset,
 input flush,

 input valid_in,
 input prediction_in,
 input actual_in,
 input [3:0] history_in,
 input [3:0] index_in,

 output valid_out,
 output prediction_out,
 output actual_out,
 output [3:0] history_out,
 output [3:0] index_out
);
 reg [2:0] valid_sr;
 reg [2:0] pred_sr;
 reg [2:0] actual_sr;
 reg [3:0] hist_sr [0:2];
 reg [3:0] index_sr [0:2];

 always @(posedge clk or posedge reset) begin
 if (reset) begin
 valid_sr <= 3'b000;
 pred_sr <= 3'b000;
 actual_sr <= 3'b000;
 hist_sr[0] <= 0; hist_sr[1] <= 0; hist_sr[2] <= 0;
 index_sr[0] <= 0; index_sr[1] <= 0; index_sr[2] <= 0;
 end else if (flush) begin
 valid_sr <= 3'b000;
 pred_sr <= 3'b000;
 actual_sr <= 3'b000;
 hist_sr[0] <= 0; hist_sr[1] <= 0; hist_sr[2] <= 0;
 index_sr[0] <= 0; index_sr[1] <= 0; index_sr[2] <= 0;
 end else begin
 valid_sr <= {valid_sr[1:0], valid_in};
 pred_sr <= {pred_sr[1:0], prediction_in};
 actual_sr <= {actual_sr[1:0], actual_in};

 hist_sr[2] <= hist_sr[1]; hist_sr[1] <= hist_sr[0]; hist_sr[0] <= history_in;
 index_sr[2] <= index_sr[1]; index_sr[1] <= index_sr[0]; index_sr[0] <= index_in;
 end
 end

 assign valid_out = valid_sr[2];
 assign prediction_out = pred_sr[2];
 assign actual_out = actual_sr[2];
 assign history_out = hist_sr[2];
 assign index_out = index_sr[2];
endmodule


// ============================================================================
// 4. FLUSH CONTROLLER (latch-free)
// ============================================================================
module flush_controller(
 input valid_resolved,
 input prediction_resolved,
 input actual_resolved,
 input [3:0] resolved_index,
 output reg flush,
 output reg [3:0] recovery_index
);
 always @(*) begin
 // Explicit default assignments prevent synthesis latch inferences
 flush = 1'b0;
 recovery_index = 4'b0000;
 if (valid_resolved && (prediction_resolved != actual_resolved)) begin
 flush = 1'b1;
 if (resolved_index == 4'd10)
 recovery_index = 4'd0;
 else
 recovery_index = resolved_index + 4'd1;
 end
 end
endmodule


// ============================================================================
// 5. BRANCH PATTERN GENERATOR
// ----------------------------------------------------------------------------
// NOTE: "pattern1" was originally a reg with an inline initializer
// ("reg [10:0] pattern1 = 11'b10110101101;") read via a variable bit-select
// ("pattern1[index]") inside a clocked block. This combination -- an
// initialized register read with a variable index -- also triggered the
// Yosys "Multiple edge sensitive events" error. Since the pattern value
// never changes at runtime, it is converted to a "localparam" instead of a
// register. A localparam read at a variable index synthesizes to a simple
// constant-select multiplexer with no clocking involved, avoiding the issue.
// ============================================================================
module branch_pattern_generator(
 input clk,
 input reset,
 input flush,
 input [3:0] recovery_index,
 output reg branch_actual,
 output reg [3:0] current_index,
 output reg valid
);
 localparam [10:0] PATTERN1 = 11'b10110101101;
 reg [3:0] index;

 always @(posedge clk or posedge reset) begin
 if (reset) begin
 index <= 0;
 valid <= 0;
 branch_actual <= 0;
 current_index <= 0;
 end else if (flush) begin
 index <= recovery_index;
 valid <= 0;
 end else begin
 branch_actual <= PATTERN1[index];
 current_index <= index;
 valid <= 1;

 if (index == 10)
 index <= 0;
 else
 index <= index + 1;
 end
 end
endmodule


// ============================================================================
// 6. ACCURACY COUNTER
// ============================================================================
module accuracy_counter(
 input clk,
 input reset,
 input valid_resolved,
 input prediction,
 input actual,
 output reg [31:0] total,
 output reg [31:0] correct,
 output reg [31:0] flushes
);
 always @(posedge clk or posedge reset) begin
 if (reset) begin
 total <= 0;
 correct <= 0;
 flushes <= 0;
 end else if (valid_resolved) begin
 total <= total + 1;
 if (prediction == actual)
 correct <= correct + 1;
 else
 flushes <= flushes + 1;
 end
 end
endmodule
