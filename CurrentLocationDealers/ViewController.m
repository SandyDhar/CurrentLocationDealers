//
//  ViewController.m
//  CurrentLocationDealers
//
//  Created by Sudeepth Dharavasthu on 5/24/16.
//  Copyright © 2016 Sudeepth Dharavasthu. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (nonatomic,strong)NSString *postalcode;
@property (nonatomic,strong)NSArray *dealersArray;
@property (nonatomic,strong)NSMutableArray *dealerName;
@property (nonatomic,weak)NSArray *dealerAddress;
@property (nonatomic,weak)NSOperationQueue* queue;
@property (nonatomic,weak)NSURLSessionDataTask *task;
@end


@implementation ViewController

CLLocationManager *locationManager;

CLGeocoder *geocoder;

CLPlacemark *placemark;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    
    geocoder = [[CLGeocoder alloc] init];
    
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager requestAlwaysAuthorization];
    
    [locationManager requestWhenInUseAuthorization];
   
    [locationManager startUpdatingLocation];

    [self getAPIData];
   
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"didUpdateToLocation: %@", [locations lastObject]);
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation != nil)
    {
        [locationManager stopUpdatingLocation];
    }
    else
    {
        NSLog(@"no cuurent location yet");
    }
    
    NSLog(@"Resolving the Address");
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         if (error == nil && [placemarks count] > 0)
         {
             placemark = [placemarks lastObject];
             //NSLog(@"%@",placemark);
             /*
              self.textLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
              placemark.subThoroughfare, placemark.thoroughfare,
              placemark.postalCode, placemark.locality,
              placemark.administrativeArea,
              placemark.country];
              */
              _postalcode = placemark.postalCode;
              NSLog(@"%@,%@,%@,%@",placemark.subThoroughfare,placemark.locality,placemark.country,placemark.postalCode);
         }
         else
         {
             
             NSLog(@"%@", error.debugDescription);
             
         }
         
     }
     ];
    

}

-(void)getAPIData{
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.edmunds.com/api/dealer/v2/dealers?zipcode=%@&radius=%@&fmt=json&api_key=ycwedw68qast829zx7sn9jnq",self.postalcode,@"30"]];
    NSLog(@"%@",url);
    
    // attempt the request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                        timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    NSError *reqError;
    NSURLResponse *urlResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&reqError];
    
    // parse `returnedData` here
    if (data.length > 0 && reqError == nil)
    {
        
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                 error:NULL];
        self.dealersArray = jsonData[@"dealers"];
        
        self.dealerName = [[NSMutableArray alloc]init];
        for (id item in self.dealersArray){
            if (item[@"name"] != nil)
            {
                [self.dealerName addObject:item[@"name"]];
               // NSLog(@"%@",self.dealerName);
            }
            else{
                NSLog(@"could'nt find the names");
            }
            if (item[@"address"] != nil){
                NSDictionary *address = item[@"address"];
                self.dealerAddress = address[@"street"];
                //NSLog(@"%@",self.dealerAddress);
                // NSLog(@"%@",address[@"city"]);
            }
            else{
                NSLog(@"could'nt find the address");
            }
            
        }
        
    }
    
    
    
    //    NSURLSession *session = [NSURLSession sharedSession];
    //    self.task = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:
    //                                                    @"https://api.edmunds.com/api/dealer/v2/dealers?zipcode=%@&radius=%@&fmt=json&api_key=ycwedw68qast829zx7sn9jnq",
    //                                                    @"01609",@"10"]]
    //      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    //
    //
    //
    //          if (data.length > 0 && error == nil)
    //          {
    //
    //              NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
    //                                                                       options:kNilOptions
    //                                                                         error:NULL];
    //
    //
    //
    //              self.dealersDictionary = jsonData[@"dealers"];
    //
    //
    //
    //              for (id item in self.dealersDictionary){
    //                  if (item[@"name"] != nil){
    //                      self.dealerName = item[@"name"];
    //                      NSLog(@"%@",self.dealerName);
    //                     }
    //                  else{
    //                      NSLog(@"could'nt find the names");
    //                  }
    //                  if (item[@"address"] != nil){
    //                      NSDictionary *address = item[@"address"];
    //                      self.dealerAddress = address[@"street"];
    //                      //NSLog(@"%@",self.dealerAddress);
    //                      // NSLog(@"%@",address[@"city"]);
    //                  }
    //                  else{
    //                      NSLog(@"could'nt find the address");
    //                  }
    //
    //              }
    //             // [self.tableView reloadData];
    //
    //          }
    //
    //      }
    //     ];
    //
    //   [self.task resume];
}


-(NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%ld sudeewwww",(long)_dealerName.count);
    return self.dealerName.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    // NSLog(@"%ld",(long)indexPath.row);
    // NSLog(@"%ld",(unsigned long)self.dealerName.count);
    cell.textLabel.text = self.dealerName[indexPath.row];
    return cell;
}

@end
