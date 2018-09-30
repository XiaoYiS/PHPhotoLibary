//
//  HYPhotoShareManager.m
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "HYPhotoShareManager.h"

#import <Photos/Photos.h>
#import "HYPhotoManager.h"
#import "HYPhotoViewController.h"

@interface HYPhotoShareManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
//选择的图片：原图片的NSData
@property (nonatomic,strong) NSMutableArray *originalPhotosArray;
//图片的缩略图
@property (nonatomic,strong) NSMutableArray <UIImage *> *thumbnailPhotos;
//压缩图片的NSData
@property (nonatomic,strong) NSMutableArray*compressPhotosArray;
/* 当前控制器的父类控制器 */
@property (nonatomic, strong) UIViewController *superViewController;
/* 自大图片个数 */
@property (nonatomic, assign) NSInteger maxPictureCount;
/* 当前已有图片个数 */
@property (nonatomic, assign) NSInteger currentPictureCount;

@end


@implementation HYPhotoShareManager

+ (instancetype)standardManager{
    
    static dispatch_once_t onceToken;
    static HYPhotoShareManager *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[HYPhotoShareManager alloc]init];
    });
    
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        _maxPictureCount = 9;
    }
    return self;
}

- (void)showAlertViewWithTarget:(UIViewController *)viewController{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"请选择照片方式" preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    [viewController presentViewController:vc animated:YES completion:nil];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        
        [self showUIImagePickerControllerSourceTypeCameraWithTarget:viewController];
        
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {

        [self showUIImagePickerControllerSourceTypePhotoLibraryWithTarget:viewController];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction *action) {
        
    }];
    
    [vc addAction:cameraAction];
    [vc addAction:photoAction];
    [vc addAction:cancel];
}

/* 拍照 */
- (void)showUIImagePickerControllerSourceTypeCameraWithTarget:(UIViewController *)viewController{
    _superViewController = viewController;
    //判断是否可以使用相机（是否为模拟器）
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        
        NSString *mediaType = AVMediaTypeVideo;
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
            [self alertTitile:@"提示"
                  withMessage:@"没有权限访问您的相机"
                  buttonTitle:@"确定"
                    forTarget:self.superViewController
                   complation:^{
                       
                   }];
            
            return;
        }else {
    
            if (self.originalPhotosArray.count >= self.maxPictureCount) {
                
                [self alertTitile:@"提示"
                      withMessage:[NSString stringWithFormat:@"最多只能上传%ld张图片",self.maxPictureCount]
                      buttonTitle:@"确定"
                        forTarget:self.superViewController
                       complation:^{
                           
                       }];
                return;
            }else{
                
                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                
                self.imagePickerVc.sourceType = sourceType;
                self.imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                [self.superViewController presentViewController:self.imagePickerVc animated:YES completion:nil];
            }
        }
    }else {
        
        [self alertTitile:@"提示"
              withMessage:@"模拟器中无法打开照相机,请在真机中使用"
              buttonTitle:@"确定"
                forTarget:self.superViewController
               complation:^{
                   
               }];
    }
}

/* 相册 */
- (void)showUIImagePickerControllerSourceTypePhotoLibraryWithTarget:(UIViewController *)viewController{
    
    _superViewController = viewController;
    
    HYPhotoViewController * photoVC =[[HYPhotoViewController alloc]initWithNeedNum:self.maxPictureCount - self.thumbnailPhotos.count];
    
    photoVC.photoBlock = ^(NSMutableArray <PHAsset *> *photos){
        for (PHAsset * asset in photos) {
            [[HYPhotoManager shareInstance] getImagesFromPHAsset:asset success:^(UIImage * images ,NSDictionary *info) {
                
                [self.thumbnailPhotos addObject: images];
                
            } isGetThumbnailImage:YES isSynchronous:YES];
        }
        //                weakSelf.isSaved = NO;
        if (self.photoShareManagerDelegate && [self.photoShareManagerDelegate respondsToSelector:@selector(HYPhotoShareManager:finishSelectPhoto:)]) {
            [self.photoShareManagerDelegate HYPhotoShareManager:self finishSelectPhoto:self.thumbnailPhotos];
        }
        //设置图片
        [self handlePic:photos];
        
        
    };
    UINavigationController * nav  =[[UINavigationController alloc]initWithRootViewController:photoVC];
    
    [self.superViewController presentViewController:nav animated:YES completion:^{
        
    }];
}


#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:@"public.image"]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (image != nil) {
            
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    // 把图片保存相册
                    [self saveImagePicker:image];
                }else{
                    NSLog(@"拒绝访问");
                }
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            //设置图片
            if (self.photoShareManagerDelegate && [self.photoShareManagerDelegate respondsToSelector:@selector(HYPhotoShareManager:finishSelectPhoto:)]) {
                
                [self.photoShareManagerDelegate HYPhotoShareManager:self finishSelectPhoto:self.thumbnailPhotos];
            }
        }];
    }
}

