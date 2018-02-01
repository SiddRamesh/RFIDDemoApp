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
 *  Description:  AntennaSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "InfoCellView.h"
#import "SelectionTableVC.h"
#import "LabelInputFieldCellView.h"

@interface zt_AntennaSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_ISelectionTableVCDelegate>
{
    IBOutlet UITableView *m_tblOptions;

    zt_LabelInputFieldCellView *m_cellPowerLevel;
    zt_InfoCellView *m_cellLinkProfile;
    
    /*  
        tari and doSelect not performed in ui
        to perform see - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
        in AntennaSettings.m
     */
    zt_LabelInputFieldCellView *m_cellTari;
    zt_InfoCellView *m_cellDoSelect;
    int m_PresentedOptionId;
    UITapGestureRecognizer *m_GestureRecognizer;
}

- (void)createPreconfiguredOptionCells;
- (void)setupConfigurationInitial;

@end
