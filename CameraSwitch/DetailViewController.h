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

@protocol DetailDelegate <NSObject>
- (void)addBeacon:(NSString *)beaconId;
- (void)savePlistSettings:(NSDictionary *)dict forCameraId:(NSString *)cameraId;
- (void)updateWidgeData:(NSDictionary *)dict forCameraId:(NSString *)cameraId;
- (void)setCameraValue:(Camera *)camera;
@end

@protocol CameraValueDelegate <NSObject>

- (void)cameraValuesChanged:(Camera *)camera;
- (void)proximitySettingChanged:(NSInteger)camera;

@end

@interface DetailViewController : UIViewController <NestCameraManagerDelegate, CameraValueDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id <DetailDelegate> delegate;
- (void)initWithCamera:(Camera *)camera andSetting:(NSDictionary *)settings;

@end

