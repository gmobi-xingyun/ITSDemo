
//
//  MenuViewController.m
//  segment
//
//  Created by Apple on 16/8/11.
//  Copyright © 2016年 gmobi. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuViewCell.h"
#import "MMSystemHelper.h"
#import "ITSApplication.h"

#define screenW [MMSystemHelper getScreenWidth]
#define screenH [MMSystemHelper getScreenHeight]

NSString *const MenuTableViewCellIdentifier = @"MenuCell";

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"粉絲小幫手";
//    self.headerBg = [[UIView alloc] init];
//    self.headerBg.frame = CGRectMake(0, -20, self.view.bounds.size.width, 20);
//    [self.navigationController.navigationBar addSubview:self.headerBg];
    
    self.headerBg.backgroundColor = [UIColor grayColor];
    //    [self.navigationController.navigationBar addSubview:self.headerBg];
    self.bgImage = [[UIImageView alloc] init];
    self.bgImage.frame = CGRectMake(0, 64, screenW, screenH/3);
    self.bgImage.backgroundColor = [UIColor grayColor];
    self.bgImage.contentMode = UIViewContentModeScaleToFill;
    self.bgImage.userInteractionEnabled = YES;
    [self.view addSubview:self.bgImage];
    
    self.icon = [[UIImageView alloc] init];
    self.icon.frame = CGRectMake((screenW - 70) / 2, (screenH/3  - 70) / 2 - 20, 70, 70);
    self.icon.image = [UIImage imageNamed:@"head"];
    self.icon.layer.masksToBounds = YES;
    self.icon.layer.cornerRadius = 35;
    [self.bgImage addSubview:self.icon];
    
    NSString *name = @"點擊登陸";
    [self.bgImage addSubview:self.icon];
    
    CGSize nameLabelSize = [self sizeWithString:name font:[UIFont systemFontOfSize:16] maxSize:CGSizeMake(MAXFLOAT,MAXFLOAT)];
    CGFloat userNameX = ([UIScreen mainScreen].bounds.size.width - nameLabelSize.width)/2;
    CGFloat userNmaeY = self.icon.frame.origin.y + 80;
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(userNameX, userNmaeY, nameLabelSize.width, nameLabelSize.height)];
    userNameLabel.textColor = [UIColor whiteColor];
    userNameLabel.font = [UIFont systemFontOfSize:16];
    userNameLabel.text = @"";
    userNameLabel.tag = 99;
    userNameLabel.textAlignment = NSTextAlignmentCenter;
    userNameLabel.text = name;
    [self.bgImage addSubview:userNameLabel];

    [self creatButton];
    [self creatScrollView];
    self.tableView = [[UITableView alloc] init];
    self.tableView.frame = CGRectMake(0, 0, screenW, screenH -screenH/3-104);
    self.tableView.rowHeight = 60;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = NO;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[MenuViewCell class] forCellReuseIdentifier:MenuTableViewCellIdentifier];
    [self.scrollView addSubview:self.tableView];
    
//    self.bgView = [[UIView alloc] init];
//    self.bgView.frame = CGRectMake(screenW, 0, screenW, screenH -screenH/3-104);
//    self.bgView.backgroundColor = [UIColor redColor];
//    [self.scrollView addSubview:self.bgView];
}
- (void)creatScrollView{
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = CGRectMake(0, screenH/3 + 64 + 40, screenW, screenH - screenH/3 - 104);
    self.scrollView.delegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    
    self.scrollView.contentSize = CGSizeMake(screenW * 3, screenH - screenH/3 - 104);
    [self.view addSubview:self.scrollView];
}
- (void)creatButton{
    
    NSArray *titleArr  = @[@"設定",@"加入網紅計畫",@"其他網紅"];
    for(NSInteger i = 0;i < 3;i++)
    {
        UIButton *but = [UIButton buttonWithType:UIButtonTypeSystem];
        but.frame = CGRectMake(screenW/3 * i , screenH/3 + 64, screenW/3, 38);
        [but setTitle:titleArr[i] forState:UIControlStateNormal];
        but.tag = 100 + i;
        [but setTitleColor:[UIColor colorWithRed:3/255.0 green:155/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
        [but addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:but];
    }
    //3 155 255
    self.line = [[UILabel alloc] initWithFrame:CGRectMake(0, screenH/3 + 64 + 38, screenW/3, 2)];
    self.line.backgroundColor = [UIColor colorWithRed:3/255.0 green:155/255.0 blue:255/255.0 alpha:1];
    [self.view addSubview:self.line];

}
- (void)btnClick:(UIButton *)button{
    switch (button.tag) {
        case 100:
        {
            self.scrollView.contentOffset = CGPointMake(0, 0);
            [UIView animateWithDuration:0.2 animations:^{
                self.line.frame = CGRectMake(0, screenH/3 + 64 + 38, screenW/3, 2);
            }];
            
        }
            break;
        case 101:
        {
            self.scrollView.contentOffset = CGPointMake(screenW, 0);
            [UIView animateWithDuration:0.2 animations:^{
                self.line.frame = CGRectMake(screenW/3, screenH/3 + 64 + 38, screenW/3, 2);
            }];
        }
            break;
        case 102:
        {
            self.scrollView.contentOffset = CGPointMake(screenW*2, 0);
            [UIView animateWithDuration:0.2 animations:^{
                self.line.frame = CGRectMake(screenW/3*2, screenH/3 + 64 + 38, screenW/3, 2);
            }];
        }
            break;
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
    [UIView animateWithDuration:0.2 animations:^{
        self.line.frame = CGRectMake(current*screenW/3, screenH/3 + 64 + 38, screenW/3, 2);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}
-(CGSize)sizeWithString:(NSString *)str font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *dict = @{NSFontAttributeName : font};
    // 如果将来计算的文字的范围超出了指定的范围,返回的就是指定的范围
    // 如果将来计算的文字的范围小于指定的范围, 返回的就是真实的范围
    CGSize size = [str boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    return size;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  
    ITSApplication* poApp = [ITSApplication get];
    DataService* ds = poApp.dataSvr;
    
    NSMutableArray* menuList = [ds getLeftMenuList];
    
    return [menuList count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ITSApplication* poApp = [ITSApplication get];
    DataService* ds = poApp.dataSvr;
    NSMutableArray* menuList = [ds getLeftMenuList];
    LeftMenuItem* menuItem = [menuList objectAtIndex:indexPath.row];

    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:MenuTableViewCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MenuViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MenuTableViewCellIdentifier];
    }
    MenuViewCell *tmpCell = (MenuViewCell*)cell;
    tmpCell.title.text = menuItem.actionName;
    UIImage* defIcon = [UIImage imageNamed:menuItem.iconName];
    [tmpCell.icon setImage:defIcon];

    tmpCell.selectionStyle = UITableViewCellSelectionStyleNone;
    return tmpCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = indexPath.row;
    if (index == 0) {
        
    }else if (index == 1){
    
    }else if (index == 2){
    
    }else if (index == 3){
    
    }else if (index == 4){
    
    }else if (index == 5){
    
    }else if (index == 6){
    
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
