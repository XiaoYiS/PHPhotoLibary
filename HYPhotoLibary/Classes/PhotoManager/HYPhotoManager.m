//
//  HYPhotoManager.m
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "HYPhotoManager.h"

@implementation HYPhotoManager

- (instancetype)init{
    if (self = [super init]){
        self.collections = [NSMutableArray arrayWithCapacity:0];
    }
    
    return self;
}

+ (instancetype)shareInstance{
    static HYPhotoManager * photoManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoManager = [[HYPhotoManager alloc]init];
    });
    
    return photoManager;
}

#pragma mark - 打开相片组

/**
 获得所有的自定义相簿和获得相机胶卷
 
 @param successBlock 成功是回调的block
 */
- (void)openPhotosCollectionSuccess:(PHAssetCollectionBlock)successBlock {
    // 获得所有的自定义相簿
    [self.collections  removeAllObjects];
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    if (cameraRoll != nil) {
        [self.collections addObject:cameraRoll];
    }
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self.collections addObject:assetCollection];
    }
    successBlock(self.collections);
}

/**
 遍历相簿中的所有图片资源
 
 @param assetCollection 相簿
 @param synchronous     是否同步
 @param successBlock    成功是回调的block
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection isSynchronous:(BOOL)synchronous  success:(PHAssetPhotoBlock)successBlock {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = synchronous;
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    NSMutableArray *assetPhotos = [[NSMutableArray alloc]init];
    for (PHAsset *asset in assets) {
        [assetPhotos addObject:asset];
    }
    successBlock(assetPhotos);
}

/**
 获得相机胶卷中的图片Image
 
 @param asset         图片资源
 @param successBlock 成功是回调的block
 @param isThumbnail  是否要缩略图
 */
- (void)getImagesFromPHAsset:(PHAsset*)asset success:(PHImgBlock)successBlock isGetThumbnailImage:(BOOL)isThumbnail isSynchronous:(BOOL)synchronous{
    CGSize size = CGSizeMake(200, 200);
    if (!isThumbnail) {
        size =CGSizeMake(1920, 1920);
    }
    static PHImageRequestOptions *requestOptions;
    if (!requestOptions) {
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.resizeMode =PHImageRequestOptionsResizeModeNone;
    }
    requestOptions.synchronous = synchronous;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        successBlock(result,info);
    }];
    
}

//保存图片到相册
- (void)savePHAssetImage:(UIImage*)img   success:(PHAssetLocalIdentifierBlock)successBlock
{
    // PHAsset : 一个资源, 比如一张图片\一段视频
    // PHAssetCollection : 一个相簿
    // PHAsset的标识, 利用这个标识可以找到对应的PHAsset对象(图片对象)
    
    __block NSString *assetLocalIdentifier = nil;
    
    // 如果想对"相册"进行修改(增删改), 那么修改代码必须放在[PHPhotoLibrary sharedPhotoLibrary]的performChanges方法的block中
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 1.保存图片A到"相机胶卷"中
        // 创建图片的请求
        assetLocalIdentifier = [PHAssetCreationRequest creationRequestForAssetFromImage:img].placeholderForCreatedAsset.localIdentifier;
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //分线程
        if (success == YES) {
            successBlock(assetLocalIdentifier);
            return;
        }
    }];
}

@end
