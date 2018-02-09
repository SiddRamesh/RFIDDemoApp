//
//  ViewController.m
//  PulsingHaloDemo
//
//  Created by shuichi on 12/5/13.
//  Modified by ShannonChou on 14-7-8
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import "ViewController.h"
#import "PulsingHaloLayer.h"

#define kMaxRadius 200
#define kMaxDuration 10


@interface PulCViewController ()
@property (nonatomic, assign) PulsingHaloLayer *halo;
@property (nonatomic, assign) IBOutlet UIImageView *beaconView;


@property (nonatomic, assign) IBOutlet UISlider *countSlider;
@property (nonatomic, assign) IBOutlet UISlider *radiusSlider;
@property (nonatomic, assign) IBOutlet UISlider *durationSlider;
@property (nonatomic, assign) IBOutlet UISlider *rSlider;
@property (nonatomic, assign) IBOutlet UISlider *gSlider;
@property (nonatomic, assign) IBOutlet UISlider *bSlider;
@property (nonatomic, assign) IBOutlet UILabel *countLabel;
@property (nonatomic, assign) IBOutlet UILabel *radiusLabel;
@property (nonatomic, assign) IBOutlet UILabel *durationLabel;
@property (nonatomic, assign) IBOutlet UILabel *rLabel;
@property (nonatomic, assign) IBOutlet UILabel *gLabel;
@property (nonatomic, assign) IBOutlet UILabel *bLabel;

@end


@implementation PulCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // basic setup
    PulsingHaloLayer *layer = [PulsingHaloLayer layer];
    self.halo = layer;
    [self.beaconView.superview.layer insertSublayer:self.halo below:self.beaconView.layer];
    
  //  [self setupInitialValues];
    
    [self.halo start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.halo.position = self.beaconView.center;
}


// =============================================================================
#pragma mark - Private

- (void)setupInitialValues {
    
    self.countSlider.value = 8;
   // [self countChanged:nil];

    self.radiusSlider.value = 1.0;
  //  [self radiusChanged:nil];
    
    self.durationSlider.value = 0.5;
  //  [self durationChanged:nil];
    
    self.rSlider.value = 0.;
    self.gSlider.value = 0.455;
    self.bSlider.value = 0.756;
  //  [self colorChanged:nil];
}

/*
// =============================================================================
#pragma mark - IBAction

- (IBAction)countChanged:(UISlider *)sender {
    
    //you can specify the number of halos by initial method or by instance property "haloLayerNumber"
    float value = floor(self.countSlider.value);
    self.halo.haloLayerNumber = value;
    self.countLabel.text = [@(value) stringValue];
}

- (IBAction)radiusChanged:(UISlider *)sender {
    
    self.halo.radius = self.radiusSlider.value * kMaxRadius;
    
    self.radiusLabel.text = [NSString stringWithFormat:@"%.0f", self.radiusSlider.value * kMaxRadius];
}

- (IBAction)durationChanged:(UISlider *)sender {
    
    self.halo.animationDuration = self.durationSlider.value * kMaxDuration;
    
    self.durationLabel.text = [NSString stringWithFormat:@"%.1f", self.durationSlider.value * kMaxDuration];
}

- (IBAction)colorChanged:(UISlider *)sender {
    
    UIColor *color = [UIColor colorWithRed:self.rSlider.value
                                     green:self.gSlider.value
                                      blue:self.bSlider.value
                                     alpha:1.0];
    
    [self.halo setBackgroundColor:color.CGColor];
    
    self.rLabel.text = [NSString stringWithFormat:@"%.2f", self.rSlider.value];
    self.gLabel.text = [NSString stringWithFormat:@"%.2f", self.gSlider.value];
    self.bLabel.text = [NSString stringWithFormat:@"%.2f", self.bSlider.value];
}
*/

@end
