/******************************************************************************
 *
 *       Copyright Zebra Technologies, Inc. 2014 - 2015
 *
 *       The copyright notice above does not evidence any
 *       actual or intended publication of such source code.
 *       The code contains Zebra Technologies
 *       Confidential Proprietary Information.
 *
 *
 *  Description:  AboutVC.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "AboutVC.h"
#import "ui_config.h"
#import "config.h"
#import "RfidAppEngine.h"

@interface zt_AboutVC ()

@end

@implementation zt_AboutVC

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil != self)
    {

    }
    return self;
}

- (void)dealloc
{
    [m_lblOrganization release];
    [m_lblApplicationCaption release];
    [m_lblApplicationVersionNotice release];
    [m_lblApplicationVersionData release];
    [m_lblRfidSledCaption release];
    [m_lblRfidSledModuleVersionNotice release];
    [m_lblCopyright release];
    [m_lblRfidSledModuleVersionData release];
    [m_lblRfidSledRadioVersionNotice release];
    [m_lblRfidSledRadioVersionData release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle:@"About"];
    
    [[zt_RfidAppEngine sharedAppEngine] addDeviceListDelegate:self];
    
    [self.view removeConstraints:[self.view constraints]];
    
    CGFloat height = self.view.bounds.size.height;
    
    CGFloat _indent = 0.01*height;
    CGFloat _height_ratio_big = 0.1;
    CGFloat _height_ratio_small = 0.05;
    
    NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblApplicationCaption attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:2*_indent];
    [self.view addConstraint:c50];
    
    NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_lblApplicationCaption attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:_height_ratio_big constant:0.0];
    [self.view addConstraint:c40];
    
    NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblApplicationCaption attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c60];
    
    NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblApplicationCaption attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c70];
    
    NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblOrganization attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblApplicationCaption attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    [self.view addConstraint:c10];
    
    NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblOrganization attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:_height_ratio_big constant:0.0];
    [self.view addConstraint:c20];
    
    NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_lblOrganization attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c30];
    
    NSLayoutConstraint *c31 = [NSLayoutConstraint constraintWithItem:m_lblOrganization attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c31];
    
    NSLayoutConstraint *c90 = [NSLayoutConstraint constraintWithItem:m_lblApplicationVersionNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblOrganization attribute:NSLayoutAttributeBottom multiplier:1.0 constant:3*_indent];
    [self.view addConstraint:c90];
    
    NSLayoutConstraint *c100 = [NSLayoutConstraint constraintWithItem:m_lblApplicationVersionNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c100];
    
    NSLayoutConstraint *c110 = [NSLayoutConstraint constraintWithItem:m_lblApplicationVersionData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c110];
    
    NSLayoutConstraint *c120 = [NSLayoutConstraint constraintWithItem:m_lblApplicationVersionData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.35 constant:0.0];
    [self.view addConstraint:c120];
    
    NSLayoutConstraint *c130 = [NSLayoutConstraint constraintWithItem:m_lblApplicationVersionNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblApplicationVersionData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c130];
        
    NSLayoutConstraint *c160 = [NSLayoutConstraint constraintWithItem:m_lblApplicationVersionData attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblApplicationVersionNotice attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:c160];

    NSLayoutConstraint *c170 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledCaption attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblApplicationVersionNotice attribute:NSLayoutAttributeBottom multiplier:1.0 constant:4*_indent];
    [self.view addConstraint:c170];
    
    NSLayoutConstraint *c180 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledCaption attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c180];
    
    NSLayoutConstraint *c190 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledCaption attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c190];
    
    NSLayoutConstraint *c200 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledCaption attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:_height_ratio_small constant:0.0];
    [self.view addConstraint:c200];
    
    NSLayoutConstraint *c210 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledModuleVersionNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledCaption attribute:NSLayoutAttributeBottom multiplier:1.0 constant:_indent];
    [self.view addConstraint:c210];
    
    NSLayoutConstraint *c220 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledModuleVersionNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c220];
    
    NSLayoutConstraint *c230 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledModuleVersionData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c230];
    
    NSLayoutConstraint *c240 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledModuleVersionData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.35 constant:0.0];
    [self.view addConstraint:c240];
    
    NSLayoutConstraint *c250 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledModuleVersionNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledModuleVersionData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c250];
        
    NSLayoutConstraint *c280 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledModuleVersionData attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledModuleVersionNotice attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:c280];
    
        NSLayoutConstraint *c290 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledModuleVersionNotice attribute:NSLayoutAttributeBottom multiplier:1.0 constant:_indent];
    [self.view addConstraint:c290];
    
    NSLayoutConstraint *c300 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c300];
    
    NSLayoutConstraint *c310 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c310];

    NSLayoutConstraint *c320 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.35 constant:0.0];
    [self.view addConstraint:c320];
    
    NSLayoutConstraint *c330 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledRadioVersionData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c330];
    
    NSLayoutConstraint *c340 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:_height_ratio_small constant:0.0];
    [self.view addConstraint:c340];
    
    NSLayoutConstraint *c350 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
    [self.view addConstraint:c350];
    
    NSLayoutConstraint *c360 = [NSLayoutConstraint constraintWithItem:m_lblRfidSledRadioVersionData attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.view addConstraint:c360];
    
    NSLayoutConstraint *c370 = [NSLayoutConstraint constraintWithItem:m_lblCopyright attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblRfidSledRadioVersionNotice attribute:NSLayoutAttributeBottom multiplier:1.0 constant:6*_indent];
    [self.view addConstraint:c370];
    
    NSLayoutConstraint *c380 = [NSLayoutConstraint constraintWithItem:m_lblCopyright attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:10.0];
    [self.view addConstraint:c380];
    
    NSLayoutConstraint *c390 = [NSLayoutConstraint constraintWithItem:m_lblCopyright attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-10.0];
    [self.view addConstraint:c390];
    
    NSLayoutConstraint *c400 = [NSLayoutConstraint constraintWithItem:m_lblCopyright attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:_height_ratio_big constant:0.0];
    [self.view addConstraint:c400];
        
    [self configureAppearance];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[zt_RfidAppEngine sharedAppEngine] removeDeviceListDelegate:self];

}

- (BOOL)deviceListHasBeenUpdated
{
    [self updateVersionData];
    return YES;
}

- (void)updateVersionData
{
    if ([[[zt_RfidAppEngine sharedAppEngine] activeReader] isActive])
    {
        zt_SledConfiguration *sled = [[zt_RfidAppEngine sharedAppEngine] sledConfiguration];
        if ( sled.readerNGEVersion != nil)
        {
            [m_lblRfidSledModuleVersionData setText:[NSString stringWithFormat:@"%@", sled.readerDeviceVersion]];
            [m_lblRfidSledRadioVersionData setText:[NSString stringWithFormat:@"%@", sled.readerNGEVersion]];
            return;
        }
    }

    [m_lblRfidSledModuleVersionData setText:[NSString stringWithFormat:@"%@", @""]];
    [m_lblRfidSledRadioVersionData setText:[NSString stringWithFormat:@"%@", @""]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureAppearance
{
    [m_lblOrganization setTextAlignment:NSTextAlignmentCenter];
    [m_lblApplicationCaption setTextAlignment:NSTextAlignmentCenter];
    [m_lblApplicationVersionNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblApplicationVersionData setTextAlignment:NSTextAlignmentRight];
    [m_lblCopyright setTextAlignment:NSTextAlignmentCenter];
    [m_lblRfidSledCaption setTextAlignment:NSTextAlignmentLeft];
    [m_lblRfidSledModuleVersionNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblRfidSledModuleVersionData setTextAlignment:NSTextAlignmentRight];
    [m_lblRfidSledRadioVersionNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblRfidSledRadioVersionData setTextAlignment:NSTextAlignmentRight];
    [m_lblOrganization setBackgroundColor:[UIColor whiteColor]];
    [m_lblApplicationCaption setBackgroundColor:[UIColor whiteColor]];
    [m_lblApplicationVersionNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblCopyright setBackgroundColor:[UIColor whiteColor]];
    [m_lblRfidSledCaption setBackgroundColor:[UIColor whiteColor]];
    [m_lblRfidSledModuleVersionNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblRfidSledModuleVersionData setBackgroundColor:[UIColor whiteColor]];
    [m_lblRfidSledRadioVersionNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblRfidSledRadioVersionData setBackgroundColor:[UIColor whiteColor]];
    [m_lblOrganization setTextColor:[UIColor blackColor]];
    [m_lblApplicationCaption setTextColor:[UIColor blackColor]];
    [m_lblApplicationVersionNotice setTextColor:[UIColor blackColor]];
    [m_lblApplicationVersionData setTextColor:[UIColor blackColor]];
    [m_lblCopyright setTextColor:[UIColor blackColor]];
    [m_lblRfidSledCaption setTextColor:[UIColor blackColor]];
    [m_lblRfidSledModuleVersionNotice setTextColor:[UIColor blackColor]];
    [m_lblRfidSledModuleVersionData setTextColor:[UIColor blackColor]];
    [m_lblRfidSledRadioVersionNotice setTextColor:[UIColor blackColor]];
    [m_lblRfidSledRadioVersionData setTextColor:[UIColor blackColor]];
    [m_lblOrganization setNumberOfLines:0];
    [m_lblApplicationCaption setNumberOfLines:0];
    [m_lblApplicationVersionNotice setNumberOfLines:1];
    [m_lblApplicationVersionData setNumberOfLines:1];
    [m_lblCopyright setNumberOfLines:0];
    [m_lblRfidSledCaption setNumberOfLines:1];
    [m_lblRfidSledModuleVersionNotice setNumberOfLines:1];
    [m_lblRfidSledModuleVersionData setNumberOfLines:1];
    [m_lblRfidSledRadioVersionNotice setNumberOfLines:1];
    [m_lblRfidSledRadioVersionData setNumberOfLines:1];
    [m_lblOrganization setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_BIG]];
    [m_lblApplicationCaption setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_BIG]];
    [m_lblApplicationVersionNotice setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblApplicationVersionData setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblCopyright setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblRfidSledCaption setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblRfidSledModuleVersionNotice setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblRfidSledModuleVersionData setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblRfidSledRadioVersionNotice setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    [m_lblRfidSledRadioVersionData setFont:[UIFont systemFontOfSize:ZT_UI_ABOUT_FONT_SZ_MEDIUM]];
    
    [m_lblOrganization setText:ZT_ORG_NAME];
    [m_lblApplicationCaption setText:ZT_INFO_RFID_APP_NAME];
    [m_lblOrganization setLineBreakMode:NSLineBreakByWordWrapping];
    [m_lblApplicationCaption setLineBreakMode:NSLineBreakByWordWrapping];

    [m_lblApplicationVersionNotice setText:@"Application version"];
    [m_lblApplicationVersionData setText:[NSString stringWithFormat: @"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]];
    
    [self updateVersionData];
    [m_lblRfidSledCaption setText:@"RFID sled:"];
    [m_lblRfidSledModuleVersionNotice setText:@"Module version"];

    [m_lblRfidSledRadioVersionNotice setText:@"Radio version"];
    [m_lblCopyright setText:[NSString stringWithFormat:@"Copyright %@", ZT_INFO_COPYRIGHT_YEAR]];
}

@end
