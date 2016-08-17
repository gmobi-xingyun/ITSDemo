//
//  CommentView.h
//  InternetStir
//
//  Created by Apple on 16/8/16.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentViewDelegate <NSObject>
- (void)writeNewComment;
@end

@interface CommentView : UIView
@property (nonatomic, strong) UIButton *icon;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, weak) id<CommentViewDelegate> delegate;

@end
