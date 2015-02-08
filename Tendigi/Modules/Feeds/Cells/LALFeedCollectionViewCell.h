//
//  LALFeedCollectionViewCell.h
//  Tendigi
//
//  Created by Lionel on 06/02/2015.
//  Copyright (c) 2015 Lionel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LALFeedCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *feedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedImageViewHeightConstraint;

@end
