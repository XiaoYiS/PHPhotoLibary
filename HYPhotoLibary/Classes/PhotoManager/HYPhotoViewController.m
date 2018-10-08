//
//  HYPhotoViewController.m
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "HYPhotoViewController.h"

#import "HYPhotoHeader.h"
#import "HYPhotoCollectionViewCell.h"
#import "HYGroupView.h"
#import "HYPhotoBroswer.h"

@interface HYPhotoViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) HYPhotoManager * photoManager;

@property (nonatomic, assign) NSInteger needNum;
//相薄组
@property (nonatomic, strong) NSMutableArray<PHAssetCollection*>* collectionArray;
//相薄
@property (nonatomic, strong) PHAssetCollection * collection;
//存储PHAsset对象的数组
@property (nonatomic, strong) NSMutableArray <PHAsset *> * photos;
//存放所有的图片对象
@property (nonatomic, strong) NSMutableArray <UIImage *> * allImages;
//存储选中ALAsset对象的数组
@property (nonatomic, strong) NSMutableArray <PHAsset *> * selectPhotos;
//标准大小
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) HYGroupView* groupView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UIImage* tempImg;
@property (nonatomic, assign) NSInteger  page;
@property (nonatomic, strong) UILabel* allLable;
@property (nonatomic, strong) UIImageView* triangleImgView;
@property (nonatomic, strong) UIButton * selectPhotoAlbumBtn;
@end

static NSString * const reuseIdentifier = @"HYPhotoCollectionViewCell";

@implementation HYPhotoViewController

- (instancetype)initWithNeedNum:(NSInteger)needNum{
    
    if (self =[super init]) {
        self.needNum = needNum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavigationBar:self.navigationController.navigationBar];
    
    //初始化存储的数组
    self.allImages = [NSMutableArray array];
    self.selectPhotos = [NSMutableArray array];
    
    self.photoManager = [HYPhotoManager shareInstance];
    //右侧的确定按钮
   
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:(UIBarButtonItemStyleDone) target:self action:@selector(choosedImage)];
    spaceItem.width = 12;
    
    self.navigationItem.rightBarButtonItems = @[spaceItem];
    
    
    //左item
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //初始化数据,适配横屏
    
    CGFloat minLength = MIN(kWindowW, kWindowH - 50 - TOPVIEWHEIGHT);
    
    self.size = (minLength - 25) / 4.0f;
    
    UICollectionViewFlowLayout * layuot = [[UICollectionViewFlowLayout alloc]init];
    layuot.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    layuot.itemSize = CGSizeMake(self.size, self.size);
    self.collectionView =[[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kWindowW, kWindowH-50-TOPVIEWHEIGHT) collectionViewLayout:layuot];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = kRTColorWithHEX(0x31384b, 1.0);
    [self.view addSubview:self.collectionView];
    
    [self setUpBottomAllGroupView];
    
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"HYPhotoCollectionViewCell" bundle:[NSBundle bundleForClass:[HYPhotoCollectionViewCell class]]] forCellWithReuseIdentifier:reuseIdentifier];
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        //还没开始授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self requestPhotoGroup];
                    [self loadPhotosWithGroup:self.collectionArray.firstObject];
                });
            }else{
                
                [self rejectGetPicture];
            }
        }];
    }else if (status == PHAuthorizationStatusDenied){
        //拒绝授权
        [self rejectGetPicture];
    }else{
        //刷新界面
        [self requestPhotoGroup];
        [self loadPhotosWithGroup:self.collectionArray.firstObject];
    }
    
}


/**
 用户拒绝访问相册权限
 */
- (void)rejectGetPicture{
    [self alertTitile:@"请确定打开照片权限"
          withMessage:@"前往\"照片\"--> \"读取和写入权限\""
          buttonTitle:@"确定"
            forTarget:self
           complation:^{
               
               NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
               
               if ([[UIApplication sharedApplication] canOpenURL:url]) {
                   if (@available(iOS 10.0, *)) {
                       [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                           
                       }];
                   }else {
                       [[UIApplication sharedApplication] openURL:url];
                   }
               }
               
           }];
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

- (void)requestPhotoGroup{
    __weak typeof(self) weakSelf = self;
    [self.photoManager openPhotosCollectionSuccess:^(NSMutableArray<PHAssetCollection *> *collections) {
        weakSelf.collectionArray = collections;
    }];
    
}

