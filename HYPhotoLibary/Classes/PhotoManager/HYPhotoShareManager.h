//
//  HYPhotoShareManager.h
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HYPhotoShareManager;

@protocol HYPhotoShareManagerDelegate <NSObject>

- (void)HYPhotoShareManager:(HYPhotoShareManager *)shareManager finishSelectPhoto:(NSArray *)selectPhotoArray;

@end


@interface HYPhotoShareManager : NSObject

@property (nonatomic, weak) id <HYPhotoShareManagerDelegate> photoShareManagerDelegate;

/**
 单例初始化

 @return self
 */
+ (instancetype)standardManager;

/**
 弹窗方式初始化

 @param viewController viewController description
 */
- (void)showAlertViewWithTarget:(UIViewController *)viewController;

/**
 直接展示拍照界面

 @param viewController viewController description
 */
- (void)showUIImagePickerControllerSourceTypeCameraWithTarget:(UIViewController *)viewController;

/**
 显示t相册

 @param viewController viewController description
 */
- (void)showUIImagePickerControllerSourceTypePhotoLibraryWithTarget:(UIViewController *)viewController;

@end
