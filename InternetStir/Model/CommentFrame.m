//
//  CommentFrame.m
//  InternetStir
//
//  Created by Apple on 16/8/12.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import "CommentFrame.h"
#import "MMSystemHelper.h"
#define padding 10
@implementation CommentFrame
- (void) setCommentItem:(CommentItem *)commentItem{

    _commentItem = commentItem;
    CGFloat screenW = [MMSystemHelper getScreenWidth];
    //iconF头像
    CGFloat iconViewX = padding;
    CGFloat iconViewY = padding;
    CGFloat iconViewWidth = 40;
    CGFloat iconViewHeight = 40;
    self.iconF = CGRectMake(iconViewX, iconViewY, iconViewWidth, iconViewHeight);
    
    //nameF昵称
    CGFloat nameLabelX = CGRectGetMaxX(self.iconF) + padding;
    CGSize nameLabelSize = [MMSystemHelper sizeWithString:self.commentItem.name font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(MAXFLOAT,MAXFLOAT)];
    CGFloat nameLabelY = iconViewHeight / 2 + 5;
    CGFloat nameLabelWidth = nameLabelSize.width;
    CGFloat nameLabelHeight = nameLabelSize.height;
    self.nameF = CGRectMake(nameLabelX, nameLabelY, nameLabelWidth, nameLabelHeight);

    self.photoF = CGRectMake(10, iconViewY + iconViewHeight + 5, screenW - 20, 9 * (screenW - 20) / 16);
    self.cellHeight = CGRectGetMaxY(self.photoF) + padding;

    
    CGFloat contentH = [MMSystemHelper sizeWithString:self.commentItem.shuoshuoText font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(screenW - 20, MAXFLOAT)].height;
    self.contentF = CGRectMake(10, self.cellHeight, screenW - 20, contentH);
    self.cellHeight = CGRectGetMaxY(self.contentF) + padding;

    
    if ([self.commentItem.replys count]) {
        for (int i = 0; i < [self.commentItem.replys count]; i++) {
            CGSize replyLabelSize = [MMSystemHelper sizeWithString:[self.commentItem.replys objectAtIndex:i] font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(screenW - 20, MAXFLOAT)];
            CGFloat replyLabelY = self.cellHeight;
            CGFloat replyLabelWidth = replyLabelSize.width;
            CGFloat replyLabelHeight = replyLabelSize.height;
            self.cellHeight += padding +replyLabelHeight;
            CGRect replyF = CGRectMake(10, replyLabelY, replyLabelWidth, replyLabelHeight);
            [self.replysF addObject:[NSValue valueWithCGRect:replyF]];
        }
    }
    CGFloat buttonW = [MMSystemHelper sizeWithString:@"查看更多留言" font:[UIFont systemFontOfSize:14] maxSize:CGSizeMake(MAXFLOAT, 25)].width;
    self.buttonF = CGRectMake(screenW - buttonW - 20, self.cellHeight, buttonW, 30);
    self.cellHeight = CGRectGetMaxY(self.buttonF) + padding;
}
-(NSMutableArray *)replysF
{
    if (!_replysF) {
        _replysF = [[NSMutableArray alloc]init];
    }
    return _replysF;
}
@end
