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
 *  Description:  AboutVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RfidAppEngine.h"

@interface zt_AboutVC : UIViewController <zt_IRfidAppEngineDevListDelegate>
{
    
    IBOutlet UILabel *m_lblOrganization;
    IBOutlet UILabel *m_lblApplicationCaption;
    IBOutlet UILabel *m_lblApplicationVersionNotice;
    IBOutlet UILabel *m_lblApplicationVersionData;
    IBOutlet UILabel *m_lblRfidSledCaption;
    IBOutlet UILabel *m_lblRfidSledModuleVersionNotice;
    IBOutlet UILabel *m_lblRfidSledModuleVersionData;
    IBOutlet UILabel *m_lblRfidSledRadioVersionNotice;
    IBOutlet UILabel *m_lblRfidSledRadioVersionData;
    IBOutlet UILabel *m_lblCopyright;
}

- (void)configureAppearance;

@end
