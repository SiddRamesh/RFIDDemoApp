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
 *  Description:  RFIDTagCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "RFIDTagCellView.h"
#import "ui_config.h"

@implementation zt_RFIDTagCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        m_lblTagData = [[UILabel alloc] init];
        m_lblTagCount = [[UILabel alloc] init];
        m_lblBankId = [[UILabel alloc] init];
        m_lblBankData = [[UILabel alloc] init];
        m_lblPCNotice = [[UILabel alloc] init];
        m_lblPCData = [[UILabel alloc] init];
        m_lblRSSINotice = [[UILabel alloc] init];
        m_lblRSSIData = [[UILabel alloc] init];
        m_lblPhaseNotice = [[UILabel alloc] init];
        m_lblPhaseData = [[UILabel alloc] init];
        m_lblChannelNotice = [[UILabel alloc] init];
        m_lblChannelData = [[UILabel alloc] init];
        
        m_IsExpanded = NO;
        m_AutoLayoutIsPerformed = NO;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_lblTagData)
    {
        [m_lblTagData release];
    }
    if (nil != m_lblTagCount)
    {
        [m_lblTagCount release];
    }
    if (nil != m_lblBankId)
    {
        [m_lblBankId release];
    }
    if (nil != m_lblBankData)
    {
        [m_lblBankData release];
    }
    if (nil != m_lblPCNotice)
    {
        [m_lblPCNotice release];
    }
    if (nil != m_lblPCData)
    {
        [m_lblPCData release];
    }
    if (nil != m_lblRSSINotice)
    {
        [m_lblRSSINotice release];
    }
    if (nil != m_lblRSSIData)
    {
        [m_lblRSSIData release];
    }
    if (nil != m_lblPhaseNotice)
    {
        [m_lblPhaseNotice release];
    }
    if (nil != m_lblPhaseData)
    {
        [m_lblPhaseData release];
    }
    if (nil != m_lblChannelNotice)
    {
        [m_lblChannelNotice release];
    }
    if (nil != m_lblChannelData)
    {
        [m_lblChannelData release];
    }
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* workaround: in some cases the super implementation does NOT call layoutSubviews
     on the content view of UITableViewCell*/
    
    [self.contentView layoutSubviews];
    
    /* proceed with multi-line label */
    m_lblBankData.preferredMaxLayoutWidth = CGRectGetWidth(m_lblBankData.frame);
    
    
    /* workaround: on iOS 7.1 this is going to an infinite loop without dispatch */
    /* workaround: on iOS 8.0 sometimes it misses or changes different data when we use dispatch.
        For example, tap on the first cell - PCData 30000, tap on the sec cell - PCData 30001, 
        tap again on the first cell - PCData 30001 (but must be 30000).*/

    if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
    {
        /* TBD: update fonts in labels to fit all data */
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateFontSizeToFitLabelWidth:m_lblTagData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblPCData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblRSSIData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblPhaseData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblChannelData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        });
         */
    }
    else
	{
        /* update fonts in labels to fit all data*/
        [self updateFontSizeToFitLabelWidth:m_lblTagData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblPCData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblRSSIData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblPhaseData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
        [self updateFontSizeToFitLabelWidth:m_lblChannelData withMaxFontSize:ZT_UI_CELL_TAG_FONT_SZ_BIG];
    }
}


