//
//  HYPhotoBroswer.m
//  PHPhotoLibary
//
//  Created by haizel on 18/10/10.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "HYPhotoBroswer.h"
#import "HYPhotoBrowserView.h"
#import "HYPhotoHeader.h"

@interface HYPhotoBroswer ()<UIScrollViewDelegate>

@property (nonatomic, strong) NSArray * imageArray;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIScrollView * scrollView;

@end

@implementation HYPhotoBroswer

- (instancetype)initWithImageArray:(NSArray *)imageArray currentIndex:(NSInteger)index{
    if (self == [super init]) {
        self.imageArray = imageArray;
        self.index = index;
        [self setUpView];
    }
    return self;
}
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake((kWindowW + 2*SpaceWidth) * self.imageArray.count, kWindowH);
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        [self numberLabel];
    }
    return _scrollView;
}
- (UILabel *)numberLabel{
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, kWindowW, 40)];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.index +1,(unsigned long)self.imageArray.count];
        [self addSubview:_numberLabel];
    }
    return _numberLabel;
}

- (void)setUpView{
    int index = 0;
    for (NSObject * object  in self.imageArray) {
            HYPhotoBrowserView * imageView = [[HYPhotoBrowserView alloc]init];
        if ([object isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *) object;
            imageView.imageview.image = image;
            imageView.hasLoadedImage = YES;
            imageView.islongPress = NO;
        }else if ([object isKindOfClass:[NSString class]]){

            
         [imageView setImageWithURL: [NSURL URLWithString:(NSString *)object] placeholderImage:[UIImage imageNamed:@"placeholder-image"]];
            imageView.islongPress = YES;
        }
        imageView.tag = index;
        __weak __typeof(self)weakSelf = self;
        imageView.singleTapBlock = ^(UITapGestureRecognizer *recognizer){
            [weakSelf dismiss];
        };
        [self.scrollView addSubview:imageView];
        index ++;
    }
}



#pragma mark ---UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/kWindowW;
    self.index = index;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([NSStringFromClass(obj.class) isEqualToString:@"HYPhotoBrowserView"]) {
            HYPhotoBrowserView * imageView = (HYPhotoBrowserView *) obj;
            if (imageView.imageview.tag != idx) {
                imageView.scrollview.zoomScale = 1.0;
            }
        }
    }];
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%lu",self.index+1,(unsigned long)self.imageArray.count];
}
- (void)layoutSubviews{
    [super layoutSubviews];
    //主要为了设置每个图片的间距，并且使 图片铺满整个屏幕，实际上就是scrollview每一页的宽度是 屏幕宽度+2*Space  居中。图片左边从每一页的 Space开始，达到间距且居中效果。
    _scrollView.bounds = CGRectMake(0, 0, kWindowW + 2 * SpaceWidth,kWindowH);
    _scrollView.center = self.center;
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(SpaceWidth + (kWindowW+20) * idx, 0,kWindowW,kWindowH);
    }];
    _scrollView.contentOffset = CGPointMake( (kWindowW+20) * self.index, 0);
}
- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = CGRectMake(0, 0, kWindowW, kWindowH);
    [window addSubview:self];
    self.transform = CGAffineTransformMakeScale(0, 0);
    [UIView animateWithDuration:.3 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}
- (void)dismiss{
    self.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:.3 animations:^{
        self.transform = CGAffineTransformMakeScale(0.0000000001, 0.00000001);
    }completion:^(BOOL finished) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        for (UIView * view in window.subviews) {
            if ([NSStringFromClass(view.class) isEqualToString:@"HYPhotoBroswer"]) {
                [view removeFromSuperview];
            }
        }
    }];
    
}
@end

