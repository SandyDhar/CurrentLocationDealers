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
@property (nonatomic,weak)NSDictionary *dealersDictionary;
@property (nonatomic,weak)NSArray *dealerName;
@property (nonatomic,weak)NSArray *dealerAddress;
@property (nonatomic,weak)NSOperationQueue* queue;
@end


@implementation ViewController

CLLocationManager *locationManager;

CLGeocoder *geocoder;

CLPlacemark *placemark;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    
    geocoder = [[CLGeocoder alloc] init];
    
    locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    
    [self getAPIData];
    
    
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocations:(NSArray *)locations
{
    NSLog(@"didUpdateToLocation: %@", [locations lastObject]);
    
    CLLocation *currentLocation = [locations lastObject];
    
    /*
     if (currentLocation != nil) {
     _longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
     _latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
     }
     */
    
   if (currentLocation != nil){
    [locationManager stopUpdatingLocation];
    }
        else
        {
            NSLog(@"no cuurent location yet");
        }
    
    
    // Reverse Geocoding
    
    NSLog(@"Resolving the Address");
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        // NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            /*
             self.textLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
             placemark.subThoroughfare, placemark.thoroughfare,
             placemark.postalCode, placemark.locality,
             placemark.administrativeArea,
             placemark.country];
             */
            _postalcode = placemark.postalCode;
            
           
            
            NSLog(@"%@,%@,%@,%@",placemark.subThoroughfare,placemark.locality,placemark.country,placemark.postalCode);
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
}

-(void)getAPIData{

    
    NSURLSession *session = [NSURLSession sharedSession];
    [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:
                                                    @"https://api.edmunds.com/api/dealer/v2/dealers?zipcode=%@&radius=%@&fmt=json&api_key=ycwedw68qast829zx7sn9jnq",
                                                    @"01609",@"10"]]
      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          
        
          
          if (data.length > 0 && error == nil)
          {
              
              NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:kNilOptions
                                                                         error:NULL];
              
              
              
              self.dealersDictionary = jsonData[@"dealers"];
              
              
              
              for (id item in self.dealersDictionary){
                  if (item[@"name"] != nil){
                      self.dealerName = item[@"name"];
                      NSLog(@"%@",self.dealerName);
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
              [self.tableView reloadData];
              
          }
          
      }
     ];
   
    
}



-(NSInteger)tableView:(UITableView *)tableview numberOfRowsInSection:(NSInteger)section
{
    return self.dealerName.count;
}

    
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
       // if (cell != nil){
            
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
            NSLog(@"%ld",(long)indexPath.row);
    NSLog(@"%ld",(unsigned long)self.dealerName.count);
            cell.textLabel.text = self.dealerName[indexPath.row];
        //}
    
    
    
        
            return cell;
    
    
}

@end
