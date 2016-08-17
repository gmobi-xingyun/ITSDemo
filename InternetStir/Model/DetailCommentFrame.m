
//
//  DetailCommentFrame.m
//  InternetStir
//
//  Created by Apple on 16/8/16.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import "DetailCommentFrame.h"
#import "MMSystemHelper.h"
#define padding 10

@implementation DetailCommentFrame
- (void)setDetailCommentItem:(DetailCommentItem *)detailCommentItem{
    _detailCommentItem = detailCommentItem;
    CGFloat screenW = [MMSystemHelper getScreenWidth];
    CGFloat iconViewX = padding + 5;
    CGFloat iconViewY = padding + 5;
    CGFloat iconViewWidth = 40;
    CGFloat iconViewHeight = 40;
    self.iconF = CGRectMake(iconViewX, iconViewY , iconViewWidth, iconViewHeight);
    
    //nameF昵称
    CGFloat nameLabelX = CGRectGetMaxX(self.iconF) + padding;
    CGSize nameLabelSize = [MMSystemHelper sizeWithString:self.detailCommentItem.name font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(MAXFLOAT,MAXFLOAT)];
    CGFloat nameLabelY = iconViewY;
    CGFloat nameLabelWidth = nameLabelSize.width;
    CGFloat nameLabelHeight = nameLabelSize.height;
    self.nameF = CGRectMake(nameLabelX, nameLabelY, nameLabelWidth, nameLabelHeight);
    
//    //时间戳
//    CGFloat timeLabelWidth = 200;
//    CGFloat timeLabelHeight = 15;
//    CGFloat timeLabelX = nameLabelX;
//    CGFloat timeLabelY = nameLabelY + nameLabelHeight;
//    self.timeF = CGRectMake(timeLabelX, timeLabelY, timeLabelWidth, timeLabelHeight);
//    
    //shuoshuotextF正文
    CGFloat contentLabelX = nameLabelX;
    CGFloat contentLabelY = CGRectGetMaxY(self.nameF) + padding/2 + 20;
    CGSize contentLabelSize = [MMSystemHelper sizeWithString:self.detailCommentItem.shuoshuoText font:[UIFont systemFontOfSize:14 ] maxSize:CGSizeMake(screenW - nameLabelX - padding, MAXFLOAT)];
    CGFloat contentLabelWidth = contentLabelSize.width;
    CGFloat contentLabelHeight = contentLabelSize.height;
    self.contentF = CGRectMake(contentLabelX, contentLabelY, contentLabelWidth, contentLabelHeight);
    
    self.cellHeight = CGRectGetMaxY(self.contentF) + padding;
    
    //评论
    if([self.detailCommentItem.replys count])
    {
        CGFloat replyLabelX = nameLabelX + padding/2;
        for (int i = 0; i < [self.detailCommentItem.replys count]; i++) {
            
            CGRect pictureF = CGRectMake(nameLabelX, self.cellHeight, 30, 30);
            
            self.cellHeight += 30 + padding/2;
            CGSize replyLabelSize = [MMSystemHelper sizeWithString:[self.detailCommentItem.replys objectAtIndex:i] font:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(screenW - 2*padding - nameLabelX, MAXFLOAT)];
            CGFloat replyLabelY = self.cellHeight;
            CGFloat replyLabelWidth = replyLabelSize.width;
            CGFloat replyLabelHeight = replyLabelSize.height;
            self.cellHeight += padding +replyLabelHeight;
            CGRect replyF = CGRectMake(replyLabelX, replyLabelY, replyLabelWidth, replyLabelHeight);
            [self.replysF addObject:[NSValue valueWithCGRect:replyF]];
            [self.replyPictureF addObject:[NSValue valueWithCGRect:pictureF]];
        }
        
        //评论的背景
        self.cellHeight = CGRectGetMaxY([(NSValue *)[self.replysF lastObject] CGRectValue]) + padding;
        CGFloat replyBackgroundWidth = screenW - 1.5*padding -nameLabelX;
        CGFloat replyBackgroundHeight = self.cellHeight - padding*2 - CGRectGetMaxY(self.contentF);
        self.replyBackgroundF = CGRectMake(nameLabelX, CGRectGetMaxY(self.contentF) + padding, replyBackgroundWidth, replyBackgroundHeight);
    }

}
-(NSMutableArray *)replyPictureF{

    if (!_replyPictureF) {
        _replyPictureF = [[NSMutableArray alloc] init];
    }
    return _replyPictureF;
}
-(NSMutableArray *)replysF
{
    if (!_replysF) {
        _replysF = [[NSMutableArray alloc]init];
    }
    return _replysF;
}
@end
