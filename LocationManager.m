//
//  LocationManager.m
//
//  Copyright (c) 2012 Symbiotic Software LLC. All rights reserved.
//

#import "LocationManager.h"

static id sharedInstance;

@interface LocationManager ()
{
	CLLocation *currentLocation;
}

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)applicationWillTerminate:(NSNotification *)notification;

@end

@implementation LocationManager

@synthesize locationManager;

+ (void)initialize
{
	if(sharedInstance == nil)
	{
		sharedInstance = [[LocationManager alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self release];
}

+ (LocationManager *)sharedManager
{
	return (LocationManager *)sharedInstance;
}

- (void)updateCurrentLocation
{
	if(self.locationManager == nil)
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate = self;
	[self.locationManager startUpdatingLocation];
}

- (CLLocation *)currentLocation
{
	return currentLocation;
}

#pragma mark - Internal Methods

- (void)dealloc
{
	[currentLocation release];
	[self.locationManager setDelegate:nil];
	self.locationManager = nil;
	[super dealloc];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{	
	NSTimeInterval interval;
	BOOL update = YES;
	
	if(self.currentLocation != nil)
	{
		// Don't update if this was from the same startUpdatingLocation request
		interval = [newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp];
		if(interval < 3.0)
			update = NO;
	}
	
	[self.locationManager stopUpdatingLocation];
	
	if(update)
	{
		[currentLocation release];
		currentLocation =  [newLocation retain];
		[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NOTIFICATION_LOCATION_UPDATE object:self]];
	}
}

@end
