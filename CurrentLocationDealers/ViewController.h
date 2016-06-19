//
//  ViewController.h
//  CurrentLocationDealers
//
//  Created by Sudeepth Dharavasthu on 5/24/16.
//  Copyright © 2016 Sudeepth Dharavasthu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>
-(void) getAPIData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

