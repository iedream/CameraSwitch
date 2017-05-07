//
//  MasterViewController.m
//  CameraSwitch
//
//  Created by Catherine Zhao on 2017-05-06.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "NestConnectViewController.h"
#import "NestAuthManager.h"
#import "Camera.h"
#import <CoreLocation/CoreLocation.h>
#import "PlistManager.h"
#import "BeaconRegionManager.h"

@interface MasterViewController ()

@property NSMutableDictionary *cameras;
@property NestStructureManager *nestStructureManager;
@property NestCameraManager *nestCameraManager;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) PlistManager *plistManager;
@property (nonatomic, strong) BeaconRegionManager *beaconRegionManager;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    self.timer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1.0 target:self selector:@selector(presentConnectView) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer: self.timer forMode: NSDefaultRunLoopMode];
    self.cameras = [[NSMutableDictionary alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }

}

- (void)presentConnectView {
    // If it isn't a valid session -- bring the user to the nest connect screen
    if (![[NestAuthManager sharedManager] isValidSession]) {
        NestConnectViewController *nestConnectViewController = [[NestConnectViewController alloc] init];
        [self presentViewController:nestConnectViewController animated:YES completion:nil];
    }else {
        self.nestStructureManager = [[NestStructureManager alloc] init];
        [self.nestStructureManager setDelegate:self];
        [self.nestStructureManager initialize];
        self.nestCameraManager = [[NestCameraManager alloc] init];
        [self.nestCameraManager setDelegate:self];
        self.plistManager = [[PlistManager alloc] init];
        self.beaconRegionManager = [[BeaconRegionManager alloc] initWithCameras:_cameras];
        self.beaconDelegate = self.beaconRegionManager;
        [self.beaconRegionManager setDelegate:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startMonitoriginBeaconRegions:(NSArray *)cameraArray {
    for (Camera *camera in cameraArray) {
        NSDictionary *plistSetting = [self.plistManager readSettingForCameraId:camera.cameraId];
        NSArray *iBeacons = plistSetting[@"BeaconArray"];
        for (NSString *iBeaconId in iBeacons) {
            [self addBeaconRegion:iBeaconId];
        }
    }
}

- (void)addBeaconRegion:(NSString *)beaconId {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:beaconId];
    CLBeaconRegion *geoRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:beaconId];
    geoRegion.notifyEntryStateOnDisplay = YES;
    geoRegion.notifyOnEntry = YES;
    geoRegion.notifyOnExit = YES;
    [self.locationManager startMonitoringForRegion:geoRegion];
    [self.locationManager startRangingBeaconsInRegion:geoRegion];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Camera *camera = self.cameras.allValues[indexPath.row];
        NSDictionary *plistSettings = [self.plistManager readSettingForCameraId:camera.cameraId];
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        controller.navigationItem.title = camera.cameraName;
        [controller initWithCamera:camera andSetting:plistSettings];
        self.delegate = controller;
        controller.delegate = self;
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cameras.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Camera *camera = self.cameras.allValues[indexPath.row];
    cell.textLabel.text = camera.cameraName;
    return cell;
}

#pragma mark - NestStructureManagerDelegate Methods

/**
 * Called from NestStructureManagerDelegate, lets the
 * controller know the structure has changed.
 * @param structure The updated structure.
 */
- (void)structureUpdated:(NSDictionary *)structure
{
    if ([structure objectForKey:@"cameras"]) {
        NSArray *cameras = [structure objectForKey:@"cameras"];
        [self subscriptionToCamera:cameras];
        [self startMonitoriginBeaconRegions:cameras];
    }
}

- (void)subscriptionToCamera:(NSArray*)cameras {
    for (Camera *camera in cameras) {
        [self.nestCameraManager beginSubscriptionForCamera:camera];
    }
}

#pragma mark - NestCameraManagerDelegate Methods

/**
 * Called from NestThermostatManagerDelegate, lets us know thermostat
 * information has been updated online.
 * @param camera The updated thermostat object.
 */
- (void)cameraValuesChanged:(Camera *)camera
{
    [self.cameras setValue:camera forKey:camera.cameraId];
    [self.tableView reloadData];
    [self.delegate cameraValuesChanged:camera];
}

#pragma mark - BeaconDelegate Methods

- (void)setCameraValue:(Camera *)camera {
    [self.nestCameraManager saveChangesForCamera:camera];
}

- (NSDictionary *)getPlistSettingForCameraID:(NSString *)cameraID {
    return [self.plistManager readSettingForCameraId:cameraID];
}

#pragma mark - DetailDelegate Methods

-(void)addBeacon:(NSString *)beaconId {
    [self addBeaconRegion:beaconId];
}

- (void)savePlistSettings:(NSDictionary *)dict forCameraId:(NSString *)cameraId {
    [self.plistManager saveSettingChange:dict forCameraId:cameraId];
}

#pragma mark - iBeaconRegionDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    for (CLBeacon *beacon in beacons) {
        [self.beaconDelegate enterBeaconRegion:beacon.proximityUUID.UUIDString proximity:beacon.proximity];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(nonnull NSError *)error {
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(nonnull CLRegion *)region {
    [self.locationManager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(nonnull CLRegion *)region {
    
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    [manager startRangingBeaconsInRegion:beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    CLBeaconRegion *beaconRegion = (CLBeaconRegion *)region;
    [manager stopRangingBeaconsInRegion:beaconRegion];
    [self.beaconDelegate exitBeaconRegion:beaconRegion.proximityUUID.UUIDString];
}


@end
