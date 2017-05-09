//
//  MasterViewController.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NestStructureManager.h"
#import "NestCameraManager.h"
#import <CoreLocation/CoreLocation.h>
#import "DetailViewController.h"
#import "BeaconRegionManager.h"
#import "WidgesDataManager.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <DetailDelegate, NestStructureManagerDelegate, NestCameraManagerDelegate, CLLocationManagerDelegate, SetCameraDelegate, BeaconDelegate, WidgesDataManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, weak) id <CameraValueDelegate>delegate;
@property (nonatomic, weak) id <BeaconDelegate>beaconDelegate;

@end

