
//
//  CommentView.m
//  InternetStir
//
//  Created by Apple on 16/8/16.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import "CommentView.h"
#import "MMSystemHelper.h"

@implementation CommentView
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self creatUI];
    }
    return self;
}
- (void)creatUI{
    
    CGFloat screenW = [MMSystemHelper getScreenWidth];
    UILabel *line = [[UILabel alloc] init];
    line.frame = CGRectMake(0, 0, screenW, 0.5);
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.3;
    [self addSubview:line];
    
    self.icon = [UIButton buttonWithType:UIButtonTypeCustom];
    self.icon.frame = CGRectMake(10, 10, 20, 20);
    [self.icon setBackgroundImage:[UIImage imageNamed:@"list_2"] forState:UIControlStateNormal];
    [self addSubview:self.icon];
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"留言..." forState:UIControlStateNormal];
    self.button.frame = CGRectMake(50, 5, screenW - 50, 30);
    [self.button setTitleColor:[MMSystemHelper string2UIColor:@"#ececec"]forState:UIControlStateNormal];
    [self.button addTarget:self action:@selector(pushKeyboard) forControlEvents:UIControlEventTouchUpInside];
    self.button.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    [self addSubview:self.button];

}
- (void)pushKeyboard{
    if ([self.delegate respondsToSelector:@selector(writeNewComment)]) {
        [self.delegate writeNewComment];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
