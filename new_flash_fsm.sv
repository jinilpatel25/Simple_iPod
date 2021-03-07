`default_nettype none
module new_flash_fsm(CLK_50M,start_fsm,in_address,flash_mem_readdata,flash_mem_waitrequest,flash_mem_readdatavalid,reset,flash_mem_read,flash_mem_address,flash_mem_byteenable,readdata,finish);

input logic CLK_50M, start_fsm, reset, flash_mem_waitrequest, flash_mem_readdatavalid;
input logic [31:0] flash_mem_readdata;
input logic [22:0] in_address;

output logic flash_mem_read, finish;
output logic [3:0] flash_mem_byteenable;
output logic [22:0] flash_mem_address;
output logic [31:0] readdata;

logic [9:0] state, next_state;
logic  strobe_read; 
logic [31:0] read_reg;
  
parameter idle = 10'b000_0000_0_0_0; //000
parameter read_state = 10'b001_0000_0_1_0; //082 
parameter wait_read = 10'b010_0000_0_0_0; // 100
parameter strobe_read_state = 10'b011_0000_1_0_0; //184
parameter task_finished = 10'b100_0000_0_0_1; // 201

assign finish = state[0]; //high when readdata is availble to sample. 
assign flash_mem_read = state[1]; //comminucates with flash memory to start reading
assign strobe_read = state[2]; // when high capture flash_mem_readdata 
assign flash_mem_byteenable = state[6:3]; 

assign flash_mem_address = in_address; //provides address to flash memory to from where we need to read
assign readdata = read_reg;

always_ff @(posedge CLK_50M, negedge reset) begin
if(~reset) begin
state <= idle;
end
else begin
state <= next_state; 
end
end

always @(*) begin
next_state = state;
    case(state)
    idle: if(start_fsm) begin
          next_state = read_state;
          end
	       else begin
	       next_state = idle;
			 end
    read_state: if(flash_mem_waitrequest) begin //if flash waitrequest is high stay in read state else goto wait state
                next_state = read_state;
                end
                else begin
                next_state = wait_read;    
                end
    wait_read: if(flash_mem_readdatavalid) begin //wait for flash memory to proceess data and provid output. When flash_mem_readdatavalid is high data is available to capture 
               next_state = strobe_read_state;
               end
               else begin
               next_state = wait_read;    
               end
    strobe_read_state: next_state = task_finished; //capture available flash_mem_readdata signal
    task_finished: next_state = idle; //make finish signal high so audio fsm can start sampling
    default: next_state = 10'bx;
    endcase
end

always_ff @(posedge strobe_read or negedge reset) begin //capturing flash_mem_readdata signal
    if(~reset) begin
    read_reg <= 32'b0;
    end
    else begin
    read_reg <= flash_mem_readdata;
    end
end
endmodule