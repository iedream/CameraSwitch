//
//  PlistManager.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "PlistManager.h"

@interface PlistManager ()
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, strong) NSMutableDictionary *cameraSettings;

@end

@implementation PlistManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *documentsURL = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
        self.fileURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",@"setting"]];
        [self readFromPlistSetting];
    }
    return self;
}

- (void)readFromPlistSetting {
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if(![fileManage fileExistsAtPath:self.fileURL.path]){
        self.cameraSettings = [[NSMutableDictionary alloc] init];
    } else {
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:self.fileURL.path];
        self.cameraSettings = [[NSMutableDictionary alloc] initWithDictionary: dict];
        if (!self.cameraSettings) {
            self.cameraSettings = [[NSMutableDictionary alloc] init];
        }
    }
}

-(void)writeToPlistSetting {
    [_cameraSettings writeToFile:self.fileURL.path atomically:YES];
}

-(NSDictionary *)readSettingForCameraId:(NSString *)cameraId {
    return [_cameraSettings objectForKey:cameraId];
}

-(void)saveSettingChange:(NSDictionary *)dict forCameraId:(NSString *)cameraId {
    [_cameraSettings setValue:dict forKey:cameraId];
    [self writeToPlistSetting];
}

@end
