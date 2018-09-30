//
//  HYPhotoCollectionViewCell.h
//  PHPhotoLibary
//
//  Created by haizel on 18/9/27.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPhotoManager.h"

typedef void(^SelectPHAssetBlock)(void);

@interface HYPhotoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
@property (weak, nonatomic) IBOutlet UIImageView *noSelectImgView;
@property (weak, nonatomic) IBOutlet UIButton *theUpperRightCornerBtn;

@property (nonatomic,strong) SelectPHAssetBlock selectPHAssetBlock;

@end
