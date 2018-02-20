//
//  VerifiedVC.h
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/6/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VerifiedVC : UIViewController  <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;

@property(nonatomic, strong) NSArray *dataArray;

@end
