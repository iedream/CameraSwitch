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

@class DetailViewController;

@interface MasterViewController : UITableViewController <IndividualDelegate, NestStructureManagerDelegate, NestCameraManagerDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, weak) id <GeneralDelegate>delegate;

@end

