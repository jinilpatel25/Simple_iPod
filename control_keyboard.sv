`default_nettype none
module control_keyboard(CLK_50M, play, reverse, kbd_received_ascii_code);

input logic CLK_50M;
input logic [7:0] kbd_received_ascii_code;

parameter character_B =8'h42;
parameter character_lowercase_b= 8'h62;
parameter character_D =8'h44;
parameter character_lowercase_d= 8'h64;
parameter character_E =8'h45;
parameter character_lowercase_e= 8'h65;
parameter character_F =8'h46;
parameter character_lowercase_f= 8'h66;

parameter is_play = 4'b0001;
parameter is_pause = 4'b0010;
parameter is_forward = 4'b0100;
parameter is_backward = 4'b1000;

output logic play, reverse;

logic to_play, sync_play;
logic to_pause, sync_pause;
logic to_backward, sync_backward;
logic to_forward, sync_forward; 

logic [3:0] check_operation;

assign to_play = (kbd_received_ascii_code == character_E) || (kbd_received_ascii_code == character_lowercase_e);
assign to_pause = (kbd_received_ascii_code == character_D) || (kbd_received_ascii_code == character_lowercase_d);
assign to_forward = (kbd_received_ascii_code == character_F) || (kbd_received_ascii_code == character_lowercase_f);
assign to_backward = (kbd_received_ascii_code == character_B) || (kbd_received_ascii_code == character_lowercase_b);

doublesync sync_to_play_signal
(.indata(to_play),
.outdata(sync_play),
.clk(CLK_50M),
.reset(1'b1));

doublesync sync_to_pause_signal
(.indata(to_pause),
.outdata(sync_pause),
.clk(CLK_50M),
.reset(1'b1));

doublesync sync_to_forward_signal
(.indata(to_forward),
.outdata(sync_forward),
.clk(CLK_50M),
.reset(1'b1));

doublesync sync_to_backward_signal
(.indata(to_backward),
.outdata(sync_backward),
.clk(CLK_50M),
.reset(1'b1));

assign check_operation = {sync_backward, sync_forward, sync_pause, sync_play};

always_ff @(posedge CLK_50M) begin

              case(check_operation)
              is_backward: begin 
                           play <= play;
                           reverse <= 1'b1;
                           end
              is_pause: begin
                        play <= 1'b0;
                        reverse <= reverse;
                        end
              is_play: begin
                       play <= 1'b1;
                       reverse <= reverse;
                       end
              is_forward: begin
                          play <= play;
                          reverse <= 1'b0;
                          end
              default: begin
                       play <= play;
                       reverse <= reverse;
                       end
              endcase
       end
endmodule
