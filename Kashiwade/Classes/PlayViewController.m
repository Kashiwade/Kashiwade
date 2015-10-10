//
//  PlayViewController.m
//  Kashiwade
//
//  Created by LoopSessions on 2015/09/26.
//  Copyright (c) 2015年 LoopSessions. All rights reserved.
//

#import "PlayViewController.h"
#import "AKFoundation.h"
#import "ConvolutionInstrument.h"
#import "AKAudioAnalyzer.h"
//#import "AKAudioOutputPlot.h"

@implementation PlayViewController
{
	ConvolutionInstrument *_conv;
	
	AKPropertySlider *_dryWetSlider;
	AKPropertySlider *_dishStairwellSlider;
//	AKAudioOutputPlot *plot;
	
	BOOL _isPlaying;
    UILabel *labelKashiwade;
    
    int numKashiwade; // todo: 仮 サーバー側のデータベースに置く
}

- (id)init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGFloat fWidth = [[UIScreen mainScreen] bounds].size.width;
	CGFloat fHeight = [[UIScreen mainScreen] bounds].size.height;
	
	/*
    conv = [[ConvolutionInstrument alloc] init];
	[conv setFiles:@"808loop" impulseL:@"bktk-shinjuku-01_03may09_44116mono" impulseR:@"Stairwell"];
    [AKOrchestra addInstrument:conv];
    
    AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithInput:conv.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    [analyzer play];
	*/
	
	
	self.title = ARRAY_GMS_MARKER_TITLE[_iIndex];
	////////////////
	// !!!: [Test] 以下の切り替えで、従来版（mono）と修正版（stereo）の聴き比べが可能
	// mono
//	[self initInstrument:ARRAY_INPUT_FILE[_iIndex] impulseL:ARRAY_IMPULSE_L[_iIndex] impulseR:ARRAY_IMPULSE_R[_iIndex] bgm:ARRAY_BGM[_iIndex]];
	// stereo
	[self initInstrument:ARRAY_INPUT_FILE[_iIndex] impulse:ARRAY_IMPULSE_STEREO[_iIndex] bgm:ARRAY_BGM[_iIndex]];
	////////////////
	
	if ([ARRAY_PLACE_IMAGE_NAME[_iIndex] length] > 0) {
		UIImage *imageBg = [UIImage imageNamed:ARRAY_PLACE_IMAGE_NAME[_iIndex]];
		if (imageBg) {
			UIImageView *imageViewBg = [[UIImageView alloc] init];
			imageViewBg.frame = CGRectMake(0.0, fHeight - imageBg.size.height / imageBg.size.width * fWidth, fWidth, imageBg.size.height / imageBg.size.width * fWidth);
			imageViewBg.image = imageBg;
			[self.view addSubview:imageViewBg];
		}
	}
	
	// stereoの場合、「L」「R」は不要になる
	NSArray *arLabelSubTitle = @[@[@"Dry", @"Wet"], @[@"L", @"R"]];
	UILabel *labelSliderSubTitle[2][2];
	for (int i = 0; i < 2; i++) {
		for (int j = 0; j < 2; j++) {
			labelSliderSubTitle[i][j] = [[UILabel alloc] init];
			[labelSliderSubTitle[i][j] setFrame:CGRectMake(40.0 + (fWidth - 40.0 - 55.0) * j, 160.0 + 95.0 * i, 50.0, 30.0)];
			[labelSliderSubTitle[i][j] setText:arLabelSubTitle[i][j]];
			[labelSliderSubTitle[i][j] setLineBreakMode:NSLineBreakByWordWrapping];
			[labelSliderSubTitle[i][j] setNumberOfLines:0];
			[labelSliderSubTitle[i][j] setTextColor:[UIColor blackColor]];
			[labelSliderSubTitle[i][j] setBackgroundColor:[UIColor clearColor]];
//			[labelSliderSubTitle[i][j] setTextAlignment:NSTextAlignmentCenter];
			[labelSliderSubTitle[i][j] setFont:[UIFont boldSystemFontOfSize:20.0]];
			[self.view addSubview:labelSliderSubTitle[i][j]];
		}
	}
	
	////
	_dryWetSlider = [[AKPropertySlider alloc] init];
	_dryWetSlider.frame = CGRectMake(30.0, 195.0, fWidth - 40.0, 30.0);
