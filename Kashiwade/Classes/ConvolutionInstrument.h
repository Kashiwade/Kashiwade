//
//  ConvolutionInstrument.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface ConvolutionInstrument : AKInstrument {
    AKNote *clapnote;
}

@property AKInstrumentProperty *dishWellBalance;
@property AKInstrumentProperty *dryWetBalance;

@property (readonly) AKAudio *auxilliaryOutput;

- (void)setFiles:(NSString *)strSrc impulseL:(NSString *)strImpulseL impulseR:(NSString *)strImpulseR bgm:(NSString *)strBgm;
- (void)setFiles:(NSString *)strSrc impulse:(NSString *)strImpulse bgm:(NSString *)strBgm;

- (void)prepareclap:(NSString *)strImpulse;
- (void)clap;

@end
