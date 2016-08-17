//
//  inputAccessoryView.m
//  InputAccessoryView-WindowLayer
//
//  Created by shake on 14/11/14.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUInputAccessoryView.h"
#import "SettingService.h"
#import "ConfigService.h"
#define UUIAV_MAIN_W    CGRectGetWidth([UIScreen mainScreen].bounds)
#define UUIAV_MAIN_H    CGRectGetHeight([UIScreen mainScreen].bounds)
#define UUIAV_Edge_Hori 5
#define UUIAV_Edge_Vert 7
#define UUIAV_Btn_W    40
#define UUIAV_Btn_H    35


@interface UUInputAccessoryView ()<UITextViewDelegate>
{
    UUInputAccessoryBlock inputBlock;

    UIButton *btnBack;
    UITextView *inputView;
    UITextField *assistView;
    UIButton *BtnSave;
    UILabel *label;
    UIToolbar *bar;
    
    // dirty code for iOS9
    BOOL shouldDismiss;
}
@end

@implementation UUInputAccessoryView

+ (UUInputAccessoryView*)sharedView {
    static dispatch_once_t once;
    static UUInputAccessoryView *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[UUInputAccessoryView alloc] init];
        
        UIButton *backgroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backgroundBtn.frame = CGRectMake(0, 0, UUIAV_MAIN_W, UUIAV_MAIN_H);
        [backgroundBtn addTarget:sharedView action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        backgroundBtn.backgroundColor=[UIColor blackColor];
        backgroundBtn.alpha = 0.5;
        
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, UUIAV_MAIN_W, UUIAV_Btn_H+2*UUIAV_Edge_Vert)];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(UUIAV_Edge_Hori, UUIAV_Edge_Vert, UUIAV_MAIN_W-UUIAV_Btn_W-4*UUIAV_Edge_Hori, UUIAV_Btn_H)];
        textView.returnKeyType = UIReturnKeyDone;
        textView.enablesReturnKeyAutomatically = YES;
        textView.delegate = sharedView;
        textView.font = [UIFont systemFontOfSize:14];
        textView.layer.cornerRadius = 5;
        textView.layer.borderWidth = 0.5;
        [toolbar addSubview:textView];
//

        UITextField *assistTxf = [UITextField new];
        assistTxf.returnKeyType = UIReturnKeyDone;
        assistTxf.enablesReturnKeyAutomatically = YES;
        [backgroundBtn addSubview:assistTxf];
        assistTxf.inputAccessoryView = toolbar;
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        saveBtn.frame = CGRectMake(UUIAV_MAIN_W-UUIAV_Btn_W-2*UUIAV_Edge_Hori, UUIAV_Edge_Vert, UUIAV_Btn_W, UUIAV_Btn_H);
        saveBtn.backgroundColor = [UIColor clearColor];
        [saveBtn setTitle: @"send" forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [saveBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [saveBtn addTarget:sharedView action:@selector(saveContent) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:saveBtn];

        UILabel *label = [[UILabel alloc] initWithFrame:textView.frame];
        label.textAlignment = NSTextAlignmentLeft;
        label.font = [UIFont systemFontOfSize:14];
        [toolbar addSubview:label];
        
        sharedView->btnBack = backgroundBtn;
        sharedView->inputView = textView;
        sharedView->assistView = assistTxf;
        sharedView->BtnSave = saveBtn;
        sharedView->label = label;
        sharedView->bar = toolbar;
    });

    return sharedView;
}
+ (void)showBlock:(UUInputAccessoryBlock)block
{
    [[UUInputAccessoryView sharedView] show:block
                               keyboardType:UIKeyboardTypeDefault
                                    content:@""
                                placeholder:@""];
}

+ (void)showKeyboardType:(UIKeyboardType)type Block:(UUInputAccessoryBlock)block
{
    [[UUInputAccessoryView sharedView] show:block
                               keyboardType:type
                                    content:@""
                                placeholder:@""];
}

+ (void)showKeyboardType:(UIKeyboardType)type content:(NSString *)content name:(NSString *)name Block:(UUInputAccessoryBlock)block
{
    SettingService *ss = [SettingService get];
    NSString *str = [ss getStringValue:@"login" defValue:nil];
    if (str.length > 0) {
        content = str;
    }
    
    [[UUInputAccessoryView sharedView] show:block
                               keyboardType:type
                                    content:content
                                placeholder:name];
}

- (void)show:(UUInputAccessoryBlock)block keyboardType:(UIKeyboardType)type content:(NSString *)content placeholder:(NSString *)placeholder
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:btnBack];

    inputBlock = block;
    inputView.text = content;
//    inputView.text = @"mm";
    assistView.text = content;
    inputView.keyboardType = type;
    assistView.keyboardType = type;
    
    ConfigService *cs = [ConfigService get];
    if (cs.type == 1) {
        inputView.keyboardAppearance = UIKeyboardAppearanceDefault;
        assistView.keyboardAppearance = UIKeyboardAppearanceDefault;
        bar.barStyle = UIBarStyleDefault;
        bar.translucent = NO;
        inputView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];

    }else{
        inputView.keyboardAppearance = UIKeyboardAppearanceDark;
        assistView.keyboardAppearance = UIKeyboardAppearanceDark;
        bar.barStyle = UIBarStyleBlackTranslucent;
        bar.translucent = YES;
        inputView.layer.borderColor = [UIColor redColor].CGColor;
        label.backgroundColor = [UIColor grayColor];
//        label.alpha = 0.3;
        label.textColor = [UIColor grayColor];
    }

    label.hidden = NO;
    label.text = [NSString stringWithFormat:@" %@",placeholder];
    [assistView becomeFirstResponder];
    shouldDismiss = NO;
    BtnSave.enabled = content.length>0;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      if (!shouldDismiss) {
                                                          [inputView becomeFirstResponder];
                                                      }
                                                  }];
}

- (void)saveContent
{
    [inputView resignFirstResponder];
    !inputBlock ?: inputBlock(inputView.text);
    [self dismiss];
}

- (void)dismiss
{
   
//    self.replyBlock(inputView.text,self.replyTag);
    shouldDismiss = YES;
    [inputView resignFirstResponder];
    [btnBack removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// textView's delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self saveContent];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    BtnSave.enabled = textView.text.length>0;
    
    if (textView.text.length > 0) {
            label.hidden = YES;
            ConfigService *cs = [ConfigService get];
            if (cs.type == 1) {
                inputView.backgroundColor = [UIColor whiteColor];
            }else{
                inputView.backgroundColor = [UIColor grayColor];
            }
    } else {
        label.hidden = NO;
        inputView.backgroundColor = [UIColor whiteColor];
    }
}

@end
