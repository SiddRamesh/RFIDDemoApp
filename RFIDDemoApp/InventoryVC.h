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
 *  Description:  InventoryVC.h
 *
 *  Notes:
 *
 ******************************************************************************/

#import <UIKit/UIKit.h>
#import "RFIDTagCellView.h"
#import "RfidSdkDefs.h"
#import "RfidAppEngine.h"
#import "UIViewController+ZT_FieldCheck.h"
#import "BaseDpoVC.h"

@interface zt_InventoryVC : BaseDpoVC <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, zt_IRfidAppEngineTriggerEventDelegate, zt_IRadioOperationEngineListener>
{
    IBOutlet UILabel *m_lblHeader;
    IBOutlet UITextField *m_txtSearch;
    IBOutlet UILabel *m_lblUniqueTagsNotice;
    IBOutlet UILabel *m_lblUniqueTagsData;
    IBOutlet UILabel *m_lblTotalTagsNotice;
    IBOutlet UILabel *m_lblTotalTagsData;
    IBOutlet UITableView *m_tblTags;
    IBOutlet UIButton *m_btnStartStop;
    
    NSMutableArray *m_Tags;
    zt_RFIDTagCellView *m_OffscreenTagCell;
    int m_ExpandedCellIdx;
    NSMutableString *m_SearchString;
    
    UIBarButtonItem *m_btnOptions;
    
    zt_EnumMapper *m_Mapper;
    NSMutableArray *m_InventoryOptions;
    SRFID_MEMORYBANK m_SelectedInventoryOption;
    
    CGFloat m_standartCellHeight;
    
    NSTimer *m_ViewUpdateTimer;
    UILabel *batchModeLabel;
}

- (void)configureTagCell:(zt_RFIDTagCellView*)tag_cell forRow:(int)row isExpanded:(BOOL)expanded;
- (void)setLabelTextToFit:(NSString*)text forLabel:(UILabel*)label withMaxFontSize:(float)max_font_size;
- (void)configureAppearance;
- (void)btnOptionsPressed;
- (IBAction)btnStartStopPressed:(id)sender;
- (void)updateOperationDataUI;

@end
