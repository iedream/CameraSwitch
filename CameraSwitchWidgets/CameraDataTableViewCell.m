//
//  CameraDataTableViewCell.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "CameraDataTableViewCell.h"

@interface CameraDataTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *cameraNameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *cameraProximitySegmentControl;

@end

@implementation CameraDataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCameraData:(CameraData *)cameraData {
    _cameraData = cameraData;
    [_cameraNameLabel setText:_cameraData.cameraName];
    [_cameraProximitySegmentControl setSelectedSegmentIndex:_cameraData.cameraProximitySetting];
}

- (IBAction)cameraProximitySettingValueChanged:(id)sender {
    [_cameraData setCameraProximitySetting:_cameraProximitySegmentControl.selectedSegmentIndex];
}

@end
