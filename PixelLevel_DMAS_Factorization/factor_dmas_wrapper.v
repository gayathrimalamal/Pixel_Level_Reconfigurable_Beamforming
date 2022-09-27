`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// 
// Create Date: 04.12.2019 12:14:16
// Design Name: 
// Module Name: factor DMAS wrapper
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
module memory_wrap(clk,rst,bf_out);

parameter channels=128;	//No. of channels
parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_latency=5;

input clk,rst;
//input mode; //Control signal to select the beamforming mode das/dmas
output signed [16:0]bf_out;
reg signed [15:0] interp_data[0:datasize-1];

initial begin
	$readmemb("cl_interpdata_pixel1_128ch.txt",interp_data);// reading from a text file
end

reg [7:0]j;
reg signed [15:0] rfdata;

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

 factor_dmas  uut (clk,rst,rfdata,bf_out );
 
endmodule
