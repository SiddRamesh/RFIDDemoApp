//
//  Place.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/20/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//


#import <MapKit/MapKit.h>

@interface Place : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *url;

@end