- (void)updateConstraints
{
    /*
		student have investigated:
            Each cell can have flexible height, 
            but sum of free space pixels between lines shouldn't be more than 41. 
            Othewize constraint conflict expected.
     */
    
    [super updateConstraints];
    if (NO == m_AutoLayoutIsPerformed)
    {
        [self.contentView removeConstraints:[self.contentView constraints]];
        
        [m_lblBankId setHidden:!m_IsExpanded];
        [m_lblBankData setHidden:!m_IsExpanded];
        [m_lblPCNotice setHidden:!m_IsExpanded];
        [m_lblPCData setHidden:!m_IsExpanded];
        [m_lblRSSINotice setHidden:!m_IsExpanded];
        [m_lblRSSIData setHidden:!m_IsExpanded];
        [m_lblPhaseNotice setHidden:!m_IsExpanded];
        [m_lblPhaseData setHidden:!m_IsExpanded];
        [m_lblChannelNotice setHidden:!m_IsExpanded];
        [m_lblChannelData setHidden:!m_IsExpanded];
        
        /*
			on iOS 8.0 autolayout works inproperly for 
		leading and trailing attributes (probably is related
		to new screen sizes system, margins and so on)

			following changes were implemented by student 
		 to fix the issue:
		- content view is binded to superview (see c1 and
			c2 constraints below)
		- translatesAutoresizingMaskIntoConstraints property
			of content view is set to NO (refer configureAppearance)
         */
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:[self contentView] attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
        [self addConstraint:c1];
        
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:[self contentView] attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        [self addConstraint:c2];
                
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblTagCount attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblTagCount attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_TAG_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_lblTagCount attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:0.0 constant:43.0];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_lblTagData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_EXT];
        [self.contentView addConstraint:c40];
        
        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_lblTagData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblTagCount attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-ZT_UI_CELL_TAG_INDENT_EXT];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_lblTagData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblTagCount attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c60];
        
        /* nrv364: specifying height of label conflicts with height of whole cell */
        
        //NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_lblTagCount attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:51.0];
        //[self.contentView addConstraint:c70];
        
        NSLayoutConstraint *c80 = [NSLayoutConstraint constraintWithItem:m_lblTagData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblTagCount attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        [self.contentView addConstraint:c80];
        
        if (NO == m_IsExpanded)
        {
            NSLayoutConstraint *c90 = [NSLayoutConstraint constraintWithItem:m_lblTagCount attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c90];
        }
        else
        {
            NSLayoutConstraint *c100 = [NSLayoutConstraint constraintWithItem:m_lblBankId attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblTagData attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_INT_BIG];
            [self.contentView addConstraint:c100];
            
            NSLayoutConstraint *c110 = [NSLayoutConstraint constraintWithItem:m_lblBankData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblBankId attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_INT_SMALL];
            [self.contentView addConstraint:c110];
            
            NSLayoutConstraint *c120 = [NSLayoutConstraint constraintWithItem:m_lblBankId attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblTagData attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c120];
            
            NSLayoutConstraint *c130 = [NSLayoutConstraint constraintWithItem:m_lblBankId attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblTagCount attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c130];
            
            NSLayoutConstraint *c140 = [NSLayoutConstraint constraintWithItem:m_lblBankData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblBankId attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c140];
            
            NSLayoutConstraint *c150 = [NSLayoutConstraint constraintWithItem:m_lblBankData attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:m_lblBankId attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c150];
            
            NSLayoutConstraint *c155 = [NSLayoutConstraint constraintWithItem:m_lblPCNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblBankData attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_INT_BIG];
            [self.contentView addConstraint:c155];

            NSLayoutConstraint *c160 = [NSLayoutConstraint constraintWithItem:m_lblPCNotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeWidth multiplier:0.25 constant:-2*ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c160];
            
            NSLayoutConstraint *c170 = [NSLayoutConstraint constraintWithItem:m_lblRSSINotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c170];
            
            NSLayoutConstraint *c180 = [NSLayoutConstraint constraintWithItem:m_lblPhaseNotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c180];
            
            NSLayoutConstraint *c190 = [NSLayoutConstraint constraintWithItem:m_lblChannelNotice attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c190];
            
            NSLayoutConstraint *c200 = [NSLayoutConstraint constraintWithItem:m_lblRSSINotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c200];
            
            NSLayoutConstraint *c210 = [NSLayoutConstraint constraintWithItem:m_lblPhaseNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c210];
            
            NSLayoutConstraint *c220 = [NSLayoutConstraint constraintWithItem:m_lblChannelNotice attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c220];
            
            NSLayoutConstraint *c230 = [NSLayoutConstraint constraintWithItem:m_lblRSSINotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c230];
            
            NSLayoutConstraint *c240 = [NSLayoutConstraint constraintWithItem:m_lblPhaseNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c240];
            
            NSLayoutConstraint *c250 = [NSLayoutConstraint constraintWithItem:m_lblChannelNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c250];
            
            NSLayoutConstraint *c260 = [NSLayoutConstraint constraintWithItem:m_lblPCNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c260];
            
            NSLayoutConstraint *c270 = [NSLayoutConstraint constraintWithItem:m_lblRSSINotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:2*ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c270];
            
            NSLayoutConstraint *c280 = [NSLayoutConstraint constraintWithItem:m_lblPhaseNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblRSSINotice attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:2*ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c280];
            
            NSLayoutConstraint *c290 = [NSLayoutConstraint constraintWithItem:m_lblChannelNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblPhaseNotice attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:2*ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c290];

            NSLayoutConstraint *c300 = [NSLayoutConstraint constraintWithItem:m_lblPCData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_CELL_TAG_INDENT_INT_SMALL];
            [self.contentView addConstraint:c300];
            
            NSLayoutConstraint *c310 = [NSLayoutConstraint constraintWithItem:m_lblPCData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c310];
            
            NSLayoutConstraint *c320 = [NSLayoutConstraint constraintWithItem:m_lblRSSIData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblRSSINotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c320];
            
            NSLayoutConstraint *c330 = [NSLayoutConstraint constraintWithItem:m_lblPhaseData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblPhaseNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c330];
            
            NSLayoutConstraint *c340 = [NSLayoutConstraint constraintWithItem:m_lblChannelData attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:m_lblChannelNotice attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c340];
            
            NSLayoutConstraint *c350 = [NSLayoutConstraint constraintWithItem:m_lblRSSIData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblPCData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c350];
            
            NSLayoutConstraint *c360 = [NSLayoutConstraint constraintWithItem:m_lblPhaseData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblPCData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c360];
            
            NSLayoutConstraint *c370 = [NSLayoutConstraint constraintWithItem:m_lblChannelData attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:m_lblPCData attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c370];
            
            NSLayoutConstraint *c380 = [NSLayoutConstraint constraintWithItem:m_lblRSSIData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCData attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c380];
            
            NSLayoutConstraint *c390 = [NSLayoutConstraint constraintWithItem:m_lblPhaseData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCData attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c390];
            
            NSLayoutConstraint *c400 = [NSLayoutConstraint constraintWithItem:m_lblChannelData attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblPCData attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c400];
            
            NSLayoutConstraint *c410 = [NSLayoutConstraint constraintWithItem:m_lblPCData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblPCNotice attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c410];
            
            NSLayoutConstraint *c420 = [NSLayoutConstraint constraintWithItem:m_lblRSSIData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblRSSINotice attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c420];

            NSLayoutConstraint *c430 = [NSLayoutConstraint constraintWithItem:m_lblPhaseData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblPhaseNotice attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c430];

            NSLayoutConstraint *c440 = [NSLayoutConstraint constraintWithItem:m_lblChannelData attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:m_lblChannelNotice attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
            [self.contentView addConstraint:c440];

            NSLayoutConstraint *c450 = [NSLayoutConstraint constraintWithItem:m_lblPCData attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_TAG_INDENT_EXT];
            [self.contentView addConstraint:c450];
            
        }
        
        m_AutoLayoutIsPerformed = YES;
    }
}

