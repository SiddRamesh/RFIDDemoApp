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
 *  Description:  UIButton+VerticalButtonFactory.m
 *
 *  Notes:
 *
 ******************************************************************************/

#import "UIButton+VerticalButtonFactory.h"
#import "objc/runtime.h"
#import "ui_config.h"

@implementation UIButton (HomeScreenButtonsFactory)

+(UIButton *) buttonForHomeScreenWithSize:(CGSize)size withType:(int)zt_buttonType {
    UIButton *theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSDictionary *viewsDictionary = @{@"button":theButton};
    NSDictionary *metrics = @{@"width":[NSNumber numberWithDouble:size.width], @"height":[NSNumber numberWithDouble:size.height]};
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(width)]"
                                                                    options:0
                                                                    metrics:metrics
                                                                    views:viewsDictionary];
    
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(height)]"
                                                                    options:0
                                                                    metrics:metrics
                                                                    views:viewsDictionary];
    [theButton addConstraints:constraint_H];
    [theButton addConstraints:constraint_V];
    
    
    
    UIImage *image = [[[UIImage alloc] init] autorelease];
    NSString *title = @"";
    switch (zt_buttonType) {
        case ZT_BUTTON_RAPID_READ:
            image = [UIImage imageNamed:@"btn_rr.png"];
            title = ZT_STR_BUTTON_RAPID_READ;
            break;
            
        case ZT_BUTTON_INVENTORY:
            image = [UIImage imageNamed:@"btn_inv.png"];
            title = ZT_STR_BUTTON_INVENTORY;
            break;
            
        case ZT_BUTTON_SETTINGS:
            image = [UIImage imageNamed:@"btn_sett.png"];
            title = ZT_STR_BUTTON_SETTING;
            break;
        case ZT_BUTTON_LOCATE_TAG:
            image = [UIImage imageNamed:@"btn_locate.png"];
            title = ZT_STR_BUTTON_LOCATE_TAG;
            break;
            
        case ZT_BUTTON_FILTER:
            image = [UIImage imageNamed:@"btn_filter.png"];
            title = ZT_STR_BUTTON_FILTER;
            break;
        case ZT_BUTTON_ACCESS:
            image = [UIImage imageNamed:@"btn_access.png"];
            title = ZT_STR_BUTTON_ACCESS;
            break;
            
            
        default:
            break;
    }
    
    float bgnd_color = (float)ZT_UI_HOME_COLOR_BTN_BACKGROUND / 255.0;
    float shadow_color = (float)ZT_UI_HOME_COLOR_BTN_SHADOW / 255.0;
    [theButton setBackgroundColor:[UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0]];
    [[theButton layer] setShadowColor:[UIColor colorWithRed:shadow_color green:shadow_color blue:shadow_color alpha:1.0].CGColor];
    
    [[theButton layer] setCornerRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
    [[theButton layer] setShadowOffset:CGSizeMake((float)ZT_UI_HOME_BTN_SHADOW_SIZE, (float)ZT_UI_HOME_BTN_SHADOW_SIZE)];
    [[theButton layer] setShadowRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
    [[theButton layer] setShadowOpacity:0.0f];
    
    [theButton setTitle:title forState:UIControlStateNormal];
    
    [theButton setImage:image forState:UIControlStateNormal];
    
    [theButton.titleLabel setFont:[UIFont fontWithName:ZT_UI_HOME_BTN_FONT_NAME size:ZT_UI_HOME_BTN_FONT_SIZE]];
    
    [theButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    return theButton;
}

+(UIButton *) buttonForHomeScreen:(int)zt_buttonType {
    UIButton *theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = [[[UIImage alloc] init] autorelease];
    NSString *title = @"";
    switch (zt_buttonType) {
        case ZT_BUTTON_RAPID_READ:
            image = [UIImage imageNamed:@"btn_rr.png"];
            title = ZT_STR_BUTTON_RAPID_READ;
            break;
            
        case ZT_BUTTON_INVENTORY:
            image = [UIImage imageNamed:@"btn_inv.png"];
            title = ZT_STR_BUTTON_INVENTORY;
            break;
            
        case ZT_BUTTON_SETTINGS:
            image = [UIImage imageNamed:@"btn_sett.png"];
            title = ZT_STR_BUTTON_SETTING;
            break;
        case ZT_BUTTON_LOCATE_TAG:
            image = [UIImage imageNamed:@"btn_locate.png"];
            title = ZT_STR_BUTTON_LOCATE_TAG;
            break;
            
        case ZT_BUTTON_FILTER:
            image = [UIImage imageNamed:@"btn_filter.png"];
            title = ZT_STR_BUTTON_FILTER;
            break;
        case ZT_BUTTON_ACCESS:
            image = [UIImage imageNamed:@"btn_access.png"];
            title = ZT_STR_BUTTON_ACCESS;
            break;
            
            
        default:
            break;
    }
    
    float bgnd_color = (float)ZT_UI_HOME_COLOR_BTN_BACKGROUND / 255.0;
    float shadow_color = (float)ZT_UI_HOME_COLOR_BTN_SHADOW / 255.0;
    [theButton setBackgroundColor:[UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0]];
    [[theButton layer] setShadowColor:[UIColor colorWithRed:shadow_color green:shadow_color blue:shadow_color alpha:1.0].CGColor];
    
    [[theButton layer] setCornerRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
    [[theButton layer] setShadowOffset:CGSizeMake((float)ZT_UI_HOME_BTN_SHADOW_SIZE, (float)ZT_UI_HOME_BTN_SHADOW_SIZE)];
    [[theButton layer] setShadowRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
    [[theButton layer] setShadowOpacity:0.0f];
    
    [theButton setTitle:title forState:UIControlStateNormal];
    
    [theButton setImage:image forState:UIControlStateNormal];
    
    [theButton.titleLabel setFont:[UIFont fontWithName:ZT_UI_HOME_BTN_FONT_NAME size:ZT_UI_HOME_BTN_FONT_SIZE]];
    
    [theButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    return theButton;
}

+(void) alignHomeButtonContent:(UIButton *)button
{
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGSize imageSize = button.imageView.frame.size;
    CGSize titleSize = button.titleLabel.frame.size;
    CGSize buttonSize = button.frame.size;
    CGFloat marginTop = (buttonSize.height -imageSize.height - titleSize.height)/3;
    CGFloat marginImgRight = (buttonSize.width - imageSize.width) / 2;

    // edgeInset margintop marginleft marginbottom marginright
    button.titleEdgeInsets = UIEdgeInsetsMake(buttonSize.height - titleSize.height - marginTop*2, -imageSize.width, 0, 0);

    button.imageEdgeInsets = UIEdgeInsetsMake(-marginTop, marginImgRight, 0,0);
    
}

+(UIButton *) buttonForHomeScreenWithFrame:(CGRect)frame withButtonType:(int)zt_buttonType {
    UIButton *theButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSDictionary *viewsDictionary = @{@"button":theButton};
    NSDictionary *metrics = @{@"width":[NSNumber numberWithDouble:frame.size.width], @"height":[NSNumber numberWithDouble:frame.size.height]};
    
    NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(width)]"
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:viewsDictionary];
    
    NSArray *constraint_V = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(height)]"
                                                                    options:0
                                                                    metrics:metrics
                                                                      views:viewsDictionary];
    [theButton addConstraints:constraint_H];
    [theButton addConstraints:constraint_V];
    
    
    
    UIImage *image = [[[UIImage alloc] init] autorelease];
    NSString *title = @"";
    switch (zt_buttonType) {
        case ZT_BUTTON_RAPID_READ:
            image = [UIImage imageNamed:@"btn_rr.png"];
            title = ZT_STR_BUTTON_RAPID_READ;
            break;
            
        case ZT_BUTTON_INVENTORY:
            image = [UIImage imageNamed:@"btn_inv.png"];
            title = ZT_STR_BUTTON_INVENTORY;
            break;
            
        case ZT_BUTTON_SETTINGS:
            image = [UIImage imageNamed:@"btn_sett.png"];
            title = ZT_STR_BUTTON_SETTING;
            break;
        case ZT_BUTTON_LOCATE_TAG:
            image = [UIImage imageNamed:@"btn_locate.png"];
            title = ZT_STR_BUTTON_LOCATE_TAG;
            break;
            
        case ZT_BUTTON_FILTER:
            image = [UIImage imageNamed:@"btn_filter.png"];
            title = ZT_STR_BUTTON_FILTER;
            break;
        case ZT_BUTTON_ACCESS:
            image = [UIImage imageNamed:@"btn_access.png"];
            title = ZT_STR_BUTTON_ACCESS;
            break;
            
            
        default:
            break;
    }
    theButton.frame = frame;
    
    float bgnd_color = (float)ZT_UI_HOME_COLOR_BTN_BACKGROUND / 255.0;
    float shadow_color = (float)ZT_UI_HOME_COLOR_BTN_SHADOW / 255.0;
    [theButton setBackgroundColor:[UIColor colorWithRed:bgnd_color green:bgnd_color blue:bgnd_color alpha:1.0]];
    [[theButton layer] setShadowColor:[UIColor colorWithRed:shadow_color green:shadow_color blue:shadow_color alpha:1.0].CGColor];
    
    [[theButton layer] setCornerRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
    [[theButton layer] setShadowOffset:CGSizeMake((float)ZT_UI_HOME_BTN_SHADOW_SIZE, (float)ZT_UI_HOME_BTN_SHADOW_SIZE)];
    [[theButton layer] setShadowRadius:(float)ZT_UI_HOME_BTN_CORNER_RADIUS];
    [[theButton layer] setShadowOpacity:0.0f];
    
    [theButton setTitle:title forState:UIControlStateNormal];
    
    [theButton setImage:image forState:UIControlStateNormal];
    
    [theButton.titleLabel setFont:[UIFont fontWithName:ZT_UI_HOME_BTN_FONT_NAME size:ZT_UI_HOME_BTN_FONT_SIZE]];
    
    [theButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [theButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [UIButton alignHomeButtonContent:theButton];
    
    return theButton;
}


@end
