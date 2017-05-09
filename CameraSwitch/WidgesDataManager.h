//
//  WidgesDataManager.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WidgesDataManagerDelegate <NSObject>
- (void)widgesDataChanged:(NSDictionary *)cameraData;
@end

@interface WidgesDataManager : NSObject
@property (nonatomic, weak) id <WidgesDataManagerDelegate> delegate;
- (void)updatingCameraSettingValue:(NSDictionary *)cameraSetting cameraID:(NSString *)cameraID;
- (instancetype)initWithDelegate:(id <WidgesDataManagerDelegate>)delegate;
- (void)cameraSettingDidChanged:(NSNotification *)notif;
@end
