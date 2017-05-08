//
//  BeaconRegionManager.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-07.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"
#import <CoreLocation/CoreLocation.h>

@protocol SetCameraDelegate <NSObject>
- (void)setCameraValue:(Camera *)camera;
- (NSDictionary *)getPlistSettingForCameraID:(NSString *)cameraID;
@end

@protocol BeaconDelegate <NSObject>

- (void)enterBeaconRegion:(NSString *)beaconId proximity:(CLProximity)proximity;
- (void)exitBeaconRegion:(NSString *)beaconId;

@end

@interface BeaconRegionManager : NSObject <BeaconDelegate>
@property (nonatomic, weak) id <SetCameraDelegate> delegate;
- (instancetype)initWithCameras:(NSDictionary *)allCameras;
@end
