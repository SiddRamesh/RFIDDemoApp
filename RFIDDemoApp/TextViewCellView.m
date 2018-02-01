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
 *  Description:  TextViewCellView.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "TextViewCellView.h"
#import "ui_config.h"

@implementation zt_TextViewCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        m_TextView = [[UITextView alloc] init];
        m_lblInfoNotice = [[UILabel alloc] init];
        m_AutoLayoutIsPerformed = NO;
        m_TextViewHeightConstraint = nil;
        
        [self configureAppearance];
        
        /* set autoresising mask to content view to avoid default cell height constraint */
        [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    }
    return self;
}

- (void)dealloc
{
    if (nil != m_TextView)
    {
        [m_TextView release];
    }
    if (nil != m_lblInfoNotice)
    {
        [m_lblInfoNotice release];
    }
    [super dealloc];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    /* workaround: in some cases the super implementation does NOT call layoutSubviews
     on the content view of UITableViewCell*/
    
    [self.contentView layoutSubviews];
    
}


- (void)updateConstraints
{
    [super updateConstraints];
    if (NO == m_AutoLayoutIsPerformed)
    {
        [self.contentView removeConstraints:[self.contentView constraints]];
        
		/* 
		- c1 and c2 constraints as well as setting disabling translating of
		autoresizing mask to constant for content view are related
		to student's workaround
		- the issue is probably is similar to one described in RFIDTagCellView::updateConstraints 
		*/
        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:[self contentView] attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self  attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0];
        [self addConstraint:c1];
        
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:[self contentView] attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self  attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0];
        [self addConstraint:c2];
     
        NSLayoutConstraint *c10 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTop multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c10];
        
        NSLayoutConstraint *c20 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c20];
        
        NSLayoutConstraint *c30 = [NSLayoutConstraint constraintWithItem:m_lblInfoNotice attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c30];
        
        NSLayoutConstraint *c40 = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_lblInfoNotice attribute:NSLayoutAttributeBottom multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_INT_SMALL];
        [self.contentView addConstraint:c40];
        
        NSLayoutConstraint *c50 = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeLeading multiplier:1.0 constant:ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c50];
        
        NSLayoutConstraint *c60 = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c60];
        
        NSLayoutConstraint *c70 = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:[self contentView] attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-ZT_UI_CELL_CUSTOM_INDENT_EXT];
        [self.contentView addConstraint:c70];
        
        
        CGSize size = [m_TextView sizeThatFits:CGSizeMake(m_TextView.frame.size.width, FLT_MAX)];

        m_TextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size.height];
        [[self contentView] addConstraint:m_TextViewHeightConstraint];

        m_AutoLayoutIsPerformed = YES;
    }
    else
    {
        [[self contentView] removeConstraint:m_TextViewHeightConstraint];
        CGSize size = [m_TextView sizeThatFits:CGSizeMake(m_TextView.frame.size.width, FLT_MAX)];
        
        m_TextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size.height];
        [[self contentView] addConstraint:m_TextViewHeightConstraint];
    }
}

- (void)configureAppearance
{
    [m_TextView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [m_TextView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [m_TextView setKeyboardType:UIKeyboardTypeDefault];
    [m_TextView setReturnKeyType:UIReturnKeyDone];
    [m_TextView setBackgroundColor:[UIColor whiteColor]];
    [m_TextView setText:@""];
    m_TextView.scrollEnabled = NO;
    
    
    [m_TextView setTextColor:[UIColor blackColor]];
    [m_TextView setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_TEXT_FIELD]];
    
    
    [m_lblInfoNotice setTextColor:[UIColor blackColor]];
    [m_lblInfoNotice setBackgroundColor:[UIColor whiteColor]];
    [m_lblInfoNotice setTextAlignment:NSTextAlignmentLeft];
    [m_lblInfoNotice setFont:[UIFont systemFontOfSize:ZT_UI_CELL_CUSTOM_FONT_SZ_BIG]];
    [m_lblInfoNotice setText:@""];
    
    [m_TextView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [m_lblInfoNotice setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self contentView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [[self contentView] addSubview:m_lblInfoNotice];
    [[self contentView] addSubview:m_TextView];
}

- (void)setData:(NSString*)data
{
    [m_TextView setText:[NSString stringWithFormat:@"%@", data]];
    CGSize size = [m_TextView sizeThatFits:CGSizeMake(m_TextView.frame.size.width, FLT_MAX)];
    if (m_TextViewHeightConstraint != nil)
    {
        [[self contentView] removeConstraint:m_TextViewHeightConstraint];
    }
    m_TextViewHeightConstraint = [NSLayoutConstraint constraintWithItem:m_TextView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:size.height];
    [[self contentView] addConstraint:m_TextViewHeightConstraint];

    [m_TextView updateConstraintsIfNeeded];
}

- (NSString*)getCellData
{
    return [m_TextView text];
}

- (void)setInfoNotice:(NSString*)notice
{
    [m_lblInfoNotice setText:notice];
}

- (void)setTextViewDelegate:(id<UITextViewDelegate>)delegate
{
    [m_TextView setDelegate:delegate];
}



@end
