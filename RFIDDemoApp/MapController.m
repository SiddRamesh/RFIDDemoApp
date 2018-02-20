//
//  MapController.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/20/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "MapController.h"
#import "MapViewController.h"

#import <MapKit/MapKit.h>

@interface MapController ()

@property (nonatomic, strong) NSArray<MKMapItem *> *places;

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@property (nonatomic, retain) MKLocalSearch *localSearch;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *viewAllButton;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (nonatomic, retain) UISearchController *searchController;

@end

@implementation MapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.navigationItem.searchController = self.searchController;
    
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MapViewController *mapViewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        
        NSIndexPath *selectedItemPath = self.tableView.indexPathForSelectedRow;
        MKMapItem *mapItem = self.places[selectedItemPath.row];
        
        MKCoordinateRegion region = self.boundingRegion;
        // And center it on the single placemark.
        region.center = mapItem.placemark.coordinate;
        mapViewController.boundingRegion = region;
        
        // Pass the individual place to our map destination view controller.
        mapViewController.mapItemList = @[mapItem];
        
    } else if ([segue.identifier isEqualToString:@"showAll"]) {
        
        mapViewController.boundingRegion = self.boundingRegion;
        
        mapViewController.mapItemList = self.places;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.places.count;
}


#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    MKMapItem *mapItem = self.places[indexPath.row];
    cell.textLabel.text = mapItem.name;
    
    return cell;
}


#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.searchController dismissViewControllerAnimated:YES completion:^() {
        
        // Check if location services are available
        if ([CLLocationManager locationServicesEnabled] == NO) {
            NSLog(@"%s: location services are not available.", __PRETTY_FUNCTION__);
            
            // Display alert to the user.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                           message:@"Location services are not enabled on this device. Please enable location services in Settings."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:nil];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        // Request "when in use" location service authorization.
        // If authorization has been denied previously, we can display an alert if the user has denied location services previously.
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
            NSLog(@"%s: location services authorization was previously denied by the user.", __PRETTY_FUNCTION__);
            
            // Display alert to the user.
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                           message:@"Location services were previously denied by the user. Please enable location services for this app in Settings."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action) {
                                                                       // Take the user to Settings app to possibly change permission.
                                                                       NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                       [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                                                                   }];
            [alert addAction:settingsAction];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:nil];
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        // Ask for our location.
        self.locationManager.delegate = self;
        [self.locationManager requestLocation];
        
        // When a location is delivered to the location manager delegate, the search will
        // actually take place. See the -locationManager:didUpdateLocations: method.
    }];
}

- (void)startSearch:(NSString *)searchString {
    if (self.localSearch.searching) {
        [self.localSearch cancel];
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.userCoordinate.latitude, self.userCoordinate.longitude);
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(center, 12000, 12000);
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    __typeof(self) weakSelf = self;
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            NSString *errorStr = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
            UIAlertController *alertController =
            [UIAlertController alertControllerWithTitle:@"Could not find any places."
                                                message:errorStr
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
            [alertController addAction:ok];
            
            [weakSelf presentViewController:alertController animated:YES completion:nil];
        } else {
            _places = response.mapItems;
            
            _boundingRegion = response.boundingRegion;
            
            weakSelf.viewAllButton.enabled = weakSelf.places != nil ? YES : NO;
            
            [weakSelf.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil) {
        _localSearch = nil;
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    _places = [NSArray array];
    
    _localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [self.localSearch startWithCompletionHandler:completionHandler];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
   
    CLLocation *userLocation = locations.lastObject;
    self.userCoordinate = userLocation.coordinate;
    
    manager.delegate = nil;
    
    
    [self startSearch:self.searchController.searchBar.text];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
   
}



@end
