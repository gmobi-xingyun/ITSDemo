//
//  ContentViewCell.m
//  segment
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 gmobi. All rights reserved.
//

#import "ContentViewCell.h"

@implementation ContentViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.icon = [[UIImageView alloc] init];
        [self.contentView addSubview:self.icon];
        
        self.titleLabel = [[UILabel alloc] init];
        //        self.title.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.titleLabel];
        
        self.sourceLabel = [[UILabel alloc] init];
        self.sourceLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.sourceLabel];
        
        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.font = [UIFont systemFontOfSize:10];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.timeLabel];
        
        self.line = [[UILabel alloc]init];
        self.line.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.line];
    }
    return self;
}
-(void)showDataWithModel{
    
    self.titleLabel.frame = CGRectMake(15, 10, self.bounds.size.width - 30, 0);
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.text = @"ee WE FE  V RFA EWGFJEFBOEWB EBFJ PWJEBF JBEJABRJQRBGAV P  NQRJGN PJQB PRJE BGPJERBG J PQJERNG NREJQPGBG";
    self.titleLabel.numberOfLines = 2;
    
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.bounds.size.width, MAXFLOAT)];
    CGRect frame = self.titleLabel.frame;
    frame.size.height = size.height;
    [self.titleLabel setFrame:frame];
    self.titleLabel.frame = frame;

    self.icon.frame = CGRectMake(15, size.height + 10 , [[UIScreen mainScreen] bounds].size.width - 30,  9 * ([[UIScreen mainScreen] bounds].size.width - 30)/16);
    self.icon.image = [UIImage imageNamed:@"news_featured_nonpicture"];
    
    self.sourceLabel.frame = CGRectMake(15,self.icon.frame.size.height + self.icon.frame.origin.y + 10, 40, 20);
    self.sourceLabel.font = [UIFont systemFontOfSize:10];
    self.sourceLabel.text = @"环球网";
    
    self.timeLabel.frame = CGRectMake(self.sourceLabel.frame.size.width + self.sourceLabel.frame.origin.x + 10, self.sourceLabel.frame.origin.y, 40, 20);
    self.timeLabel.text = @"4小时前";

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
