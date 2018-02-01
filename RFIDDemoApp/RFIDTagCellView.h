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
 *  Description:  RFIDTagCellView.h
 *
 *  Notes:
 *
 ******************************************************************************/


#import <UIKit/UIKit.h>

#define ZT_CELL_ID_TAG_DATA                 @"ID_CELL_TAG_DATA"

/*
 TBD:
 - inventory operation shall be performed in accordance with selected bank and show
 details on cell selection
 - if user select "none as option" => no expended view for bank details (???)
 */

@interface zt_RFIDTagCellView : UITableViewCell
{
    UILabel *m_lblTagData;
    UILabel *m_lblTagCount;
    UILabel *m_lblBankId;
    UILabel *m_lblBankData;
    UILabel *m_lblPCNotice;
    UILabel *m_lblPCData;
    UILabel *m_lblRSSINotice;
    UILabel *m_lblRSSIData;
    UILabel *m_lblPhaseNotice;
    UILabel *m_lblPhaseData;
    UILabel *m_lblChannelNotice;
    UILabel *m_lblChannelData;
    
    BOOL m_IsExpanded;
    BOOL m_AutoLayoutIsPerformed;
}

- (void)configureAppearance;
- (void)configureViewMode:(BOOL)is_expanded;
- (void)updateFontSizeToFitLabelWidth:(UILabel*)label withMaxFontSize:(float)max_font_size;
- (void)setTagData:(NSString*)tag_data;
- (void)setTagCount:(NSString*)tag_count;
- (void)setBankIdentifier:(NSString*)bank_identifier;
- (void)setBankData:(NSString*)bank_data;
- (void)setPCData:(NSString*)pc_data;
- (void)setRSSIData:(int)rssi_data;
- (void)setPhaseData:(int)phase_data;
- (void)setChannelData:(int)channel_data;

- (void)setUnperfomPCData;
- (void)setUnperfomRSSIData;
- (void)setUnperfomPhaseData;
- (void)setUnperfomChannelData;
- (void)setUnperfomTagSeenCount;
@end
