//
//  Card.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/5/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "Card.h"

static CGFloat radius = 2;

static int shadowOffsetWidth = 0;
static int shadowOffsetHeight = 3;
static float shadowOpacity = 0.5;

@implementation Card

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}


-(void)setup {
    self.layer.cornerRadius = radius;
    UIBezierPath *shadowPath = [UIBezierPath
                                bezierPathWithRoundedRect: self.bounds
                                cornerRadius: radius];
    
    
    self.layer.masksToBounds = false;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(shadowOffsetWidth, shadowOffsetHeight);
    self.layer.shadowOpacity = shadowOpacity;
    self.layer.shadowPath = shadowPath.CGPath;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
