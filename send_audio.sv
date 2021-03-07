`default_nettype none
module send_audio(CLK_50M, sample_clock_divider, reset, readdata, out_data, finish);

input logic CLK_50M, reset, finish;
input logic [31:0] readdata;
input [31:0] sample_clock_divider;
output logic [7:0] out_data;

logic send_data; //high when when sending data
logic low, up; // controls which sample to send to audio data 
logic [5:0] state;
logic goto_next_sample; //when high you go to another sample
logic [7:0] send_audio_data; 
logic start_counter; //starts counter to get goto_next_sample. Used to control wait time between playing two samples

parameter idle = 6'b00_0000; //00
parameter send_lower = 6'b00_0001; //01
parameter strobe_lower = 6'b00_0101;//05
parameter wait_to_send_upper = 6'b01_1000;//18
parameter send_upper = 6'b00_0010; //02
parameter strobe_upper = 6'b00_0110;//06
parameter wait_upper_finish = 6'b10_1000; //28

assign low = state[0];
assign up = state[1];
assign send_data = state[2];
assign start_counter = state[3];

assign out_data = send_audio_data;

wait_counter wait_for_next_sample(.CLK_50M(CLK_50M),.start_counter(start_counter),.reset(reset),.top_count((sample_clock_divider)>>1),.flag(goto_next_sample));

always_ff @(posedge CLK_50M or negedge reset) begin
    if(~reset) begin
     state <= idle;   
    end
    else begin
        case(state)
        idle: if(finish) begin //stimulus for this fsm. Finish is the output of flash controller fsm which is high when data is captured
            state <= send_lower;
            end
            else begin
            state <= idle;    
            end
        send_lower: state <= strobe_lower; //send first sample
		  strobe_lower: state <= wait_to_send_upper; //capture first same into audio data signal
        wait_to_send_upper: if(goto_next_sample) begin // wait to play next sample
                            state <= send_upper;
                            end
                            else begin
                            state <= wait_to_send_upper;
                            end
        send_upper: state <= strobe_upper; //send second sample 
		  strobe_upper: state <= wait_upper_finish; //capture second same into audio data signal
		  wait_upper_finish: if(goto_next_sample) begin //wait for upper address to play
                            state <= idle;
                            end
                            else begin
                            state <= wait_upper_finish;
                            end
        default: state <= idle;
        endcase
    end
end

always_ff @ (posedge send_data) begin //capture the audio data
    if(low) begin
        send_audio_data <= readdata[15:8];
    end
    else if(up) begin
       send_audio_data <= readdata[31:24];
    end
end
endmodule