- (void)configureAppearance
{
    m_lblBankData.numberOfLines = 0; // multiline
    m_lblTagData.numberOfLines = 1;
    m_lblTagCount.numberOfLines = 1;
    m_lblBankId.numberOfLines = 1;
    m_lblPCNotice.numberOfLines = 1;
    m_lblPCData.numberOfLines = 1;
    m_lblRSSINotice.numberOfLines = 1;
    m_lblRSSIData.numberOfLines = 1;
    m_lblPhaseNotice.numberOfLines = 1;
    m_lblPhaseData.numberOfLines = 1;
    m_lblChannelNotice.numberOfLines = 1;
    m_lblChannelData.numberOfLines = 1;
    
    [m_lblTagCount setTextAlignment:NSTextAlignmentRight];
    
    [m_lblTagData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_BIG]];
    [m_lblTagCount  setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_BIG]];
    [m_lblBankId setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_SMALL]];
    [m_lblBankData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_BIG]];
    [m_lblPCNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_SMALL]];
    [m_lblPCData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_MEDIUM]];
    [m_lblRSSINotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_SMALL]];
    [m_lblRSSIData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_MEDIUM]];
    [m_lblPhaseNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_SMALL]];
    [m_lblPhaseData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_MEDIUM]];
    [m_lblChannelNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_SMALL]];
    [m_lblChannelData setFont:[UIFont systemFontOfSize:ZT_UI_CELL_TAG_FONT_SZ_MEDIUM]];
    
    [m_lblTagData setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblTagCount setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblBankId setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblBankData setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblPCNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblPCData setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblRSSINotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblRSSIData setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblPhaseNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblPhaseData setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblChannelNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblChannelData setTranslatesAutoresizingMaskIntoConstraints:NO];
    /* workaround for iOS 8.0 - see comment in updateConstraints */
	[[self contentView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [m_lblPCNotice setText:@"PC"];
    [m_lblRSSINotice setText:@"RSSI"];
    [m_lblPhaseNotice setText:@"PHASE"];
    [m_lblChannelNotice setText:@"CHANNEL"];
    
    [[self contentView] addSubview:m_lblTagData];
    [[self contentView] addSubview:m_lblTagCount];
}

- (void)configureViewMode:(BOOL)is_expanded
{
    if (is_expanded == m_IsExpanded)
    {
        return;
    }
    
    m_IsExpanded = is_expanded;
    
    if (YES == m_IsExpanded)
    {
        [[self contentView] addSubview:m_lblBankId];
        [[self contentView] addSubview:m_lblBankData];
        [[self contentView] addSubview:m_lblPCNotice];
        [[self contentView] addSubview:m_lblPCData];
        [[self contentView] addSubview:m_lblRSSINotice];
        [[self contentView] addSubview:m_lblRSSIData];
        [[self contentView] addSubview:m_lblPhaseNotice];
        [[self contentView] addSubview:m_lblPhaseData];
        [[self contentView] addSubview:m_lblChannelNotice];
        [[self contentView] addSubview:m_lblChannelData];
    }
    else
    {
        [m_lblBankId removeFromSuperview];
        [m_lblBankData removeFromSuperview];
        [m_lblPCNotice removeFromSuperview];
        [m_lblPCData removeFromSuperview];
        [m_lblRSSINotice removeFromSuperview];
        [m_lblRSSIData removeFromSuperview];
        [m_lblPhaseNotice removeFromSuperview];
        [m_lblPhaseData removeFromSuperview];
        [m_lblRSSINotice removeFromSuperview];
        [m_lblRSSIData removeFromSuperview];
    }
    
    /* to cause update of layout constraints */
    m_AutoLayoutIsPerformed = NO;
}

- (void)updateFontSizeToFitLabelWidth:(UILabel*)label withMaxFontSize:(float)max_font_size;
{
    //float lbl_height = label.frame.size.height;
    float lbl_width = label.frame.size.width;
    
    CGFloat font_size = max_font_size + 1.0;
    CGSize text_size;
    
    NSString *text = [label text];
    
    do
    {
        font_size--;
        text_size = [text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font_size]}];
        
    } while ((text_size.width > lbl_width));
    
    [label setFont:[UIFont systemFontOfSize:font_size]];
    [label setText:text];
}

