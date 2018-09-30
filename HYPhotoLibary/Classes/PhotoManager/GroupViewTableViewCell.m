//
//  GroupViewTableViewCell.m
//  PHPhotoLibary
//
//  Created by haizel on 18/9/27.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "GroupViewTableViewCell.h"

@implementation GroupViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.firstImgView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
