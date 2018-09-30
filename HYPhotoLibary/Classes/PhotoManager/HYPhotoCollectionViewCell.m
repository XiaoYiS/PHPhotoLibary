//
//  HYPhotoCollectionViewCell
//  PHPhotoLibary
//
//  Created by haizel on 18/9/27.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "HYPhotoCollectionViewCell.h"

@implementation HYPhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (IBAction)theUpperRightCornerBtnAction:(UIButton *)sender {
    if (self.selectPHAssetBlock) {
        self.selectPHAssetBlock();
    }
    
}

@end
