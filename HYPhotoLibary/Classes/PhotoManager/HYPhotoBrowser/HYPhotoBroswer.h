//
//  HYPhotoBroswer.h
//  PHPhotoLibary
//
//  Created by haizel on 18/10/10.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYPhotoBroswer : UIView
@property (nonatomic, strong) UILabel * numberLabel;
/**
 * @brief 初始化方法  图片以数组的形式传入, 需要显示的当前图片的索引
 *
 * @param  imageArray需要显示的图片以数组的形式传入.
 * @param  index 需要显示的当前图片的索引
 */
- (instancetype)initWithImageArray:(NSArray *)imageArray currentIndex:(NSInteger)index;




- (void)show;
@end
