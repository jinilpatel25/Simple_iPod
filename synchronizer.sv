module synchronizer(async_sig,outclk,out_sync_sig,clr,vcc);
input logic async_sig, outclk;
input logic vcc;
output logic out_sync_sig;
logic fdc_0_out;
logic fdc_1_out;
logic fdc_2_out;
logic fdc_3_out;
input logic clr;

flip fdc_0(vcc,async_sig,fdc_0_out,fdc_1_out);
flip fdc_1(fdc_3_out,outclk,fdc_1_out,clr);
flip fdc_2(fdc_0_out,outclk,fdc_2_out,clr);
flip fdc_3(fdc_2_out,outclk,fdc_3_out,clr);

assign out_sync_sig = fdc_3_out;

endmodule
