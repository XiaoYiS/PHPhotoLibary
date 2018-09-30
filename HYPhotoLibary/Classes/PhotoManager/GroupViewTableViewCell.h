//
//  GroupViewTableViewCell.h
//  PHPhotoLibary
//
//  Created by haizel on 18/9/27.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupViewTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *firstImgView;
@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UILabel *pictureNumLab;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@end
