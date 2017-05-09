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
@property (strong, nonatomic) NSMutableArray *iBeaconArray;
@property (weak, nonatomic) IBOutlet UITableView *beaconTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *proximitySegmentControl;
@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) Camera *camera;
@property (strong, nonatomic) NSTimer *cameraStateDisabledTimer;
@property (nonatomic) BOOL cameraStateSwitchDisabled;
@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (!_cameraStateSwitchDisabled) {
        _isOnSwitch.on = _camera.isStreaming;
        NSLog(@"updating");
    }else {
        NSLog(@"not updating");
    }
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
    [self populateSettingFromPlist];
}

- (NSDictionary *)getPlistData {
    NSMutableDictionary *plistData = [[NSMutableDictionary alloc] init];
    [plistData setValue:_iBeaconArray forKey:@"BeaconArray"];
    [plistData setValue:[NSNumber numberWithInteger:_proximitySegmentControl.selectedSegmentIndex] forKey:@"ProximitySegmentControl"];
    return plistData.copy;
}

- (NSDictionary *)getWidgetData {
    NSMutableDictionary *widgetData = [[NSMutableDictionary alloc] init];
    [widgetData setValue:_camera.cameraName forKey:@"name"];
    [widgetData setValue:[NSNumber numberWithInteger:_proximitySegmentControl.selectedSegmentIndex] forKey:@"proximitySetting"];
    return widgetData.copy;
}

- (void)populateSettingFromPlist {
    NSInteger proximitySetting = [_settings[@"ProximitySegmentControl"] integerValue];
    NSArray *iBeaconArray = _settings[@"BeaconArray"];
    _iBeaconArray = [[NSMutableArray alloc] initWithArray:iBeaconArray];
    [_proximitySegmentControl setSelectedSegmentIndex:proximitySetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CameraValueDelegate Methods

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

- (void)proximitySettingChanged:(NSInteger)proximitySetting {
    [_proximitySegmentControl setSelectedSegmentIndex:proximitySetting];
}

#pragma mark - Managing the detail item

- (void)initWithCamera:(Camera *)camera andSetting:(NSDictionary *)settings{
    if (_camera != camera) {
        _camera = camera;
        
        // Update the view.
        [self configureView];
    }
    if (_settings != settings) {
        _settings = settings;
        
        // Update the view.
        [self populateSettingFromPlist];
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
        if (![_iBeaconArray containsObject:iBeaconUUID]) {
            [_iBeaconArray addObject: iBeaconUUID];
            [self.delegate addBeacon:iBeaconUUID];
            [self.delegate savePlistSettings:[self getPlistData] forCameraId:_camera.cameraId];
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [useiBeacon addAction:submitAction];
    [useiBeacon addAction:cancelAction];
    [self presentViewController:useiBeacon animated:true completion:nil];
}

- (IBAction)segmentValueChanged:(id)sender {
    if (_proximitySegmentControl) {
        _proximitySegmentControl = (UISegmentedControl *)sender;
        [self.delegate savePlistSettings:[self getPlistData] forCameraId:_camera.cameraId];
        [self.delegate updateWidgeData:[self getWidgetData] forCameraId:_camera.cameraId];
    }
}

- (IBAction)cameraStateChanged:(id)sender {
    _cameraStateSwitchDisabled = YES;
    _camera.isStreaming = _isOnSwitch.on;
    [self.delegate setCameraValue:_camera];
    self.cameraStateDisabledTimer =[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(cameraStateDisabledTimerEnd) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer: self.cameraStateDisabledTimer forMode: NSDefaultRunLoopMode];
}

- (void)cameraStateDisabledTimerEnd {
    _cameraStateSwitchDisabled = NO;
    [self.cameraStateDisabledTimer invalidate];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _iBeaconArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BeaconCell"];
    }
    NSString *iBeaconID = _iBeaconArray[indexPath.row];
    cell.textLabel.text = iBeaconID;
    return cell;
}

@end
