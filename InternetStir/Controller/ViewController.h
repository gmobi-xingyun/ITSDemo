//
//  ViewController.h
//  InternetStir
//
//  Created by apple on 16/8/9.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *RigthTableView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UISegmentedControl *segment;
@property (assign) NSInteger index;

@property (nonatomic,strong)NSMutableArray *commentData;

@end