//	[_dryWetSlider addTarget:self action:@selector(sliderNBandEQChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_dryWetSlider];
	
	_dishStairwellSlider = [[AKPropertySlider alloc] init];
	_dishStairwellSlider.frame = CGRectMake(30.0, 290.0, fWidth - 40.0, 30.0);
//	[_dishStairwellSlider addTarget:self action:@selector(sliderNBandEQChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_dishStairwellSlider];
	
	UIButton *buttonPlay = [UIButton buttonWithType:UIButtonTypeCustom];
	buttonPlay.tag = 1000;
	[buttonPlay setFrame:CGRectMake(20.0, 80.0, fWidth - 40.0, 40.0)];
	[buttonPlay setBackgroundColor:[UIColor colorWithRed:66.0/255.0 green:148.0/255.0 blue:247.0/255.0 alpha:1.0]];
	[buttonPlay setTitle:@"Start" forState:UIControlStateNormal];
	[buttonPlay addTarget:self action:@selector(buttonPlayAct:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonPlay];
	// 角丸の枠
	buttonPlay.layer.borderColor = [[UIColor whiteColor] CGColor];
	buttonPlay.layer.borderWidth = 2.0;
	buttonPlay.layer.cornerRadius = 6.0;
	buttonPlay.clipsToBounds = YES;
	////
	
	_dryWetSlider.property = _conv.dryWetBalance;
	_dishStairwellSlider.property = _conv.dishWellBalance;
    
    numKashiwade=0;
    labelKashiwade = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 122.0, fWidth-80.0, 30.0)];
    labelKashiwade.textAlignment=NSTextAlignmentRight;
    labelKashiwade.text=[NSString stringWithFormat:@"%d柏手", numKashiwade];
    [self.view addSubview:labelKashiwade];
    
    UIImage *imageKashiwade1 = [UIImage imageNamed:@"clap_1_c.png"];
    UIImage *imageKashiwade2 = [UIImage imageNamed:@"clap_2_c.png"];
    UIButton *buttonKashiwade = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonKashiwade.tag = 1001;
    [buttonKashiwade setFrame:CGRectMake(fWidth - 50.0, 120.0, 30.0, 30.0)];
    [buttonKashiwade setImage:imageKashiwade1 forState:UIControlStateNormal];
    [buttonKashiwade setImage:imageKashiwade2 forState:UIControlStateHighlighted];
    [buttonKashiwade addTarget:self action:@selector(doKashiwade:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonKashiwade];

    /*
	plot = [[AKAudioOutputPlot alloc] init];
	plot.frame = CGRectMake(10, 377, 300, 200);
	[self.view addSubview:plot];
	
    [AKManager addBinding:plot];
	*/
}

// mono
- (void)initInstrument:(NSString *)strSrc impulseL:(NSString *)strImpulseL impulseR:(NSString *)strImpulseR bgm:(NSString *)strBgm
{
	_conv = [[ConvolutionInstrument alloc] init];
	[_conv setFiles:strSrc impulseL:strImpulseL impulseR:strImpulseR bgm:strBgm];
	[AKOrchestra addInstrument:_conv];
	
	/*
//	AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithInput:conv.auxilliaryOutput];
	AKAudioAnalyzer *analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:conv.auxilliaryOutput];
	[AKOrchestra addInstrument:analyzer];
	[analyzer play];
	*/
}

// stereo
- (void)initInstrument:(NSString *)strSrc impulse:(NSString *)strImpulse bgm:(NSString *)strBgm
{
	_conv = [[ConvolutionInstrument alloc] init];
	[_conv setFiles:strSrc impulse:strImpulse bgm:strBgm];
	[AKOrchestra addInstrument:_conv];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	[UIApplication sharedApplication].statusBarHidden = YES;
	[self.navigationController setNavigationBarHidden:NO animated:NO];
	[self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (![self.navigationController.viewControllers containsObject:self]) {
		// Backボタン
		[_conv stop];
		_isPlaying = 0;
	}
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)doKashiwade:(UIButton *)sender
{
    numKashiwade++;
    labelKashiwade.text=[NSString stringWithFormat:@"%d柏手", numKashiwade];
    [_conv clap];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (void)buttonPlayAct:(UIButton *)sender
{
	if (_isPlaying) {
		[_conv stop];
		[sender setTitle:@"Start" forState:UIControlStateNormal];
	} else {
		[_conv play];
		[sender setTitle:@"Stop" forState:UIControlStateNormal];
	}
	_isPlaying ^= 0x01;
}

@end
