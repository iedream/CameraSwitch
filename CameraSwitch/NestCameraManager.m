/**
 *  Copyright 2014 Nest Labs Inc. All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#import "NestCameraManager.h"
#import "NestAuthManager.h"
#import "FirebaseManager.h"

@interface NestCameraManager ()

@end

#define FAN_TIMER_ACTIVE @"fan_timer_active"
#define HAS_FAN @"has_fan"
#define TARGET_TEMPERATURE_F @"target_temperature_f"
#define AMBIENT_TEMPERATURE_F @"ambient_temperature_f"
#define NAME_LONG @"name_long"
#define CAMERA_PATH @"devices/cameras"

@implementation NestCameraManager

/**
 * Sets up a new Firebase connection for the thermostat provided
 * and observes for any change in /devices/thermostats/thermostatId.
 * @param camera The thermostat you want to watch changes for.
 */
- (void)beginSubscriptionForCamera:(Camera *)camera
{
    [[FirebaseManager sharedManager] addSubscriptionToURL:[NSString stringWithFormat:@"devices/cameras/%@/", camera.cameraId] withBlock:^(FDataSnapshot *snapshot) {
        [self updateCamera:camera forStructure:snapshot.value];
    }];
}

/**
 * Parse thermostat structure and put it in the thermostat object.
 * Then send the updated object to the delegate.
 * @param camera The thermostat you wish to update.
 * @param structure The structure you wish to update the thermostat with.
 */
- (void)updateCamera:(Camera *)camera forStructure:(NSDictionary *)structure
{
    if ([structure objectForKey:@"name"]) {
        camera.cameraName = [structure objectForKey:@"name"];
    }
    if ([structure objectForKey:@"is_streaming"]) {
        camera.isStreaming = [[structure objectForKey:@"is_streaming"] boolValue];
    }
    if ([structure objectForKey:@"is_online"]) {
        camera.isOnline = [[structure objectForKey:@"is_online"] boolValue];
    }
    [self.delegate cameraValuesChanged:camera];
}

/**
 * Sets the thermostat values by using the Firebase API.
 * @param thermostat The thermost you wish to save.
 * @see https://www.firebase.com/docs/transactions.html
 */
- (void)saveChangesForCamera:(Camera *)camera
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    [values setValue:[NSNumber numberWithBool:camera.isStreaming] forKey:@"is_streaming"];

    [[FirebaseManager sharedManager] setValues:values forURL:[NSString stringWithFormat:@"%@/%@/", CAMERA_PATH, camera.cameraId]];
}



@end
