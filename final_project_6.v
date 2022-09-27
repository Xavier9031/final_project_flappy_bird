module final_project_6(
	input CLOCK_50,
	input [2:0] BUTTON,     
	input [9:0] SW,	
	output [0:6]	HEX0,HEX1,HEX2,HEX3,  

	// VGA
	output VGA_CLK,   	//	VGA Clock
	output VGA_HS,		//	VGA H_SYNC
	output VGA_VS,		//	VGA V_SYNC
	output VGA_BLANK,		//	VGA BLANK
	output VGA_SYNC,		//	VGA SYNC
	output [3:0] VGA_R,  	//	VGA Red[3:0]
	output [3:0] VGA_G,		//	VGA Green[3:0]
	output [3:0] VGA_B   	//	VGA Blue[3:0]
);

	// reset delay gives some time for peripherals to initialize
	wire DLY_RST;
	Reset_Delay r0(	.iCLK(CLOCK_50),.oRESET(DLY_RST) );


	wire VGA_CTRL_CLK;
	wire AUD_CTRL_CLK;
	wire [3:0]	mVGA_R;
	wire [3:0]	mVGA_G;
	wire [3:0]	mVGA_B;
	wire [9:0]	mCoord_X;
	wire [9:0]	mCoord_Y;

	
	VGA_Audio_PLL 	p1 (	
		.areset(~DLY_RST),
		.inclk0(CLOCK_50),
		.c0(VGA_CTRL_CLK),
		.c1(AUD_CTRL_CLK),
		.c2(VGA_CLK)
	);


	wire [3:0] r, g, b;

	game game(BUTTON[1], BUTTON[0], BUTTON[2], CLOCK_50, mCoord_X, mCoord_Y, r, g, b, HEX0, HEX1, HEX2, HEX3);


	assign mVGA_R = r;
	assign mVGA_G = g;
	assign mVGA_B = b;




	vga u1(
	   .iCLK(VGA_CTRL_CLK),
	   .iRST_N(DLY_RST&SW[9]),	
	   .iRed(mVGA_R),
	   .iGreen(mVGA_G),
	   .iBlue(mVGA_B),
	   // pixel coordinates
	   .px(mCoord_X),
	   .py(mCoord_Y),
	   // VGA Side
	   .VGA_R(VGA_R),
	   .VGA_G(VGA_G),
	   .VGA_B(VGA_B),
	   .VGA_H_SYNC(VGA_HS),
	   .VGA_V_SYNC(VGA_VS),
	   .VGA_SYNC(VGA_SYNC),
	   .VGA_BLANK(VGA_BLANK)
	);


endmodule 