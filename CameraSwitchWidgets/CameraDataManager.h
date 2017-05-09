//
//  CameraDataManager.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CameraData.h"

@protocol CameraDataManagerDelegate <NSObject>
- (void)newCameraData:(NSDictionary *)cameraData;
@end

@interface CameraDataManager : NSObject <CameraDataDelegate>
@property (nonatomic, weak) id <CameraDataManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *cameraDatas;
- (void)changeCameraSetting:(CameraData *)cameraData;
- (instancetype)initWithDelegate:(id <CameraDataManagerDelegate>)delegate;
@end
