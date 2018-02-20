//
//  MapViewController.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/20/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property (nonatomic, strong) NSArray *mapItemList;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@end
