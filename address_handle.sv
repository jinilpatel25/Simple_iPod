`default_nettype none
module address_handle (CLK_50M, Clock_sample, reset, out_address,start_fsm, reverse);

input logic CLK_50M, Clock_sample,reset, reverse;
output logic start_fsm;
output logic [22:0] out_address;

logic [22:0] count;
logic increment_address, decrement_address;
logic reset_count;
logic strobe_address;
logic [7:0] state;

parameter idle = 8'b000_0_0_0_0_0;
parameter pass_address = 8'b001_0_0_1_0_0;
parameter Clock_sample_read_fsm = 8'b101_0_1_0_0_0;
parameter check_count_value = 8'b011_0_0_0_0_0;
parameter increment_count =  8'b010_0_0_0_0_1;
parameter reset_counter = 8'b100_0_0_0_1_0;
parameter decrement_count = 8'b110_1_0_0_0_0;

assign increment_address = state[0]; //increase the counter 
assign reset_count = state[1]; //reset the counter if count has reached maximum value
assign strobe_address = state[2]; //to capture the count value to address value make it high
assign start_fsm = state[3]; //signal that provides stimulus to flash controller fsm
assign decrement_address = state[4];

always_ff @(posedge CLK_50M or negedge reset) begin //counter 
    if (~reset) begin
	     if(~reverse) begin
		  count <= 23'h0;
		  end
		  else begin
		  count <= 23'h7FFFF;
		  end
	 end
	 else if(reset_count && ~reverse) begin
	 count <= 23'h0;
	 end
	 else if(reset_count && reverse) begin
	 count <= 23'h7FFFF;
	 end
    else if(increment_address) begin
    count <= count + 23'h1;
	 end
    else if(decrement_address) begin
    count <= count - 23'h1;	 
    end
end

always @ (posedge CLK_50M or negedge reset) begin
    if(~reset) begin
    state <= idle;    
    end
    else begin
    case(state)
    idle: if(Clock_sample) begin //change address every half of the sampling frequency
          state <= pass_address;
          end
          else begin
          state <= idle;    
          end
    pass_address: state <= Clock_sample_read_fsm; //pass address to flash controller fsm 
	 Clock_sample_read_fsm: state <= check_count_value; // trigger the flash controller fsm
    check_count_value: if(~reverse && count <= (23'h7FFFF-1)) begin //check the value of count and increment if less than last address else reset it
                       state <= increment_count;
                       end
							  else if(reverse && count >= 23'h1) begin
							  state <= decrement_count;
							  end
                       else begin
                       state <= reset_counter;    
                       end
    increment_count: state <= idle; // increment count
	 decrement_count: state <= idle;
    reset_counter: state <= idle; // reset counter when it reached last address
    default: state <= idle;
    endcase
    end
end

always_ff @(posedge strobe_address) begin //capture out address 
    out_address <= count;     
    end
endmodule
