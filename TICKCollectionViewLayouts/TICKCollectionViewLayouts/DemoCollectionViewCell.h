//
//  DemoCollectionViewCell.h
//  TICKCollectionViewLayouts
//
//  Created by Claris on 2016.10.02.
//  Copyright © 2016 Claris. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kDemoCollectionViewCellIdentifier = @"kDemoCollectionViewCellIdentifier";

@interface DemoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@end
