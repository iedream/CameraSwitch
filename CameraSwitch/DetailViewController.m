//
//  DetailViewController.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "DetailViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *isOnSwitch;
@property (weak, nonatomic) IBOutlet UILabel *isOnlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *isHomeLabel;
@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (strong, nonatomic) NSMutableArray *iBeaconArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *proximitySegmentControl;
@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    _isOnSwitch.on = _camera.isStreaming;
    NSString *isOnlineLabelText = _camera.isOnline ? @"Online" : @"Offline";
    [_isOnlineLabel setText:isOnlineLabelText];
    NSString *isHomeLabelText = _camera.isHome ? @"Home" : @"Away";
    [_isHomeLabel setText:isHomeLabelText];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _iBeaconArray = [[NSMutableArray alloc] init];
    self.beaconTable.delegate = self;
    self.beaconTable.dataSource = self;
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CameraUpdatedDelegate Methods

/**
 * Called from NestThermostatManagerDelegate, lets us know thermostat
 * information has been updated online.
 * @param camera The updated thermostat object.
 */
- (void)cameraValuesChanged:(Camera *)camera
{
    if ([_camera.cameraId isEqualToString: camera.cameraId]) {
        _camera = camera;
        [self configureView];
    }
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(Camera *)camera {
    if (_camera != camera) {
        _camera = camera;
        
        // Update the view.
        [self configureView];
    }
}

- (IBAction)addBeacon:(id)sender {
    UIAlertController *useiBeacon = [UIAlertController alertControllerWithTitle:@"Create iBeacon Range" message:@"Create iBeacon Boundry" preferredStyle:UIAlertControllerStyleAlert];
    [useiBeacon addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter iBeacon UUID";
        textField.clearsOnBeginEditing = YES;
    }];
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *iBeaconUUID = useiBeacon.textFields.firstObject.text;
        [self addBeacon:iBeaconUUID];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [useiBeacon addAction:submitAction];
    [useiBeacon addAction:cancelAction];
    [self presentViewController:useiBeacon animated:true completion:nil];
}

- (void)addIBeacon:(NSString *)iBeaconUUID {
    if (![_iBeaconArray containsObject:iBeaconUUID]) {
        [_iBeaconArray addObject: iBeaconUUID];
        [self.delegate addBeacon:iBeaconUUID];
    }
}

#pragma mark - MasterDelegate Methods

- (void)enterBeaconRegion:(NSString *)beaconId proximity:(CLProximity)proximity {
    BOOL isStreaming = _camera.isStreaming;
    switch (_proximitySegmentControl.selectedSegmentIndex) {
        case 0:
            isStreaming = NO;
            break;
        case 1:
            if (proximity != CLProximityFar) {
                isStreaming = NO;
            } else {
                isStreaming = YES;
            }
        case 2:
            if (proximity == CLProximityImmediate) {
                isStreaming = NO;
            } else {
                isStreaming = YES;
            }
        default:
            break;
    }
    if (isStreaming != _camera.isStreaming) {
        [self.delegate setCameraValue:_camera];
    }
}

- (void)exitBeaconRegion:(NSString *)beaconId {
    _camera.isStreaming = YES;
    [self.delegate setCameraValue:_camera];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _iBeaconArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *iBeaconID = _iBeaconArray[indexPath.row];
    cell.textLabel.text = iBeaconID;
    return cell;
}

@end