- (void)loadPhotosWithGroup:(PHAssetCollection *)assetsCollection{
    
    self.navigationItem.title  = assetsCollection.localizedTitle;
    self.allLable.text = assetsCollection.localizedTitle;
    if (assetsCollection.localizedTitle.length >16) {
        self.allLable.text = [assetsCollection.localizedTitle substringToIndex:16];
    }
    CGSize  size =  kRTLABELSIZE_AUTO(self.allLable.text, 15);
    self.allLable.frame = CGRectMake(15, 35/2.0, size.width, 15);
    self.triangleImgView.frame = CGRectMake(CGRectGetMaxX(self.allLable.frame)+2, CGRectGetMaxY(self.allLable.frame)-self.triangleImgView.frame.size.height, self.triangleImgView.frame.size.width, self.triangleImgView.frame.size.height);
    self.selectPhotoAlbumBtn.frame = CGRectMake(0, 0, CGRectGetMaxX(self.triangleImgView.frame), 50);
    __weak typeof(self) weakSelf = self;
    [self.photoManager enumerateAssetsInAssetCollection:assetsCollection isSynchronous:NO success:^(NSMutableArray<PHAsset *> *photos) {
        
        if (photos.count == 0) {
            return ;
        }
        weakSelf.photos = photos;
        NSIndexPath * path = [NSIndexPath indexPathForRow:weakSelf.photos.count -1 inSection:0];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HYPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    PHAsset *  asset =  self.photos[indexPath.item];
    cell.theUpperRightCornerBtn.userInteractionEnabled = NO;
    
    [self.photoManager getImagesFromPHAsset:asset  success:^(UIImage * images ,NSDictionary *info) {
        cell.photoImageView.image = images;
        
    } isGetThumbnailImage:YES isSynchronous:NO];
    
    if ([self.selectPhotos containsObject:asset] ) {
        cell.selectImgView.hidden = NO;
    }else{
        cell.selectImgView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - 完成选择图片

- (void)choosedImage{
    NSMutableArray * arry = [NSMutableArray array];
    [arry addObjectsFromArray:self.selectPhotos];
    [self.selectPhotos removeAllObjects];
    //进行回调
    if (self.photoBlock) {
        self.photoBlock(arry);
    }
    [self dismiss];
}

//模态消失
- (void)dismiss{
    
    [self.navigationController dismissViewControllerAnimated:true completion:^{
        
    }];
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PHAsset *  asset =  self.photos[indexPath.item];
    static PHImageRequestOptions *requestOptions;
    if (!requestOptions) {
        
        requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.synchronous = YES;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        requestOptions.resizeMode =PHImageRequestOptionsResizeModeNone;
    }
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:requestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        NSUInteger   ddd = imageData.length/1024 ;
        if (MAX(ddd/1024.0, 10.0) != 10.0) {
            //            [UIViewControllerUtils showMessage:@"所选的单张图片大小不能大于10M!"];
            return ;
        }else{
            HYPhotoCollectionViewCell * cell = (HYPhotoCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
            
            if (cell.selectImgView.hidden) {
                if (self.selectPhotos.count < self.needNum) {
                    [self.selectPhotos addObject:asset];
                    cell.selectImgView.hidden = NO;
                }else{
                    [self showAlert:[NSString stringWithFormat:@"最多选择%lu张图片",(unsigned long)self.needNum]];
                }
            }else{
                [self.selectPhotos removeObject:asset];
                cell.selectImgView.hidden = YES;
            }
        }
    }];
}

//弹出提示
- (void)timerFireMethod:(NSTimer*)theTimer{
    
    UIView *promptAlert = (UIView*)[theTimer userInfo];
    promptAlert.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0];
    [promptAlert  removeFromSuperview];
    promptAlert = nil;
}

- (void)showAlert:(NSString *) _message{//时间
    
    UIView *promptAlert = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    promptAlert.center = CGPointMake(kWindowW/2.0, kWindowH/2.0);
    promptAlert.backgroundColor =[[UIColor blackColor] colorWithAlphaComponent:0.7];
    promptAlert.layer.cornerRadius = 12;
    promptAlert.layer.masksToBounds = YES;
    UIImageView * imgView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"exclamation-mark"]];
    imgView.frame = CGRectMake((150 - imgView.frame.size.width)/2.0 , 18, imgView.frame.size.width, imgView.frame.size.height);
    [promptAlert addSubview:imgView];
    UILabel * lable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame)+12, 150, 15)];
    lable.textAlignment =NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:14];
    lable.textColor = [UIColor whiteColor];
    lable.text = _message;
    [promptAlert addSubview:lable];
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(timerFireMethod:)userInfo:promptAlert repeats:YES];
    [[[UIApplication sharedApplication].delegate window] addSubview:promptAlert];
    
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 5;
}


