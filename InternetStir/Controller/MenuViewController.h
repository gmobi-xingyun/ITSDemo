//
//  MenuViewController.h
//  segment
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 gmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *bgImage;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *headerBg;
@property (nonatomic, strong) UILabel *line;
@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) UIView *bgView;
@end
