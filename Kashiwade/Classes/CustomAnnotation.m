//
//  CustomAnnotation.m
//  Kashiwade
//
//  Created by LoopSessions on 2015/09/26.
//  Copyright (c) 2015年 LoopSessions. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)coordinate2D newTitle:(NSString *)strTitle newSubTitle:(NSString *)strSubTitle type:(int)type
{
	self = [super self];
	if (self != nil) {
		_coordinate = coordinate2D;
		_title = strTitle;
		_subtitle = strSubTitle;
        _type = type;
	}
	return self;
}

@end