#pragma mark == 创建底部视图

- (void)setUpBottomAllGroupView{
    UIView *bottomAllGroupView =[[UIView alloc]initWithFrame:CGRectMake(0,  kWindowH-50-TOPVIEWHEIGHT, kWindowW,50)];
    bottomAllGroupView.backgroundColor =kRTColorWithHEX(0x393939, 1.0);
    
    self.allLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 35/2.0, 70, 15)];
    self.allLable.text = @"相册交卷";
    self.allLable.font =[UIFont systemFontOfSize:15];
    self.allLable.textColor = [UIColor whiteColor];
    [bottomAllGroupView addSubview:self.allLable];
    self.triangleImgView =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"photo-album-Triangle"]];
    self.triangleImgView.frame = CGRectMake(CGRectGetMaxX(self.allLable.frame)+2, CGRectGetMaxY(self.allLable.frame)-self.triangleImgView.frame.size.height, self.triangleImgView.frame.size.width, self.triangleImgView.frame.size.height);
    [bottomAllGroupView addSubview:self.triangleImgView];
    self.selectPhotoAlbumBtn =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(self.triangleImgView.frame), 50)];
    [bottomAllGroupView addSubview:  self.selectPhotoAlbumBtn];
    [self.selectPhotoAlbumBtn addTarget:self action:@selector(setUpGroupViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomAllGroupView];
    
}

- (void)setUpGroupViewAction{
    
    self.groupView.collectionArray = self.collectionArray;
}

- (UIActivityIndicatorView *)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [_activityIndicatorView setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        _activityIndicatorView.center = CGPointMake(kWindowW / 2.0, (kWindowH - TOPVIEWHEIGHT) / 2.0f);
        _activityIndicatorView.color = kRTColorWithHEXAlpha(0xffffff);
        _activityIndicatorView.backgroundColor = kRTColorWithHEX(0x333333, 0.5);
        [self.view addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

//创建图片组视图
- (HYGroupView *)groupView{
    
    if (!_groupView) {
        _groupView = [HYGroupView nibFromXib];
        _groupView.frame = CGRectMake(0, -50, kWindowW, kWindowH);
        __weak typeof(self) weakSelf = self;
        
        _groupView.imagesBlock = ^(PHAssetCollection * collection){
            [weakSelf loadPhotosWithGroup:collection];
        };
        _groupView.removeViewBlock = ^{
            [weakSelf.groupView removeFromSuperview];
            weakSelf.groupView  = nil;
        };
        UIWindow * window = [[UIApplication sharedApplication].delegate window];
        [window addSubview:_groupView];
    }
    return _groupView;
}


/**
 初始化导航栏配置

 @param navigationBar navigationBar 此处可以将参数放入外部获取相关的导航栏进行配置
 */
- (void)initNavigationBar:(UINavigationBar *)navigationBar{
    // navigationBar setting - background color
    UIColor* backgroundColor = [UIColor colorWithRed:(float)0x20/0xff green:(float)0x24/0xff blue:(float)0x2c/0xff alpha:1.0];
    
    [navigationBar setTranslucent:NO];
    [navigationBar setBarTintColor:backgroundColor];
    [navigationBar setBackgroundColor:backgroundColor];
    
    // navigationBar setting - title color
    navigationBar.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:kRTColorWithHEX(0xffffff, 1)};
    
    for (UINavigationItem *item in [navigationBar items]) {
        item.leftBarButtonItem.tintColor =[UIColor whiteColor];
    }
    
    // 去掉导航栏的边界线
    [navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    navigationBar.shadowImage = [[UIImage alloc] init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
