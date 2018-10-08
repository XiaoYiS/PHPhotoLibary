//
//  HYGroupView.m
//  PHPhotoLibary
//
//  Created by haizel on 18/9/27.
//  Copyright © 2018年 photo. All rights reserved.
//

#import "HYGroupView.h"
#import "GroupViewTableViewCell.h"

@interface HYGroupView ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mytableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;

//是否跳入胶卷相册，默认为false
@property (nonatomic, assign) BOOL isPushCameraRoll;
//存储ALAsset对象的数
@property (nonatomic, strong) NSMutableArray <PHAsset *> *photos;

@end

@implementation HYGroupView

@synthesize collectionArray = _collectionArray;

+ (instancetype)nibFromXib{
    
//    HYGroupView *selfView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    
    HYGroupView *selfView = [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass(self) owner:nil options:nil].lastObject;
    
    
    selfView.mytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [selfView.mytableView registerNib:[UINib nibWithNibName:@"GroupViewTableViewCell" bundle:[NSBundle bundleForClass:[GroupViewTableViewCell class]]] forCellReuseIdentifier:@"GroupViewTableViewCell"];
    return selfView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  
    }
    return self;
}

- (void)setCollectionArray:(NSMutableArray<PHAssetCollection *> *)collectionArray{

    _collectionArray = collectionArray;
    
    if (_collectionArray.count >4) {
        self.tableViewHeight.constant = 70*4.5;
    }else{
        self.tableViewHeight.constant = 70*_collectionArray.count;
    }
    
    [self.mytableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _collectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GroupViewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"GroupViewTableViewCell" forIndexPath:indexPath];
    
    PHAssetCollection * collection = self.collectionArray[indexPath.row];
    if (indexPath.row == self.collectionArray.count -1) {
        cell.lineView.hidden = YES;
    }else{
       cell.lineView.hidden =  NO;
    }
    cell.groupName.text = collection.localizedTitle;
    HYPhotoManager *photoManager =[HYPhotoManager shareInstance];
    
    [photoManager enumerateAssetsInAssetCollection:collection isSynchronous:YES success:^(NSMutableArray<PHAsset *> *photos) {
          cell.pictureNumLab.text = [NSString stringWithFormat:@"(%lu)",photos.count];
        [photoManager getImagesFromPHAsset:photos.firstObject success:^(UIImage * images ,NSDictionary *info) {
            cell.firstImgView.image = images;
        } isGetThumbnailImage:YES isSynchronous:NO];
    }];

    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PHAssetCollection * collection = self.collectionArray[indexPath.row];
    if (self.imagesBlock) {
        self.imagesBlock(collection);
    }
    if (self.removeViewBlock) {
        self.removeViewBlock();
    }
}

- (IBAction)removeViewAction:(id)sender {
    if (self.removeViewBlock) {
        self.removeViewBlock();
    }
}

@end
