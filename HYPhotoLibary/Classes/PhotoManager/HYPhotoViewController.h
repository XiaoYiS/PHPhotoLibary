//
//  HYPhotoViewController.h
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//  相册浏览

#import <UIKit/UIKit.h>

@import ImageIO;
#import "HYPhotoManager.h"

typedef void(^PhotoBlock)(NSMutableArray  <PHAsset *> * photos);

@interface HYPhotoViewController : UIViewController

//代码块属性
@property (nonatomic, copy) PhotoBlock photoBlock;


- (instancetype)initWithNeedNum:(NSInteger)needNum;



@end
