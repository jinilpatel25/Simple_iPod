`default_nettype none
module edge_detector(CLK_50M,second_clock,reset,start); // borrowed from Chu textbook. Added register to remove the glitch

input logic CLK_50M, second_clock,reset;
output logic start;

logic delay_reg;

always_ff @(posedge CLK_50M or negedge reset) begin
if(~reset) begin
delay_reg <= 1'b0;
end
else begin
delay_reg <= second_clock;
end
end

always_ff @(posedge CLK_50M) begin
start <= ~delay_reg & second_clock;
end
endmodule 

