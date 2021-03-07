module flip(d,c,q,clr);
input logic d,c,clr;
output logic q;
always_ff @ (posedge c, posedge clr) begin
if(clr) q = 1'b0;
else q <= d;
end
endmodule
