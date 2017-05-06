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

#import "NestStructureManager.h"
#import "Camera.h"
#import "NestAuthManager.h"
#import "FirebaseManager.h"

@implementation NestStructureManager

/**
 * Gets the entire structure and converts it to
 * thermostat objects andreturns it as a dictionary.
 */
- (void)initialize
{
    [[FirebaseManager sharedManager] addSubscriptionToURL:@"structures/" withBlock:^(FDataSnapshot *snapshot) {
        [self parseStructure:snapshot.value];
    }];
}

/**
 * Parse the structure and send it back to the delegate
 * @param The structure you want to parse.
 */
- (void)parseStructure:(NSDictionary *)structure
{
    NSArray *thermostats = [self cameraForStructure:structure];
    
    NSMutableDictionary *returnStructure = [[NSMutableDictionary alloc] init];
    
    if (thermostats) {
        [returnStructure setObject:thermostats forKey:@"cameras"];
    }
    
    [self.delegate structureUpdated:returnStructure];
}

/**
 * Create new thermostats for the given structure
 * @param The structure you want to create thermostats for
 * @return The list of thermostats in the structure in an NSArray
 */
- (NSArray *)cameraForStructure:(NSDictionary *)structure
{
    NSString *structureId = [[structure allKeys] objectAtIndex:0];
    NSArray *cameraIds = [[structure objectForKey:structureId] objectForKey:@"cameras"];
    NSString *homeState = [[structure objectForKey:structureId] objectForKey:@"away"];
    BOOL isHome = false;
    if ([homeState isEqualToString:@"home"]) {
        isHome = true;
    }
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    if (!cameraIds || [cameraIds count] == 0) {
        return nil;
    } else {
        for (int i = 0; i < [cameraIds count]; i++) {
            Camera *newCamera = [[Camera alloc] init];
            newCamera.cameraId = [cameraIds objectAtIndex:i];
            newCamera.isHome = isHome;
            [returnArray addObject:newCamera];
        }
    }
    
    return returnArray;
}

@end
