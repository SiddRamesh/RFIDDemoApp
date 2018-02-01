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
 *  Description:  TagReportSettingsVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "SwitchCellView.h"
#import "PickerCellView.h"
#import "InfoCellView.h"
#import "SledConfiguration.h"

@interface zt_TagReportSettingsVC : UIViewController <UITableViewDataSource, UITableViewDelegate, zt_IOptionCellDelegate>
{
    IBOutlet UITableView *m_tblTagReportOptions;

    zt_SwitchCellView *m_OffscreenSwitchCell;
    
    int m_PickerCellIdx;
    int m_PickerCellSectionIdx;
    zt_PickerCellView *m_cellPicker;
    zt_InfoCellView *m_cellBatchMode;
    NSArray *m_OptionsBatchMode;
    int m_SelectedOptionMemoryBank;
    zt_SledConfiguration *localSled;
}

- (void)configureSwitchCell:(zt_SwitchCellView*)cell forRow:(NSIndexPath *)indexPath;
- (void)setupConfigurationInitial;

@end
