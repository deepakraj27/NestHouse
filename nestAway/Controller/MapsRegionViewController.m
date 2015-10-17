//
//  MapsRegionViewController.m
//  nestAway
//
//  Created by deepakraj murugesan on 17/10/15.
//  Copyright © 2015 deepakraj murugesan. All rights reserved.
//
#define kAlertVeiwSettings 2

#import "MapsRegionViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import "MBProgressHUD.h"
#import "WebServices.h"
#import "Reachability.h"
#import "DetailViewController.h"

@import GoogleMaps;

@interface MapsRegionViewController ()<GMSMapViewDelegate, CLLocationManagerDelegate>{
    GMSMapView *mapView_;
    CLLocationCoordinate2D userLocation ;
    CLLocation *currentLocation;
    NSTimer *locateTimer;
    NSString* lat;
    NSString*lng;
    NSString* mapTitle;
    NSString* subLocation;
    
    NSString * housestypes;
    NSString * idvalue;
    NSString * titleValue;
    NSString * bedcount;
    NSString * bhkcount;
    NSString * localAddress;
    NSString * genderPref;
    NSString * adressvalue;
    NSString * rentvalue;
    NSString* imageURLValue;

}
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong)NSDictionary *locationDictionary;
@property (nonatomic, strong)NSArray * fetchedLocationArray;


@end

@implementation MapsRegionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // [self mapsViewCalling];
    [self gettingLocation];
    
    
    self.locationDictionary = [[NSDictionary alloc]init];
    
    self.fetchedLocationArray = [[NSArray alloc]init];
    
    locateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerNew) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}


-(void)timerNew{
    if (currentLocation && currentLocation.horizontalAccuracy<100) {
        [self mainAPICall];
        [locateTimer invalidate];
        locateTimer = nil;
    }
}

/*Getting the latitude AND longitude starts here*/
-(void)gettingLocation{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        // If the status is denied or only granted for when in use, display an alert
        if (status == kCLAuthorizationStatusDenied) {
            NSString *title;
            title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
            NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Settings", nil];
            alertView.tag = kAlertVeiwSettings;
            [alertView show];
        }
        // The user has not enabled any location services. Request background authorization.
        else if (status == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    [self.locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    NSLog(@"the location is :%@", [locations lastObject]);
    if (currentLocation.horizontalAccuracy <=50)
    {
        currentLocation = [locations lastObject];
        [self.locationManager stopUpdatingLocation];
        [self mainAPICall];
        [locateTimer invalidate];
        
    }
}


-(BOOL)isConnectedTointernet{
    BOOL status = NO;
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    int networkStatus = reachability.currentReachabilityStatus;
    status = (networkStatus != NotReachable)? YES:NO;
    return status;
    
}


-(void)mainAPICall{
    if (self.isConnectedTointernet) {

        [MBProgressHUD showHUDAddedTo:self.view animated:YES]; /*To display the loading buffer*/
        [[WebServices sharedInstance]apicallForGetMethod:@"ngrok.io" onCompletion:^(NSDictionary *responseData) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES]; /*To stop displaying the loading buffer*/
            self.locationDictionary = responseData;
            self.fetchedLocationArray = self.locationDictionary[@"houses"];
            [self mapsViewCalling];

        }];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Internet Connectivity Issue!" message:@"Please make sure you are connected to the internet" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alertView show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertVeiwSettings) {
        if (buttonIndex == 1) {
            // Send the user to the Settings for this app
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }
    
}

-(void)mapsViewCalling{
    NSLog(@"lat: %f, long: %f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLocation.coordinate.latitude
                                                            longitude:currentLocation.coordinate.longitude
                                                                 zoom:12];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.delegate = self;
    self.view = mapView_;
    NSLog(@"User's location: %@", mapView_.myLocation);
    
    
    //creates a circle...
    userLocation = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    GMSCircle *circ = [GMSCircle circleWithPosition:userLocation
                                             radius:10000];
    circ.fillColor = [UIColor colorWithRed:0.25 green:0 blue:0 alpha:0.05];
    circ.strokeColor = [UIColor redColor];
    circ.strokeWidth = 5;
    circ.map = mapView_;

    
    for (int i=0 ; i<[self.fetchedLocationArray count] ; i++) {
        
        NSMutableDictionary * location = [self.fetchedLocationArray objectAtIndex:i];
        lat  = [location objectForKey:@"lat_double"];
        lng = [location objectForKey:@"long_double"];
        mapTitle = [location objectForKey:@"title"];
        subLocation = [location objectForKey:@"locality"];
        housestypes = [location objectForKey:@"house_type"];
        idvalue = [location objectForKey:@"nestaway_id"];
        titleValue= [location objectForKey:@"title"];
        bedcount= [location objectForKey:@"bed_available_count"];
        bhkcount= [location objectForKey:@"bhk_details"];
        localAddress= [location objectForKey:@"locality"];
        genderPref= [location objectForKey:@"gender"];
        adressvalue= [location objectForKey:@"slug"];
        rentvalue= [location objectForKey:@"min_rent"];
        imageURLValue = [location objectForKey:@"image_url"];

        
        
        CLLocationCoordinate2D position = { [lat doubleValue], [lng doubleValue] };
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [GMSMarker markerImageWithColor:[UIColor purpleColor]];
        marker.title = mapTitle;
        marker.snippet = subLocation;
        marker.appearAnimation = YES;
        marker.flat = YES;
        //marker.snippet = @"";
        marker.map = mapView_;

    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    // your code
    NSLog(@"yes");
    [self performSegueWithIdentifier:@"detailview" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"detailview"])
    {
        DetailViewController *Details = (DetailViewController *)segue.destinationViewController;
        Details.houseType = housestypes;
        Details.nestawayID = idvalue;
        Details.Title = titleValue;
        Details.bedAvailable = bedcount;
        Details.BHK = bhkcount;
        Details.locality = localAddress;
        Details.gender = genderPref;
        Details.address = adressvalue;
        Details.rent = rentvalue;
        Details.imageURL = imageURLValue;
    }
}

@end
