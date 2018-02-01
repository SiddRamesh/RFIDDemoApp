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
 *  Description:  LocateTagVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"
#import "AlertView.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "ui_config.h"
#import "config.h"
#import "BaseDpoVC.h"

@interface zt_LocateTagVC : BaseDpoVC <UITextFieldDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener>
{
    IBOutlet UITextField *m_txtTagIdInput;
    IBOutlet UILabel *m_lblDistanceNotice;
    IBOutlet UILabel *m_lblDistanceData;
    IBOutlet UIButton *m_btnStartStop;
    IBOutlet UILabel *m_lblIndicatorBackground;
    IBOutlet UILabel *m_lblIndicatorValue;
    IBOutlet UILabel *m_lblTagIdInputBackground;
    UITapGestureRecognizer *m_GestureRecognizer;
    NSLayoutConstraint *m_IndicatorHeightConstraint;
    
    NSMutableString *m_strTagInput;
    
    NSTimer *m_ViewUpdateTimer;
}

- (IBAction)btnStartStopPressed:(id)sender;
- (void)configureAppearance;
- (void)setRelativeDistance:(int)distance;
- (void)dismissKeyboard;
- (BOOL)onNewProximityEvent:(int)value;
- (void)showWarning:(NSString *)message;
- (void)updateOperationDataUI;

@end
