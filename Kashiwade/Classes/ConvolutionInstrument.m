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
	}
	return self;
}

// mono
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
	AKAudioInput *audioInput = [[AKAudioInput alloc] init];
	[audioInput stringForCSD];
	
	
	NSString *strPathImpulseL = [[NSBundle mainBundle] pathForResource:strImpulseL ofType:@"wav"];
	NSString *strPathImpulseR = [[NSBundle mainBundle] pathForResource:strImpulseR ofType:@"wav"];
	
	AKConvolution *convImpulseL = [[AKConvolution alloc] initWithInput:audioInput impulseResponseFilename:strPathImpulseL];
	AKConvolution *convImpulseR = [[AKConvolution alloc] initWithInput:audioInput impulseResponseFilename:strPathImpulseR];
	
	AKMix *balance = [[AKMix alloc] initWithInput1:convImpulseL input2:convImpulseR balance:_dishWellBalance];
	AKMix *dryWet = [[AKMix alloc] initWithInput1:audioInput input2:balance balance:_dryWetBalance];
	
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

// stereo
- (void)setFiles:(NSString *)strSrc impulse:(NSString *)strImpulse bgm:(NSString *)strBgm
{
	// INPUTS AND CONTROLS =================================================
	_dishWellBalance = [self createPropertyWithValue:0 minimum:0 maximum:1.0];
	_dryWetBalance   = [self createPropertyWithValue:0 minimum:0 maximum:0.1];
	
	// INSTRUMENT DEFINITION ===============================================
	AKAudioInput *audioInput = [[AKAudioInput alloc] init];
	[audioInput stringForCSD];
	
	NSString *strPathImpulse = [[NSBundle mainBundle] pathForResource:strImpulse ofType:@"wav"];
	
	// stereoでたたみ込み
	AKStereoConvolution *convImpulse = [[AKStereoConvolution alloc] initWithInput:audioInput impulseResponseFilename:strPathImpulse];
	// stereo -> mono
	AKMix *mixConvImpulse = [[AKMix alloc] initMonoAudioFromStereoInput:convImpulse];
	
	// LR balance の概念は無し
//	AKMix *balance = [[AKMix alloc] initWithInput1:convImpulseL input2:convImpulseR balance:_dishWellBalance];
	AKMix *dryWet = [[AKMix alloc] initWithInput1:audioInput input2:mixConvImpulse balance:_dryWetBalance];
	
	// AUDIO OUTPUT ========================================================
	[self setAudioOutput:dryWet];
	
	// add
	if (strBgm.length > 0) {
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
