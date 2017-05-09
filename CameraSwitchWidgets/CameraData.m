//
//  CameraData.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "CameraData.h"

@interface CameraData()
@end

@implementation CameraData

- (instancetype)initWithCameraID:(NSString *)cameraID cameraName:(NSString *)cameraName cameraProximitySetting:(NSInteger)cameraProximitySetting
{
    self = [super init];
    if (self) {
        _cameraID = cameraID;
        _cameraName = cameraName;
        _cameraProximitySetting = cameraProximitySetting;
    }
    return self;
}

- (void)setCameraProximitySetting:(NSInteger)cameraProximitySetting {
    _cameraProximitySetting = cameraProximitySetting;
    [self.delegate newCameraProximitySetting:self];
}

@end
