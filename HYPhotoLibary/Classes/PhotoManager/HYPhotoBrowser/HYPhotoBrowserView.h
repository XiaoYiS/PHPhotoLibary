//
//  HYPhotoBrowserView.h
//  PHPhotoLibary
//
//  Created by haizel on 18/10/12.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYPhotoBrowserView : UIView
@property (nonatomic,strong) UIScrollView *scrollview;
@property (nonatomic,strong) UIImageView *imageview;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL beginLoadingImage;

@property (nonatomic, assign) BOOL hasLoadedImage;//图片下载成功为YES 否则为NO
//是否需要长按保存
@property (nonatomic, assign) BOOL islongPress;

//单击回调
@property (nonatomic, strong) void (^singleTapBlock)(UITapGestureRecognizer *recognizer);

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
@end
