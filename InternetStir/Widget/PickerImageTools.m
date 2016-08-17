//
//  PickerImageTools.m
//  PoPoNews
//
//  Created by Apple on 16/8/5.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import "PickerImageTools.h"

static PickerImageTools *_tools = nil;

@interface PickerImageTools ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation PickerImageTools

+ (instancetype)ShareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _tools = (PickerImageTools *)@"只初始化一次";
        _tools = [[self alloc]init];
    });
    return _tools;
}
- (instancetype)init
{
    if ([_tools isKindOfClass:[NSString class]]) {
        self = [super init];
        return self;
    }
    return nil;
}



- (void)selectImageToolsWith:(UIViewController *)mySelf
{
    //拍照
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        mySelf.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [mySelf presentViewController:picker animated:YES completion:nil];

}


- (void)selectPhotograph:(UIViewController *)mySelf
{
//    从手机相册选择
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
    {
        mySelf.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    }
    [mySelf presentViewController:picker animated:YES completion:nil];



}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取选择的图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = [[NSData alloc]init];
   imageData = [self imageData:image];
     if (self.pickerImageCameraBlock)
    {
        self.pickerImageCameraBlock(imageData);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSData *)imageData:(UIImage *)myimage
{
    
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024)
    {
        if (data.length > 1024*1024)
        {
            //1M以及以上
            data = UIImageJPEGRepresentation(myimage, 0.1);
        }
        else if (data.length > 512*1024)
        {
            //0.5M-1M
            data = UIImageJPEGRepresentation(myimage, 0.5);
        }
        else if (data.length > 200*1024)
        {
            //0.25M-0.5M
            data = UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    return data;
}


@end
