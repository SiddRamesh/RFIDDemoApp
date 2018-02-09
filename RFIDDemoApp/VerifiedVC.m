//
//  VerifiedVC.m
//  RFIDDemoApp
//
//  Created by Ramesh Siddanavar on 2/6/18.
//  Copyright © 2018 Motorola Solutions. All rights reserved.
//

#import "VerifiedVC.h"
#import "CollectionCellCollectionViewCell.h"

@interface VerifiedVC ()

@property(nonatomic, assign) UILabel *contentLbl;

@end

@implementation VerifiedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_collectionView setDelegate:self];
    [_collectionView setDelegate:self];
    // Do any additional setup after loading the view.
    
    NSMutableArray *firstSection = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        [firstSection addObject:[NSString stringWithFormat:@"Cell %d", i]];
    }
    self.dataArray = [[NSArray alloc] initWithObjects:firstSection, nil];
    
 //   UINib *cellNib = [UINib nibWithNibName:@"CollectionViewCell" bundle:nil];
 //   [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 50;// [self.dataArray count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
 //   NSMutableArray *sectionArray = [self.dataArray objectAtIndex:section];
    return 8;//[sectionArray count];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSMutableArray *data = [self.dataArray objectAtIndex:indexPath.section];
//    NSString *cellData = [data objectAtIndex:indexPath.section]; //row
    
    static NSString *cellIdentifier = @"cvCell";
   UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
   

//    if (indexPath.section % 2 != 0 ) {
//        cell.backgroundColor = [UIColor whiteColor];
//    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
           self.contentLbl.text = @"Date";
        } else {
            self.contentLbl.text = @"Section";
        }
    } else {
        
        if (indexPath.row == 0) {
            self.contentLbl.text = [NSString stringWithFormat:@"%ld",(long)indexPath.section]; //
        } else {
            self.contentLbl.text = @"Content";
        }
    }
    
    return cell;
}


@end


