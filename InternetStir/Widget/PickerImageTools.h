//
//  PickerImageTools.h
//  PoPoNews
//
//  Created by Apple on 16/8/5.
//  Copyright © 2016年 Gmobi. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^PickerImageCameraBlock)(NSData *pickerImage);


@interface PickerImageTools : NSObject

@property (nonatomic,copy) PickerImageCameraBlock pickerImageCameraBlock;

// 拍照
- (void)selectImageToolsWith:(UIViewController *)mySelf;
// 相册
- (void)selectPhotograph:(UIViewController *)mySelf;

+ (instancetype) ShareInstance;
@end
