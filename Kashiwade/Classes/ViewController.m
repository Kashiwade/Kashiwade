//
//  ViewController.m
//  Kashiwade
//
//  Created by LoopSessions on 2015/09/26.
//  Copyright (c) 2015年 LoopSessions. All rights reserved.
//

#import "ViewController.h"
#import "PlayViewController.h"

@interface ViewController ()
{
	MKMapView *_mapView;
	CLLocationManager *_locationManager;
}
@end

@implementation ViewController

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
	
	self.view.backgroundColor = [UIColor lightGrayColor];
	
	CGFloat fWidth = [[UIScreen mainScreen] bounds].size.width;
	CGFloat fHeight = [[UIScreen mainScreen] bounds].size.height;
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	// !!!: iOS8
	if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[_locationManager requestWhenInUseAuthorization];
		
		[_locationManager startUpdatingLocation];
	}
	
	
	_mapView = [[MKMapView alloc] init];
	_mapView.frame = CGRectMake(0.0, 0.0, fWidth, fHeight);
	_mapView.delegate = self;
	_mapView.showsUserLocation = YES;  // ユーザの現在地を表示するように設定
	[self.view addSubview:_mapView];
	
	// 縮尺
	MKCoordinateRegion coordinateRegion = _mapView.region;
//	coordinateRegion.center = coordinate;
	coordinateRegion.span.latitudeDelta = 0.5;
	coordinateRegion.span.longitudeDelta = 0.5;
	[_mapView setRegion:coordinateRegion animated:NO];
	
	for (int i = 0; i < [ARRAY_GMS_MARKER_TITLE count]; i++) {
		[self createPin:LATITUDE[i] longitude:LONGTIDE[i] title:ARRAY_GMS_MARKER_TITLE[i] subTitle:@""];
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
	[_mapView release];
	_locationManager.delegate = nil;
	[_locationManager release];
	[super dealloc];
}

- (void)createPin:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude title:(NSString *)title subTitle:(NSString *)subTitle
{
	// 経度緯度
	CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
	
	CustomAnnotation *customAnnotation = [[CustomAnnotation alloc] initWithCoordinates:locationCoordinate newTitle:title newSubTitle:subTitle];
	[_mapView addAnnotation:customAnnotation];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	[UIApplication sharedApplication].statusBarHidden = YES;
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	[self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

////////////////////////////////////////////////////////////////
#pragma mark -

// !!!: iOS8
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	if (status == kCLAuthorizationStatusNotDetermined) {
	} else if(status == kCLAuthorizationStatusAuthorizedAlways) {
	} else if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
	}
	NSLog(@"didChangeAuthorizationStatus %d", status);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	CLLocation *location = locations[0];
	NSLog(@"didUpdateLocations %f %f", location.coordinate.latitude, location.coordinate.longitude);
	
	// 表示の中心位置
	CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
	[_mapView setCenterCoordinate:locationCoordinate animated:NO];
	
	[_locationManager stopUpdatingLocation];
}

////////////////////////////////////////////////////////////////
#pragma mark -

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	// 現在地は除外
	if (annotation == mapView.userLocation) {
		return nil;
	}
	
	NSString *identifier = @"Pin";
	MKAnnotationView *annotationView = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (annotationView == nil) {
		annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
	}
 
	// 画像を設定
	annotationView.image = [UIImage imageNamed:@"map_pin"];
	annotationView.canShowCallout = YES;  // この設定でポップアップが出る
	annotationView.annotation = annotation;
	
	// ポップアップ上のボタンの種類を指定（ここがないとタッチできない）
	UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	annotationView.rightCalloutAccessoryView = detailButton;
	
	return annotationView;
}

// tap mark
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	NSLog(@"didSelectAnnotationView");
}

// tap AccessoryControl
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSLog(@"AccessoryControlTapped");
	CustomAnnotation *annotation = (CustomAnnotation *)view.annotation;
	
	int iCnt = 0;
	for (int i = 0; i < [ARRAY_GMS_MARKER_TITLE count]; i++) {
		if ([annotation.title isEqualToString:ARRAY_GMS_MARKER_TITLE[i]]) {
			iCnt = i;
			break;
		}
	}
	
	PlayViewController *pVC = [[[PlayViewController alloc] init] autorelease];
	pVC.iIndex = iCnt;
	[self.navigationController pushViewController:pVC animated:YES];
}

@end