- (void)setTagData:(NSString*)tag_data
{
    [m_lblTagData setText:tag_data];
}

- (void)setTagCount:(NSString*)tag_count
{
    [m_lblTagCount setText:tag_count];
}


- (void)setBankIdentifier:(NSString*)bank_identifier
{
    if([bank_identifier  isEqual: @"None"])
    {
        [m_lblBankId setText:@""];
        return;
    }
    NSString *identifier = [bank_identifier uppercaseString];
    [m_lblBankId setText:[NSString stringWithFormat:@"%@ MEMORY", identifier]];
}

- (void)setBankData:(NSString*)bank_data
{
    [m_lblBankData setText:bank_data];
}

- (void)setPCData:(NSString*)pc_data
{
    [m_lblPCData setText:pc_data];
}

- (void)setRSSIData:(int)rssi_data
{
    [m_lblRSSIData setText:[NSString stringWithFormat:@"%d", rssi_data]];
}

- (void)setPhaseData:(int)phase_data
{
    [m_lblPhaseData setText:[NSString stringWithFormat:@"%d", phase_data]];
}

- (void)setChannelData:(int)channel_data
{
    [m_lblChannelData setText:[NSString stringWithFormat:@"%d", channel_data]];
}

- (void)setUnperfomPCData
{
    [m_lblPCData setText:@"-"];
}
- (void)setUnperfomRSSIData
{
    [m_lblRSSIData setText:@"-"];
}
- (void)setUnperfomPhaseData
{
    [m_lblPhaseData setText:@"-"];
}
- (void)setUnperfomChannelData
{
    [m_lblChannelData setText:@"-"];
}
- (void)setUnperfomTagSeenCount
{
    [m_lblTagCount setText:@"-"];
}

@end
