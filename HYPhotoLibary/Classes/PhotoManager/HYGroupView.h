//
//  HYGroupView.h
//  PHPhotoLibary
//
//  Created by haizel on 18/9/27.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYPhotoManager.h"

typedef void(^ImagesGroupBlock)(PHAssetCollection * collection);
typedef void(^RemoveViewBlock)(void);

@interface HYGroupView : UIView

+ (instancetype)nibFromXib;

//存放资源组对象的数组
@property (nonatomic, copy) NSMutableArray <PHAssetCollection *> * collectionArray;

@property (nonatomic, copy) ImagesGroupBlock imagesBlock;
@property (nonatomic,strong) RemoveViewBlock removeViewBlock;

@end
