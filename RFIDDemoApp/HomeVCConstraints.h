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
 *  Description:  HomeVCConstraints.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RFIDTabVC.h"
#import "SettingsVC.h"
#import "ScanVC.h"
#import "VerifyVCViewController.h"
#import "ui_config.h"
#import "AlertView.h"
#import "UIViewController+ZT_ResponseHandler.h"
#import "BatteryStatusVC.h"
#import "GenerateMasterViewController.h"

#import "MaterialControls/MDButton.h"



@interface zt_HomeVCConstraints : UIViewController <RKCardViewDelegate, MDButtonDelegate>
{
    
}

@property (nonatomic, retain) IBOutlet MDButton *FloatingActionButton;

- (IBAction)btnGeneratePressed:(id)sender;
- (IBAction)btnScanPressed:(id)sender;
- (IBAction)btnSettingsPressed:(id)sender;

- (void)showTabInterfaceActiveView:(int)identifier;

@end
