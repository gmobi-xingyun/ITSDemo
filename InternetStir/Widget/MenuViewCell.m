 //
//  MenuViewCell.m
//  segment
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 gmobi. All rights reserved.
//

#import "MenuViewCell.h"
#import "MMSystemHelper.h"
@implementation MenuViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        CGFloat screenW = [MMSystemHelper getScreenWidth];
        CGFloat itemHeight = 60; //[[ConfigService get] getNewsListItemHeight:NEWS_TYPE_IMAGE]; //screenH / 7;
        CGFloat itemWidth = screenW * 3 / 4;
        self.contentView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        self.line = [[UIView alloc] init];
        self.line.frame = CGRectMake(10, 0, screenW - 20, 0.5);
        self.line.backgroundColor = [UIColor grayColor];//[UIColor lightGrayColor];
        self.line.alpha = 0.5;
        [self.contentView addSubview:self.line];
        self.icon = [[UIImageView alloc] init];
        CGFloat iconW = 42;
        CGFloat iconH = 42;
        
        self.icon.frame = CGRectMake(16, 9, iconW, iconH);
        [self.contentView addSubview:self.icon];
        
        self.title = [[UILabel alloc] init];
        CGFloat titleW = itemWidth - 16*3 - 42;
        CGFloat titleH = 20;
        self.title.frame = CGRectMake(16 + 42 + 16, 20, titleW, titleH);
        //UIFont* titleFont = [UIFont fontWithName:@"Arial" size:18];
        UIFont* titleFont = [UIFont systemFontOfSize:18];
        [self.title setFont:titleFont];
        self.title.text = @"设置";
        [self.title setNumberOfLines:1];
        
        [self.contentView addSubview:self.title];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
