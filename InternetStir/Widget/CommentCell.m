//
//  CommentCell.m
//  InternetStir
//
//  Created by Apple on 16/8/12.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import "CommentCell.h"

@implementation CommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;   //cell选中时的颜色，无色
        self.icon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.icon];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.nameLabel];
        
        self.photo = [[UIImageView alloc] init];
        [self.contentView addSubview:self.photo];
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.font = [UIFont systemFontOfSize:12];
        self.commentLabel.numberOfLines = 0;
        [self.contentView addSubview:self.commentLabel];
        
        self.replyLabel = [[UILabel alloc] init];
        self.replyLabel.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.replyLabel];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.titleLabel.font = [UIFont systemFontOfSize: 14.0];
        [self.button setTitle:@"查看更多留言" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.contentView addSubview:self.button];

    }
    return self;
}
-(void)setCommentFrame:(CommentFrame *)commentFrame{

    _commentFrame = commentFrame;
    [self removeOldReplys];
    [self settingtData];
    [self settingFrame];
}
//防止cell重叠
-(void)removeOldReplys
{
    for (int i = 0; i < [self.replysView count]; i++) {
        UILabel *replyView = [self.replysView objectAtIndex:i];
        if (replyView.superview) {
            [replyView removeFromSuperview];
        }
    }
    [self.replysView removeAllObjects];
}
-(void)settingtData
{
    CommentItem *comment = self.commentFrame.commentItem;
    self.icon.image = [UIImage imageNamed:comment.icon];
    self.nameLabel.text = comment.name;
    self.photo.image = [UIImage imageNamed:comment.pictures];
    self.commentLabel.text = comment.shuoshuoText;
    for (NSInteger i = 0; i < comment.replys.count; i++) {
        UILabel *replyLabel = [[UILabel alloc]init];
        replyLabel.font = [UIFont systemFontOfSize:12];
        replyLabel.numberOfLines = 0;
        replyLabel.text = [comment.replys objectAtIndex:i];
        self.replyLabel = replyLabel;
        [self.contentView addSubview:replyLabel];
        [self.replysView addObject:replyLabel];
    }
}
-(void)settingFrame
{
    self.icon.frame = self.commentFrame.iconF;
    self.nameLabel.frame = self.commentFrame.nameF;
    self.photo.frame = self.commentFrame.photoF;
    for (int i = 0; i < [self.commentFrame.replysF count]; i++) {
        ((UILabel *)[self.replysView objectAtIndex:i]).frame = [(NSValue *)[self.commentFrame.replysF objectAtIndex:i] CGRectValue];
    }
    self.button.frame = self.commentFrame.buttonF;
    self.commentLabel.frame = self.commentFrame.contentF;
}
-(NSMutableArray *)replysView
{
    if (!_replysView) {
        _replysView = [[NSMutableArray alloc]init];
    }
    return _replysView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
