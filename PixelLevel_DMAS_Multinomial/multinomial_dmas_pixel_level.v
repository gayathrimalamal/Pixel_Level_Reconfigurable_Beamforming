`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Indian Institute of Technology Palakkad, India
// Engineer: Gayathri Malamal
// 
// Create Date: 02.12.2019 15:12:13
// Design Name: 
// Module Name: multinomial_dmas_pixel_level
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
module multinomial_dmas_pixel_level( clk,rst,chnl_data,sign,bf_out);

parameter channels=128;	//No. of channels
parameter channel_bits=8;          //For channels=128

parameter pixels=1;	//No. of pixels
parameter datasize=channels;
parameter sqrt_ip_latency=5;

input clk;
input rst;
input signed [1:0]sign;
input signed [15:0]chnl_data;

//DAS
reg signed [16:0]sigma;
reg [channel_bits-1:0] ch_das_cnt,ch_das_cnt_d,ch_das_cnt_d2;

//DMAS
reg signed [1:0]sign_d1;
reg signed [1:0]sign_d2;
reg signed [1:0]sign_d3;
reg signed [1:0]sign_d4;
reg signed [1:0]sign_d5;
//eg signed [1:0]sign_d6;

wire sqrt_out_valid;
reg signed [16:0]sigma_sqrt;
reg signed [16:0]sigma_sum_sqr;

wire [15:0]chnl_dout_sqrt;
//reg  [8:0]chnl_dout_sqrt_sync;
wire signed [8:0]chnl_din_dmas;

reg [channel_bits-1:0]ch_dmas_cnt,ch_dmas_cnt_d;
reg [2:0]compensate_sqrt_latency;

output reg signed [16:0]bf_out;

//Synchronizing sign according to square root latency which is 2
always@(posedge clk) begin
	if(rst) begin
		sign_d1<=2'b1;
		sign_d2<=2'b1;
		sign_d3<=2'b1;
		sign_d4<=2'b1;
		sign_d5<=2'b1;
	//	sign_d6<=2'b1;
	end
	else begin
		sign_d1<=sign;
		sign_d2<=sign_d1;
		sign_d3<=sign_d2;
		sign_d4<=sign_d3;
		sign_d5<=sign_d4;
//		sign_d6<=sign_d5;
	end
end

squareroot dut_sqrroot          (
                            .aclk(clk),                                        // input wire aclk
                            .s_axis_cartesian_tvalid(1'b1),  // input wire s_axis_cartesian_tvalid
                            .s_axis_cartesian_tdata(chnl_data),    // input wire [15 : 0] s_axis_cartesian_tdata
                            .m_axis_dout_tvalid(sqrt_out_valid),            // output wire m_axis_dout_tvalid
                            .m_axis_dout_tdata(chnl_dout_sqrt)              // output wire [15 : 0] m_axis_dout_tdata
                            );
							  
assign chnl_din_dmas=(sign_d5==-1)? -chnl_dout_sqrt[8:0]:chnl_dout_sqrt[8:0]; //sign*abs(sqrt)

always @(posedge clk)
begin
	if(rst) begin
		ch_das_cnt<=0;
		//ch_das_cnt_d<=0;
	end
	else begin
//	if(mode) begin
      if(ch_das_cnt<channels) begin
		ch_das_cnt<=ch_das_cnt+1'b1;
		//ch_das_cnt_d<=ch_das_cnt;
     end
	end
end

always@(posedge clk) begin
         ch_das_cnt_d<=ch_das_cnt;
         ch_das_cnt_d2<=ch_das_cnt_d;
end

always @(posedge clk) 
begin
	if(rst) begin
		compensate_sqrt_latency<=0;
	end
	else if(compensate_sqrt_latency<sqrt_ip_latency+1'b1) 
			compensate_sqrt_latency<=compensate_sqrt_latency+1'b1;
	else
			compensate_sqrt_latency<=compensate_sqrt_latency;
end

always @(posedge clk)
begin
	if(rst) begin
		ch_dmas_cnt<=0;
		ch_dmas_cnt_d<=0;
	end
	else if(compensate_sqrt_latency==sqrt_ip_latency+1'b1) begin
		ch_dmas_cnt<=ch_dmas_cnt+1'b1;
		ch_dmas_cnt_d<=ch_dmas_cnt;
	end
	else begin
		ch_dmas_cnt<=ch_dmas_cnt;
		ch_dmas_cnt_d<=ch_dmas_cnt_d;
	end
end

always @(posedge clk)
begin
	if(rst) begin
			sigma<=0;
	end
	
	else if(ch_das_cnt_d2<channels) begin
			sigma<=sigma+chnl_data;
	end
end
 
always @(posedge clk)
begin
	if(rst)begin
		sigma_sqrt<=0;
		
	end
		
	else begin
			if(ch_dmas_cnt_d<channels) begin
					sigma_sqrt<=sigma_sqrt+chnl_din_dmas;
			end
	end
end

always @(posedge clk) begin
   if(rst) begin
		sigma_sum_sqr<=0;
	end
	else begin
		if (ch_dmas_cnt_d==channels)
			sigma_sum_sqr<=((sigma_sqrt*sigma_sqrt)-sigma)>>>1'b1;
	end
end 

always @(posedge clk) begin
	if(rst) begin
		bf_out<=0;
	end
	
	else begin
	 if(ch_dmas_cnt_d==channels)
			bf_out<=sigma_sum_sqr;
	end
end
 
endmodule

    