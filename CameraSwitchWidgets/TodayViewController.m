//
//  TodayViewController.m
//  CameraSwitchWidgets
//
//  Created by Catherine Zhao on 2017-05-08.
//  Copyright © 2017 Catherine. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "CameraDataManager.h"
#import "CameraDataTableViewCell.h"

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UITableView *widgetsTableView;
@property (strong, nonatomic) CameraDataManager *cameraDataManager;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _cameraDataManager = [[CameraDataManager alloc] initWithDelegate:self];
    _widgetsTableView.delegate = self;
    _widgetsTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

- (void)newCameraData:(NSDictionary *)cameraData {
    [self.widgetsTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cameraDataManager.cameraDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CameraDataTableViewCell *cameraSettingCell = [tableView dequeueReusableCellWithIdentifier:@"CameraSettingCell" forIndexPath:indexPath];
    if (cameraSettingCell == nil) {
        cameraSettingCell = [[CameraDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CameraSettingCell"];
    }
    CameraData *cameraData = _cameraDataManager.cameraDatas.allValues[indexPath.row];
    [cameraSettingCell setCameraData:cameraData];
    return cameraSettingCell;
}

@end
