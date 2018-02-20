//
//  MapViewController.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/20/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "MapViewController.h"
#import "Place.h"

@interface MapViewController () <MKMapViewDelegate>
@property (nonatomic, assign) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mapView setRegion:self.boundingRegion animated:YES];
    self.mapView.delegate = self;
    
    MKCompassButton *compassButton = [MKCompassButton compassButtonWithMapView:self.mapView];
    compassButton.compassVisibility = MKFeatureVisibilityVisible;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:compassButton];
    self.mapView.showsCompass = NO;
    
    
    [self.mapView registerClass:[MKPinAnnotationView class] forAnnotationViewWithReuseIdentifier:@"Pin"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
   
    if (self.mapItemList.count == 1) {
        MKMapItem *mapItem = self.mapItemList[0];
        
        self.title = mapItem.name;
        
     
        Place *annotation = [[Place alloc] init];
        annotation.coordinate = mapItem.placemark.location.coordinate;
        annotation.title = mapItem.name;
        annotation.url = mapItem.url;
        [self.mapView addAnnotation:annotation];
        
      
        [self.mapView selectAnnotation:self.mapView.annotations[0] animated:YES];
    } else {
        self.title = @"All Places";
        
        
        for (MKMapItem *mapItem in self.mapItemList) {
            Place *annotation = [[Place alloc] init];
            annotation.coordinate = mapItem.placemark.location.coordinate;
            annotation.title = mapItem.name;
            
            annotation.url = mapItem.url;
            
            [self.mapView addAnnotation:annotation];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mapView removeAnnotations:self.mapView.annotations];
}


#pragma mark - MKMapViewDelegate

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    NSLog(@"Failed to load the map: %@", error);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
    if ([annotation isKindOfClass:[Place class]]) {
        annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin" forAnnotation:annotation];
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        
        Place *annotation = [annotationView annotation];
        if (annotation.url != nil) {
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
        }
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[Place class]]) {
        Place *annotation = [view annotation];
        NSURL *url = annotation.url;    // User tapped the annotation's Info Button.
        if (url != nil) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                // Completed openURL.
            }];
        }
    }
}

@end
