//
//  HYViewController.m
//  HYPhotoLibary
//
//  Created by XiaoYiS on 09/30/2018.
//  Copyright (c) 2018 XiaoYiS. All rights reserved.
//

#import "HYViewController.h"
#import "HYPhotoShareManager.h"

@interface HYViewController ()<HYPhotoShareManagerDelegate>
    
    
    @property (nonatomic, strong) HYPhotoShareManager *photoShareManager;
    
    
    @end

@implementation HYViewController
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        self.photoShareManager = [HYPhotoShareManager new];
        self.photoShareManager.photoShareManagerDelegate = self;
        
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        [self.photoShareManager showAlertViewWithTarget:self];
    }
    
#pragma mark HYPhotoShareManagerDelegate
- (void)HYPhotoShareManager:(HYPhotoShareManager *)shareManager finishSelectPhoto:(NSArray *)selectPhotoArray{
    
    NSLog(@"选择的图片个数%ld",selectPhotoArray.count);
}
    
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    
    @end
