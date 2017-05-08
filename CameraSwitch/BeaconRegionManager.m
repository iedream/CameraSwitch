//
//  BeaconRegionManager.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-07.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "BeaconRegionManager.h"
#import "Camera.h"
#import <CoreLocation/CoreLocation.h>

@interface BeaconRegionManager()

@property (nonatomic, strong) NSDictionary *allCameras;

@end

@implementation BeaconRegionManager

#pragma mark - MasterDelegate Methods

- (instancetype)initWithCameras:(NSDictionary *)allCameras
{
    self = [super init];
    if (self) {
        _allCameras = allCameras;
    }
    return self;
}

- (Camera *)getCameraFromBeaconID:(NSString *)beaconID callEnter:(BOOL)callEnter callExit:(BOOL)callExit{
    NSMutableArray *cameraIDs = [[NSMutableArray alloc] init];
    for (Camera *camera in cameraIDs) {
        NSDictionary *setting = [self.delegate getPlistSettingForCameraID:camera.cameraId];
        NSArray *beaconArray = setting[@"BeaconArray"];
        if ([beaconArray containsObject:beaconID] ) {
            
        }
    }
    return [_allCameras objectForKey:beaconID];
}

- (NSInteger)getProximitySettingFromBeaconID:(NSString *)cameraID {
    NSDictionary *setting = [self.delegate getPlistSettingForCameraID:cameraID];
    return [[setting objectForKey:@"ProximitySegmentControl"] integerValue];
}

- (void)enterBeaconRegion:(NSString *)beaconId proximity:(CLProximity)proximity {
    for (Camera *camera in _allCameras.allValues) {
        NSDictionary *setting = [self.delegate getPlistSettingForCameraID:camera.cameraId];
        NSArray *beaconArray = setting[@"BeaconArray"];
        if ([beaconArray containsObject:beaconId] ) {
            NSInteger proximitySettings = [self getProximitySettingFromBeaconID:camera.cameraId];
            [self didEnterBeaconRegionWithProximity:proximity camera:camera proximitySetting:proximitySettings];
        }
    }
}

- (void)exitBeaconRegion:(NSString *)beaconId {
    for (Camera *camera in _allCameras.allValues) {
        NSDictionary *setting = [self.delegate getPlistSettingForCameraID:camera.cameraId];
        NSArray *beaconArray = setting[@"BeaconArray"];
        if ([beaconArray containsObject:beaconId] ) {
            [self didExitBeaconRegionWithCamera:camera];
        }
    }
}

- (void)didEnterBeaconRegionWithProximity:(CLProximity)proximity camera:(Camera *)camera proximitySetting:(NSInteger)proximitySetting {
    BOOL isStreaming = camera.isStreaming;
    switch (proximitySetting) {
        case 0:
            isStreaming = NO;
            break;
        case 1:
            if (proximity != CLProximityFar) {
                isStreaming = NO;
            } else {
                isStreaming = YES;
            }
            break;
        case 2:
            if (proximity == CLProximityImmediate) {
                isStreaming = NO;
            } else {
                isStreaming = YES;
            }
            break;
        default:
            break;
    }
    if (isStreaming != camera.isStreaming) {
        camera.isStreaming = isStreaming;
        [self.delegate setCameraValue:camera];
    }
}

- (void)didExitBeaconRegionWithCamera:(Camera *)camera {
    camera.isStreaming = YES;
    [self.delegate setCameraValue:camera];
}

@end
