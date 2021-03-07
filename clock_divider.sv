module clock_divider(input_clock,output_clock,divider,reset);
input input_clock;
input [31:0] divider; // this variable gets 50MHz/required frequency value
input reset;
logic [31:0] count = 32'b0;  // set count value to 0 for LED control because in module instantiation reset is set to 1 so we need to initialize thge count
output logic output_clock;

always_ff @ (posedge input_clock) begin
if(~reset) begin 
count = 32'b0;
end
else if (count >= divider-1) begin // set count to zero once it reaches divider value
count = 32'b0;
end
else begin
count = count + 1;
end
if(count<(divider>>1)) begin // make output = 1 if the counter is between 0 and divider/2 
output_clock <= 1'b1;
end
else begin
output_clock <= 1'b0; // make output = 0 if counter is between divider/2 and divider to complete one cycle of output square wave
end
end
endmodule
