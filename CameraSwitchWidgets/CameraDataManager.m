//
//  CameraDataManager.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "CameraDataManager.h"

@implementation CameraDataManager

- (instancetype)initWithDelegate:(id <CameraDataManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _cameraDatas = [[NSMutableDictionary alloc] init];
        _delegate = delegate;
        [self cameraSettingHasChanged:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cameraSettingHasChanged:)
                                                     name:NSUserDefaultsDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)processCameraData:(NSDictionary *)dict {
    for (NSString *cameraID in dict.allKeys) {
        NSDictionary *cameraDict = [dict objectForKey:cameraID];
        CameraData *cameraData = [[CameraData alloc] initWithCameraID:cameraID cameraName:cameraDict[@"name"] cameraProximitySetting:[cameraDict[@"proximitySetting"] integerValue]];
        [cameraData setDelegate:self];
        [_cameraDatas setValue:cameraData forKey:cameraID];
    }
}

- (NSDictionary *)produceWidgesData {
    NSMutableDictionary *widgesData = [[NSMutableDictionary alloc] init];
    for (CameraData *cameraData in _cameraDatas.allValues) {
        NSDictionary *widgeData = @{@"proximitySetting":[NSNumber numberWithInteger:cameraData.cameraProximitySetting], @"name":cameraData.cameraName};
        [widgesData setValue:widgeData forKey:cameraData.cameraID];
    }
    return widgesData.copy;
}

- (void)cameraSettingHasChanged:(NSNotification *)notif {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.CustomCameraSwitch"];
    NSDictionary *dict = [defaults dictionaryForKey:@"CameraSettingData"];
    [self processCameraData:dict];
    [self.delegate newCameraData:_cameraDatas.copy];
}

- (void)changeCameraSetting:(CameraData *)cameraData {
    [_cameraDatas setValue:cameraData forKey:cameraData.cameraID];
    NSDictionary *widgesData = [self produceWidgesData];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.CustomCameraSwitch"];
    [sharedDefaults setObject:widgesData forKey:@"CameraSettingData"];
    [sharedDefaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)newCameraProximitySetting:(CameraData *)cameraData {
    [self changeCameraSetting:cameraData];
}

@end
