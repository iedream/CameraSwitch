//
//  DetailViewController.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Camera.h"
#import "NestCameraManager.h"
#import <CoreLocation/CoreLocation.h>

@protocol IndividualDelegate <NSObject>

- (void)addBeacon:(NSString *)beaconId;
- (void)setCameraValue:(Camera *)camera;

@end

@protocol GeneralDelegate <NSObject>

- (void)cameraValuesChanged:(Camera *)camera;
- (void)enterBeaconRegion:(NSString *)beaconId proximity:(CLProximity)proximity;
- (void)exitBeaconRegion:(NSString *)beaconId;

@end

@interface DetailViewController : UIViewController <NestCameraManagerDelegate, GeneralDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Camera *camera;
@property (nonatomic, weak) id <IndividualDelegate> delegate;


@end

