//
//  ViewController.m
//  InternetStir
//
//  Created by apple on 16/8/9.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import "ViewController.h"
#import "MMSystemHelper.h"
#import "ContentViewCell.h"
#import "CommentItem.h"
#import "CommentCell.h"
#import "CommentViewController.h"
#import "UUInputAccessoryView.h"
#import "MenuViewController.h"

#define screenW [MMSystemHelper getScreenWidth]
#define screenH [MMSystemHelper getScreenHeight]

NSString *const ContentTableViewCellIdentifier = @"ContentTableViewCell";
NSString *const CommentTableViewCellIdentifier = @"CommentTableViewCell";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"蔡阿嘎";
    NSArray *arr = @[@"留言",@"内容",@"社群"];
    self.segment = [[UISegmentedControl alloc] initWithItems:arr];
    self.segment.frame = CGRectMake(20, 70, screenW - 40, 30);
    self.segment.selectedSegmentIndex = 0;
    self.index = self.segment.selectedSegmentIndex;
    [self.segment addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.segment];
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0, 110, screenW, screenH - 110);
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    
    self.scrollView.contentSize = CGSizeMake(screenW * 3, screenH - 110);
//    self.scrollView.backgroundColor = [UIColor redColor];
//    self.scrollView.contentOffset = CGPointMake(screenW,0);
    [self.view addSubview:self.scrollView];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = CGRectMake(0, 0, screenW, screenH - 110);
//    self.tableView.rowHeight = 280;
    self.tableView.tag = 100;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ContentViewCell class] forCellReuseIdentifier:ContentTableViewCellIdentifier];
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:CommentTableViewCellIdentifier];
    [self.scrollView addSubview:self.tableView];
    
    
    self.RigthTableView = [[UITableView alloc] init];
    self.RigthTableView.frame = CGRectMake(screenW, 0, screenW, screenH - 110);
//    self.RigthTableView.rowHeight = 280;
    self.RigthTableView.delegate = self;
    self.RigthTableView.dataSource = self;
    [self.RigthTableView registerClass:[ContentViewCell class] forCellReuseIdentifier:ContentTableViewCellIdentifier];
    [self.RigthTableView registerClass:[CommentCell class] forCellReuseIdentifier:CommentTableViewCellIdentifier];
    [self.scrollView addSubview:self.RigthTableView];
    
    CGFloat space = (screenW - 5*30)/(5 + 1);
 
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(2*screenW, 0, screenW, 40);
    bgView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:bgView];
    for (NSInteger i = 0; i < 5; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        button.frame = CGRectMake(space + i * (30 + space), 5, 30, 30);
        [bgView addSubview:button];
    }
    self.webView = [[UIWebView alloc] init];
//https://www.taobao.com/
    self.webView.frame = CGRectMake(2 *screenW, 40, screenW, screenH - 80);
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.scrollView addSubview:self.webView];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height;
    if (tableView == self.tableView) {
        CommentFrame *frame = self.commentData[indexPath.row];
        height = frame.cellHeight;
    }else{
        height = 280;
    }
    return height;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.commentData.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (tableView == self.tableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:CommentTableViewCellIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentTableViewCellIdentifier];
        }
        CommentCell *tmpCell = (CommentCell*)cell;
        tmpCell.commentFrame = self.commentData[indexPath.row];
        [tmpCell.button addTarget:self action:@selector(pushComment:) forControlEvents:UIControlEventTouchUpInside];
        for (int i = 0; i < [tmpCell.replysView count]; i++) {
            ((UILabel *)[tmpCell.replysView objectAtIndex:i]).frame = [(NSValue *)[tmpCell.commentFrame.replysF objectAtIndex:i] CGRectValue];
            tmpCell.replyLabel = [tmpCell.replysView objectAtIndex:i];
            tmpCell.replyLabel.userInteractionEnabled = YES;
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, tmpCell.replyLabel.frame.size.width, tmpCell.replyLabel.frame .size.height);
            [button addTarget:self action:@selector(tapReply:) forControlEvents:UIControlEventTouchUpInside];
            button.userInteractionEnabled = YES;
            button.tag = indexPath.row;
            [tmpCell.replyLabel addSubview:button];
        }
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:ContentTableViewCellIdentifier forIndexPath:indexPath];
        if (cell == nil){
            cell = [[ContentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContentTableViewCellIdentifier];
        }
        ContentViewCell* tmpCell = (ContentViewCell*)cell;
        [tmpCell showDataWithModel];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}
- (void)pushComment:(UIButton*)button{

    CommentViewController *vc = [[CommentViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)tapReply:(UIButton *)button{
    
    [UUInputAccessoryView showKeyboardType:UIKeyboardTypeDefault
                                   content:@""
                                      name:@"jpj"
                                     Block:^(NSString *contentStr)
     {
         
         
         
     }];
}
- (void)change:(UISegmentedControl*)sender{
    NSInteger index = sender.selectedSegmentIndex;
    self.index = index;
    switch (index) {
        case 0:
            self.scrollView.contentOffset = CGPointMake(0, 0);
            break;
        case 1:
            self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
            break;
        case 2:
            self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width * 2, 0);
        default:
            break;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollVie{
    
    if ([scrollVie isKindOfClass:[UITableView class]]) {
        return;
    }
    CGPoint curPoint = scrollVie.contentOffset;
    NSInteger current = curPoint.x/scrollVie.frame.size.width;
    self.index = current;
    [UIView animateWithDuration:0.3 animations:^{
        self.segment.selectedSegmentIndex = current;
    }];
}
-(NSMutableArray *)commentData
{
    if (!_commentData) {
        NSString *fullPath = [[NSBundle mainBundle] pathForResource:@"FamilyGroup.plist" ofType:nil];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:fullPath];
        NSMutableArray *models = [NSMutableArray arrayWithCapacity:[dictArray count]];
        for (NSDictionary *dict in dictArray) {
            CommentItem *commentItem = [CommentItem familyGroupWithDict:dict];
            CommentFrame *commentFrame = [[CommentFrame alloc]init];
            commentFrame.commentItem = commentItem;
            
            [models addObject:commentFrame];
        }
        _commentData = [models copy];
    }
    //NSLog(@"%lu",(unsigned long)[_statusFrames count]);
    return _commentData;
}
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:
     
     @{NSFontAttributeName:[UIFont systemFontOfSize:19],
       
       NSForegroundColorAttributeName:[UIColor blackColor]}];

    UIButton* Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    Btn.frame = CGRectMake(0, 20, 30, 30);
    [Btn setBackgroundImage:[UIImage imageNamed:@"list_2"] forState:UIControlStateNormal];
    
    //[backBtn setTitle:@"Categories" forState:UIControlStateNormal];
    [Btn addTarget:self action:@selector(pushMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:Btn];
    self.navigationItem.leftBarButtonItem = left;
}
- (void)pushMenu{

    MenuViewController *menu = [[MenuViewController alloc] init];
    [self.navigationController pushViewController:menu animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
