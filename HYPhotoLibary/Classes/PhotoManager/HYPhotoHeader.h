//
//  HYPhotoHeader.h
//  PHPhotoLibary
//
//  Created by Haizel on 2018/8/13.
//  Copyright © 2018年 photo. All rights reserved.
//

#ifndef HYPhotoHeader_h
#define HYPhotoHeader_h

#define kWindowH   [UIScreen mainScreen].bounds.size.height //应用程序的屏幕高度
#define kWindowW    [UIScreen mainScreen].bounds.size.width  //应用程序的屏幕宽度

#define TOPVIEWHEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 88 : 64)

#define kRTColorWihRGB(R,G,B)     [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

#define kRTColorWithHEX(hex,opa)  [UIColor colorWithRed:((float)((hex & 0XFF0000)>>16))/255.0 green:((float)((hex & 0X00FF00)>>8))/255.0 blue:((float)(hex & 0X0000FF))/255.0 alpha:opa]

#define kRTColorWithHEXAlpha(hex)  [UIColor colorWithRed:((float)((hex & 0XFF0000)>>16))/255.0 green:((float)((hex & 0X00FF00)>>8))/255.0 blue:((float)(hex & 0X0000FF))/255.0 alpha:1.0]

#define kRTLABELSIZE_AUTO(String,Font) [String sizeWithAttributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:Font] forKey:NSFontAttributeName]]

//图片缩放比例
#define kMinZoomScale 0.6f
#define kMaxZoomScale 2.0f

//图片距离左右 间距
#define SpaceWidth    10

//是否支持横屏
#define shouldSupportLandscape YES

#define kIsFullWidthForLandScape YES //是否在横屏的时候直接满宽度，而不是满高度，一般是在有长图需求的时候设置为YES


#endif /* HYPhotoHeader_h */
