//
//  WidgesDataManager.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "WidgesDataManager.h"
#import "Camera.h"

@interface WidgesDataManager()
@property (nonatomic, strong)NSMutableDictionary *widgesData;
@end

@implementation WidgesDataManager

- (instancetype)initWithDelegate:(id <WidgesDataManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _widgesData = [[NSMutableDictionary alloc] init];
        _delegate = delegate;
        [self cameraSettingDidChanged:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(cameraSettingDidChanged:)
//                                                     name:NSUserDefaultsDidChangeNotification
//                                                   object:nil];
    }
    return self;
}

- (void)cameraSettingDidChanged:(NSNotification *)notif {
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.CustomCameraSwitch"];
    NSDictionary *data = [sharedDefaults dictionaryForKey:@"CameraSettingData"];
    [self.delegate widgesDataChanged:data];
}

- (void)updatingCameraSettingValue:(NSDictionary *)cameraSetting cameraID:(NSString *)cameraID {
    [_widgesData setValue:cameraSetting forKey:cameraID];
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.CustomCameraSwitch"];
    [sharedDefaults setObject:_widgesData forKey:@"CameraSettingData"];
    [sharedDefaults synchronize];
}

@end
