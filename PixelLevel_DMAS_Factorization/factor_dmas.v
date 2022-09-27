`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// Create Date: 29.11.2019 12:10:47
// Design Name: 
// Module Name: factor_dmas
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: G. Malamal and M. R. Panicker, "VLSI architectures for Delay Multiply and Sum Beamforming in Ultrasound Medical Imaging," 
// 2020 International Conference on Signal Processing and Communications (SPCOM), 2020, pp. 1-5, doi: 10.1109/SPCOM50965.2020.9179510.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module factor_dmas(clk,rst,rfdata,bf_out);
   
parameter channels=128;	//No. of channels
parameter channel_bits=8; //For channels=128
parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_ip_latency=5;

input clk;	//clk
input rst;	//rst
input  signed [15:0] rfdata;
//input mode; //Control signal to select the beamforming mode das/dmas
output signed [16:0]bf_out;
reg signed [1:0]sign;

//reg i;
reg [ channel_bits-1:0]j;
reg signed[15:0] chnl_din;

always@(posedge clk) begin
   if(rst) 
			j<=channels+1;
			
	else if(j>0) 
			j<=j-1;
end		
		
always@(posedge clk) begin
   if(rst) begin
		chnl_din<=0;
   	sign<=2'b1;
	end
	else if(j>0) begin
		  if(rfdata<0) begin
					chnl_din<=(~rfdata +1'd1); //Taking absolute of data for sqrt
					sign<=2'b11; //sign=-1
			  end
			  else begin
					chnl_din<=rfdata;
					sign<=2'b1;  //sign=+1
			  end
		 end
    else  begin
			chnl_din<=0;
	end
end

factor_dmas_pixel_level#(channels,channel_bits,pixels,datasize,sqrt_ip_latency ) uut_seqdmas_1pixel  (clk,rst,chnl_din, sign,bf_out);

endmodule

