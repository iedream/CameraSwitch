//
//  DetailViewController.h
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

