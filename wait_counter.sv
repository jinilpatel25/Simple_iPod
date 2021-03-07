`default_nettype none
module wait_counter(CLK_50M, reset, start_counter, top_count, flag);

input logic CLK_50M, start_counter, reset;
input logic [31:0] top_count; //Upper limit of count
output logic flag;

logic change_flag; //high when count has reached upper limit. This provide stimulus to go to next sample

logic [31:0] count;

always_ff @(posedge CLK_50M or negedge reset) begin
    if(~reset) begin
        count <= 32'b0;
        change_flag <= 1'b0;
    end
   else if(start_counter) begin
        if(count == top_count) begin
            count <= 32'b0;
            change_flag <= 1'b1;
        end
        else begin
            count <= count + 32'b1;
				change_flag <= 1'b0; 
        end
    end
    else begin
        count <= 32'b0;
        change_flag <= 1'b0;
    end
end

always_ff @(posedge CLK_50M) begin //capture flag
flag <= change_flag;
end
endmodule