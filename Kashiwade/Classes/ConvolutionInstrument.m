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
	// INPUTS AND CONTROLS
//	_dishWellBalance = [self createPropertyWithValue:0.0 minimum:0.0 maximum:1.0];
	_dishWellBalance = [self createPropertyWithValue:0.5 minimum:0.0 maximum:1.0];
//	_dryWetBalance   = [self createPropertyWithValue:0.0 minimum:0.0 maximum:0.1];
	_dryWetBalance   = [self createPropertyWithValue:0.01 minimum:0.0 maximum:0.1];
	
	// インパルス応答
	AKAudioInput *audioInput = [[AKAudioInput alloc] init];
	[audioInput stringForCSD];
	
	NSString *strPathImpulse = [[NSBundle mainBundle] pathForResource:strImpulse ofType:@"wav"];
	
	// stereoでたたみ込み
	AKStereoConvolution *convImpulse = [[AKStereoConvolution alloc] initWithInput:audioInput impulseResponseFilename:strPathImpulse];
	
	// LR 各々をMix
	AKMix *mixDryWetL = [[AKMix alloc] initWithInput1:audioInput input2:convImpulse.leftOutput balance:_dryWetBalance];
	AKMix *mixDryWetR = [[AKMix alloc] initWithInput1:audioInput input2:convImpulse.rightOutput balance:_dryWetBalance];
	AKStereoAudio *stereoAudioConvImpulse = [[AKStereoAudio alloc] initWithLeftAudio:mixDryWetL rightAudio:mixDryWetR];
	
	[self setStereoAudioOutput:stereoAudioConvImpulse];
	
	// Sound Effect
	if (strBgm.length > 0) {
		// 無音とSEの AKMix で音量調整を実現
		NSString *strFilePathSilence = [[NSBundle mainBundle] pathForResource:@"NoSound_stereo_44100" ofType:@"wav"];
		AKFileInput *inputSilence = [[AKFileInput alloc] initWithFilename:strFilePathSilence];
		[inputSilence setLoop:YES];
		
		NSString *strFilePathSE = [[NSBundle mainBundle] pathForResource:strBgm ofType:@"wav"];
		AKFileInput *inputSE = [[AKFileInput alloc] initWithFilename:strFilePathSE];
		[inputSE setLoop:YES];
		
		// LR 各々をMix
		AKMix *mixSE_L = [[AKMix alloc] initWithInput1:inputSilence.leftOutput input2:inputSE.leftOutput balance:_dishWellBalance];
		AKMix *mixSE_R = [[AKMix alloc] initWithInput1:inputSilence.rightOutput input2:inputSE.rightOutput balance:_dishWellBalance];
		AKStereoAudio *stereoAudioSE = [[AKStereoAudio alloc] initWithLeftAudio:mixSE_L rightAudio:mixSE_R];
		
		[self setStereoAudioOutput:stereoAudioSE];
	}
	
	/*
	// EXTERNAL OUTPUTS ====================================================
	// After your instrument is set up, define outputs available to others
	_auxilliaryOutput = [AKAudio globalParameter];
	[self assignOutput:_auxilliaryOutput to:dryWet];
	*/
}

// マイク入力
- (void)setAudioInputEnabled:(BOOL)audioInputEnabled
{
	AKSettings.shared.audioInputEnabled = audioInputEnabled;
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (void)prepareclap:(NSString *)strImpulse
{
    AKInstrumentProperty* loopgain = [self createPropertyWithValue:0.08 minimum:0.0 maximum:1.0];
    NSString *file=[[NSBundle mainBundle] pathForResource:@"kashiwade" ofType:@"wav"];
    AKSoundFileTable *fileTable = [[AKSoundFileTable alloc] initWithFilename:file];
    AKStereoSoundFileLooper* filelooper=[AKStereoSoundFileLooper looperWithSoundFile:fileTable];
    filelooper.amplitude=loopgain;
    filelooper.loopMode = [AKStereoSoundFileLooper loopPlaysOnce];
    NSString *strPathImpulse = [[NSBundle mainBundle] pathForResource:strImpulse ofType:@"wav"];
    AKMix *mix = [[AKMix alloc] initMonoAudioFromStereoInput:filelooper];
    
    AKStereoConvolution *convImpulse = [[AKStereoConvolution alloc] initWithInput:mix impulseResponseFilename:strPathImpulse];
    AKInstrument* clapinstument=[[AKInstrument alloc]init];

    [clapinstument setAudioOutput:convImpulse];
    clapnote=[[AKNote alloc] initWithInstrument:clapinstument];
    [AKOrchestra updateInstrument:clapinstument];
}

- (void)clap
{
    [clapnote play];    
}

@end