// 把图片保存相册
- (void)saveImagePicker:(UIImage * )image{
    
    [[HYPhotoManager shareInstance] savePHAssetImage:image success:^(NSString *localIdentifier) {
        
        PHAsset * asset =  [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].lastObject;
        
        [[HYPhotoManager shareInstance] getImagesFromPHAsset:asset
                                                     success:^(UIImage *images, NSDictionary *info) {
                                                         //缩略图保存
                                                         [self.thumbnailPhotos addObject:image];
        }
                                         isGetThumbnailImage:YES
                                               isSynchronous:YES];
        
        
        static PHImageRequestOptions *requestOptions;
        
        if (!requestOptions) {
            requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.synchronous = YES;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            requestOptions.resizeMode =PHImageRequestOptionsResizeModeNone;
        }
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            [self.originalPhotosArray addObject:imageData];
            
        }];
        [self performSelectorOnMainThread:@selector(returnOnMainThread) withObject:nil waitUntilDone:NO];
    }];
    
}

- (void)returnOnMainThread{
    
    [self.superViewController dismissViewControllerAnimated:YES completion:^{
        
        //设置图片
        if (self.photoShareManagerDelegate && [self.photoShareManagerDelegate respondsToSelector:@selector(HYPhotoShareManager:finishSelectPhoto:)]) {
            [self.photoShareManagerDelegate HYPhotoShareManager:self finishSelectPhoto:self.thumbnailPhotos];
        }
    }];
    
}

//获得原图的数据源
- (void)handlePic:(NSArray *)photos{
    for (PHAsset * asset in photos) {
        static PHImageRequestOptions *requestOptions;
        if (!requestOptions) {
            requestOptions = [[PHImageRequestOptions alloc] init];
            requestOptions.synchronous = YES;
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            requestOptions.resizeMode =PHImageRequestOptionsResizeModeNone;
        }
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [UIImage imageWithData:imageData];
            [self.originalPhotosArray addObject:imageData];
            
        }];
        
    }
}

//等比例压缩图片
- (UIImage *)resetSizeSourceImage:(UIImage*)sourceImage {
    CGFloat  scaleToWidth  = 1280;
    if ( scaleToWidth > MAX(sourceImage.size.width,  sourceImage.size.height)) {
        return  sourceImage;
    }
    if (sourceImage.size.width >sourceImage.size.height ) {
        CGFloat height = (scaleToWidth / sourceImage.size.width) * sourceImage.size.height;
        CGRect  rect = CGRectMake(0, 0, scaleToWidth, height);
        UIGraphicsBeginImageContext(rect.size);
        [sourceImage drawInRect:rect];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }else{
        CGFloat width = (scaleToWidth / sourceImage.size.height) * sourceImage.size.width;
        CGRect  rect = CGRectMake(0, 0, width, scaleToWidth);
        UIGraphicsBeginImageContext(rect.size);
        [sourceImage drawInRect:rect];
        UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

- (NSData *)resetSizeOfImageData:(UIImage*)sourceImage{
    
    NSData * finallImageData = UIImageJPEGRepresentation(sourceImage,1.0);
    NSUInteger  sizeOriginKB = finallImageData.length/ 1024;
//    NSLog(@" =sizeOriginKB===== %lu ==size== %@ = ",finallImageData.length/1024 ,NSStringFromCGSize(sourceImage.size));
    if (sizeOriginKB <= 300) {
        return finallImageData;
    }
    finallImageData  = UIImageJPEGRepresentation(sourceImage,0.8);
//    NSLog(@"需要上传的图片的大小======%lu",finallImageData.length/1024);
    return finallImageData;
    
}

#pragma mark custom medthod

- (void)alertTitile:(NSString *)title withMessage:(NSString *)message buttonTitle:(NSString *)buttonTitle forTarget:(UIViewController *)target complation:(void (^)(void))complation{
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:buttonTitle
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            complation();
                                                        }];
    

    [controller addAction:alertAction];
    
    [target presentViewController:controller animated:YES completion:nil];
    
}


#pragma mark lazy loading

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // 改变相册选择页的导航栏外观
//        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
//        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
    
    return _imagePickerVc;
}

- (NSMutableArray *)originalPhotosArray{
    if (_originalPhotosArray==nil) {
        _originalPhotosArray =[[NSMutableArray alloc]init];
    }
    return _originalPhotosArray;
    
}

- (NSMutableArray<UIImage *> *)thumbnailPhotos{
    if (!_thumbnailPhotos) {
        _thumbnailPhotos = [[NSMutableArray alloc]init];
    }
    
    return _thumbnailPhotos;
}

@end
