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
 *  Description:  UIVerticalButton.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "UIVerticalButton.h"
#import "ui_config.h"

@implementation zt_UIVerticalButton


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self != nil)
    {
        float bgnd_color = (float)ZT_UI_HOME_COLOR_BTN_BACKGROUND / 255.0;
        float shadow_color = (float)ZT_UI_HOME_COLOR_BTN_SHADOW / 255.0;
        [self setBackgroundColor:[UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0]];
        [[self layer] setShadowColor:[UIColor colorWithRed:shadow_color green:shadow_color blue:shadow_color alpha:1.0].CGColor];
        
        [[self layer] setCornerRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
        [[self layer] setShadowOffset:CGSizeMake((float)ZT_UI_HOME_BTN_SHADOW_SIZE, (float)ZT_UI_HOME_BTN_SHADOW_SIZE)];
        [[self layer] setShadowRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
        [[self layer] setShadowOpacity:0.0f];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
 
    CGRect content_rect = self.bounds;
    
    float padding = self.bounds.size.height / 10;
    
    CGRect image_rect_original = self.imageView.frame;
    
    float content_width = content_rect.size.width - 2 * padding;
    
    float image_height = content_rect.size.height * 0.75 - 1.2 * padding;
    float label_height = content_rect.size.height * 0.25 - 1.2 * padding;
    
    float image_aspect_ratio = image_height / image_rect_original.size.height;
    
    self.titleLabel.frame = CGRectMake(padding, content_rect.size.height * 0.75 + 0.24 * padding, content_width, label_height);
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    CGRect image_rect = CGRectMake(padding, padding, image_rect_original.size.width *  image_aspect_ratio, image_height);
    image_rect.origin.x = (content_rect.size.width - image_rect.size.width) / 2;
    self.imageView.frame = image_rect;
}

@end
