//
//  HYPhotoManager.h
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//

#import <Foundation/Foundation.h>

@import UIKit;
@import Photos;

typedef void(^PHAssetCollectionBlock)(NSMutableArray <PHAssetCollection *> * collections);

typedef void(^PHAssetPhotoBlock)(NSMutableArray <PHAsset *> * photos);

typedef void(^PHAssetLocalIdentifierBlock)(NSString * localIdentifier);

typedef void(^PHImgBlock)(UIImage * images ,NSDictionary *info );


@interface HYPhotoManager : NSObject

// 单例方法
+ (instancetype)shareInstance;

@property (nonatomic,strong) NSMutableArray<PHAssetCollection*>* collections;

/**
 获得所有的自定义相簿和获得相机胶卷

 @param successBlock 成功
 */
- (void)openPhotosCollectionSuccess:(PHAssetCollectionBlock)successBlock ;

/**
 遍历相簿中的所有图片资源

 @param assetCollection 相簿
 @param synchronous 是否同步
 @param successBlock 成功是回调的block
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection isSynchronous:(BOOL)synchronous  success:(PHAssetPhotoBlock)successBlock ;

/**
 获得相机胶卷中的图片Image

 @param asset 图片资源
 @param successBlock 成功是回调的block
 @param isThumbnail 是否要缩略图
 @param synchronous 是否同步
 */
- (void)getImagesFromPHAsset:(PHAsset*)asset success:(PHImgBlock)successBlock isGetThumbnailImage:(BOOL)isThumbnail isSynchronous:(BOOL)synchronous;

//保存图片到相册
- (void)savePHAssetImage:(UIImage*)img   success:(PHAssetLocalIdentifierBlock)successBlock;


@end
