//
//  DetailCommentCell.h
//  InternetStir
//
//  Created by Apple on 16/8/15.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailCommentFrame.h"
@interface DetailCommentCell : UITableViewCell

@property (nonatomic, strong) DetailCommentFrame *detailCommentFrame;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) NSMutableArray *replysView;
@property (nonatomic, strong) NSMutableArray *replyIconView;
@property (nonatomic, strong) UILabel *replyLabel;
@property (nonatomic, strong) UILabel *replyNameLabel;
@property (nonatomic, strong) UIImageView *replyIcon;
@property (nonatomic,strong)  UIImageView *replyBackgroundView;
@end
