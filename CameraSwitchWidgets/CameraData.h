//
//  CameraData.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CameraData;

@protocol CameraDataDelegate <NSObject>
- (void)newCameraProximitySetting:(CameraData *)cameraData;
@end

@interface CameraData : NSObject
@property (nonatomic) NSInteger cameraProximitySetting;
@property (nonatomic, strong) NSString *cameraName;
@property (nonatomic, strong) NSString *cameraID;
- (instancetype)initWithCameraID:(NSString *)cameraID cameraName:(NSString *)cameraName cameraProximitySetting:(NSInteger)cameraProximitySetting;
@property (nonatomic, weak) id <CameraDataDelegate> delegate;
@end
