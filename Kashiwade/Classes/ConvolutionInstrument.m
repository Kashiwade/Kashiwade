//
//  ConvolutionInstrument.m
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "ConvolutionInstrument.h"

@implementation ConvolutionInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        /*
        // INPUTS AND CONTROLS =================================================
        _dishWellBalance = [self createPropertyWithValue:0 minimum:0 maximum:1.0];
        _dryWetBalance   = [self createPropertyWithValue:0 minimum:0 maximum:0.1];
        
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
        AKFileInput *loop = [[AKFileInput alloc] initWithFilename:file];
        [loop setLoop:YES];
        
//		NSString *dish = [[NSBundle mainBundle] pathForResource:@"dish" ofType:@"wav"];
//		NSString *dish = [[NSBundle mainBundle] pathForResource:@"bktk-shinjuku-01_03may09" ofType:@"wav"];
//		NSString *dish = [[NSBundle mainBundle] pathForResource:@"bktk-shinjuku-01_03may09_44116St" ofType:@"wav"];
		NSString *dish = [[NSBundle mainBundle] pathForResource:@"bktk-shinjuku-01_03may09_44116mono" ofType:@"wav"];
		NSString *well = [[NSBundle mainBundle] pathForResource:@"Stairwell" ofType:@"wav"];
        
        AKConvolution *dishConv;
        dishConv  = [[AKConvolution alloc] initWithInput:loop.leftOutput
                                 impulseResponseFilename:dish];
        
        
        AKConvolution *wellConv;
        wellConv  = [[AKConvolution alloc] initWithInput:loop.rightOutput
                                 impulseResponseFilename:well];
        
        
        AKMix *balance;
        balance = [[AKMix alloc] initWithInput1:dishConv
                                         input2:wellConv
                                        balance:_dishWellBalance];
        
        
        AKMix *dryWet;
        dryWet = [[AKMix alloc] initWithInput1:loop.leftOutput
                                        input2:balance
                                       balance:_dryWetBalance];
        
        // AUDIO OUTPUT ========================================================
        [self setAudioOutput:dryWet];
        
        // EXTERNAL OUTPUTS ====================================================
        // After your instrument is set up, define outputs available to others
        _auxilliaryOutput = [AKAudio globalParameter];
        [self assignOutput:_auxilliaryOutput to:dryWet];
        */
    }
    return self;
}

- (void)setFiles:(NSString *)strSrc impulseL:(NSString *)strImpulseL impulseR:(NSString *)strImpulseR bgm:(NSString *)strBgm
{
	
	// INPUTS AND CONTROLS =================================================
	_dishWellBalance = [self createPropertyWithValue:0 minimum:0 maximum:1.0];
	_dryWetBalance   = [self createPropertyWithValue:0 minimum:0 maximum:0.1];
	
	// INSTRUMENT DEFINITION ===============================================
	/*
//	NSString *file = [AKManager pathToSoundFile:@"808loop" ofType:@"wav"];
	NSString *file = [AKManager pathToSoundFile:strSrc ofType:@"wav"];
	AKFileInput *loop = [[AKFileInput alloc] initWithFilename:file];
	[loop setLoop:YES];
	*/
	AKAudioInput *loop = [[AKAudioInput alloc] init];
	[loop stringForCSD];
	
	
//	NSString *dish = [[NSBundle mainBundle] pathForResource:@"dish" ofType:@"wav"];
//	NSString *dish = [[NSBundle mainBundle] pathForResource:@"bktk-shinjuku-01_03may09" ofType:@"wav"];
//	NSString *dish = [[NSBundle mainBundle] pathForResource:@"bktk-shinjuku-01_03may09_44116St" ofType:@"wav"];
//	NSString *dish = [[NSBundle mainBundle] pathForResource:@"bktk-shinjuku-01_03may09_44116mono" ofType:@"wav"];
	NSString *dish = [[NSBundle mainBundle] pathForResource:strImpulseL ofType:@"wav"];
//	NSString *well = [[NSBundle mainBundle] pathForResource:@"Stairwell" ofType:@"wav"];
	NSString *well = [[NSBundle mainBundle] pathForResource:strImpulseR ofType:@"wav"];
	
	AKConvolution *dishConv;
	dishConv  = [[AKConvolution alloc] initWithInput:loop
							 impulseResponseFilename:dish];
	
	
	AKConvolution *wellConv;
	wellConv  = [[AKConvolution alloc] initWithInput:loop
							 impulseResponseFilename:well];
	
	
	AKMix *balance;
	balance = [[AKMix alloc] initWithInput1:dishConv
									 input2:wellConv
									balance:_dishWellBalance];
	
	
	AKMix *dryWet;
	dryWet = [[AKMix alloc] initWithInput1:loop
									input2:balance
								   balance:_dryWetBalance];
	
	// AUDIO OUTPUT ========================================================
	[self setAudioOutput:dryWet];
	
	
	// add
	if (strBgm.length > 0) {
	//	NSString *fileBg = [AKManager pathToSoundFile:@"carpool_SE" ofType:@"wav"];
		NSString *fileBg = [[NSBundle mainBundle] pathForResource:strBgm ofType:@"wav"];
		AKFileInput *background = [[AKFileInput alloc] initWithFilename:fileBg];
		[background setLoop:YES];
		
		[self setStereoAudioOutput:background];
	}
	
	
	// EXTERNAL OUTPUTS ====================================================
	// After your instrument is set up, define outputs available to others
	_auxilliaryOutput = [AKAudio globalParameter];
	[self assignOutput:_auxilliaryOutput to:dryWet];
}

@end
