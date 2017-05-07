//
//  PlistManager.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"

@interface PlistManager : NSObject
-(NSDictionary *)readSettingForCameraId:(NSString *)cameraId;
-(void)saveSettingChange:(NSDictionary *)dict forCameraId:(NSString *)cameraId;
@end
