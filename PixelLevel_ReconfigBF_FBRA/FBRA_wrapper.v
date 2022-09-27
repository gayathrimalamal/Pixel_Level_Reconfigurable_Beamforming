`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// 
// Create Date: 04.12.2019 09:39:06
// Design Name: 
// Module Name: Wrapper Module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: G. Malamal and M. R. Panicker, "Towards A Pixel-Level Reconfigurable Digital Beamforming Core for Ultrasound Imaging,"
// in IEEE Transactions on Biomedical Circuits and Systems, vol. 14, no. 3, pp. 570-582, June 2020, doi: 10.1109/TBCAS.2020.2983759.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FBRA_wrapper(clk,rst,mode,bf_out);

parameter INFILE="cl_interpdata_pixel1_128ch.txt";
parameter channels=128;	//No. of channels
parameter bit_size=8; //For 128 channels
parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_latency=5;

input clk,rst;
input mode; //Control signal to select the beamforming mode das/dmas
output signed [16:0]bf_out;

reg [bit_size-1:0]j; 
reg signed [15:0] interp_data[0:datasize-1];
reg signed [15:0] rfdata;

initial begin
	$readmemb(INFILE,interp_data);// reading from a text file
end

always@(posedge clk) begin
   if(rst) 
			j<=channels;
			
	else if(j>0) 
			j<=j-1;
end		
		
always@(posedge clk) begin
   if(rst) begin
		rfdata<=0;
   	end
	else if(j>0) begin
			rfdata<=interp_data[j-1];
	end
end

 FBRA#(channels,bit_size,pixels,datasize,sqrt_latency)  uut (clk,rst,mode,rfdata,bf_out );

endmodule

