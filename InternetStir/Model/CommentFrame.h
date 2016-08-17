//
//  CommentFrame.h
//  InternetStir
//
//  Created by Apple on 16/8/12.
//  Copyright © 2016年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CommentItem.h"
@interface CommentFrame : NSObject
@property (nonatomic, assign) CGRect iconF;
@property (nonatomic, assign) CGRect nameF;
@property (nonatomic, assign) CGRect photoF;
@property (nonatomic, assign) CGRect contentF;
@property (nonatomic, assign) CGRect replyF;
@property (nonatomic, strong) NSMutableArray *replysF;
@property (nonatomic, assign) float cellHeight;
@property (nonatomic, strong) CommentItem *commentItem;
@property (nonatomic, assign) CGRect buttonF;
@end
