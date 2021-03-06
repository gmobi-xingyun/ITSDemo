//
//  RemoteService.m
//  PoPoNews
//
//  Created by apple on 15/4/17.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RemoteService.h"
#import "ConfigService.h"
#import "ITSAppConst.h"
#import "MMSystemHelper.h"
#import "MMLogger.h"
#import "MMHttpSession.h"
#import "MMEventService.h"
#import "ITSApplication.h"
#import "DataService.h"
#import "SettingService.h"

@implementation RemoteService

-(NSString*) getBaseUrl{
    ITSApplication* app = [ITSApplication  get];
    return app.baseUrl;
}

-(NSString*) getGroup{
    ITSApplication* app = [ITSApplication  get];
    return @"";//app.group;
}

-(NSString*) getConnectUrl{
    NSString* url;
    NSString* chParams = @"";
    
    ConfigService* cs = [ConfigService get];
    NSString* ch = [cs getChannel];
    if (ch != nil){
        chParams = [[NSString alloc] initWithFormat:@"&channel=%@", ch];
    }
    
    url = [[NSString alloc] initWithFormat:@"%@%@?group=%@%@" , [self getBaseUrl], CONNECT_PATH, [self getGroup], chParams];

    return url;
}

-(NSString*) getDefaultReportUrl{
    NSString* url;
    
    url = [[NSString alloc] initWithFormat:@"%@api/news/data" , [self getBaseUrl]];
    
    return url;
}

-(NSString*) getEditionListUrl: (NSString*) group{
    NSString* url;
    
    url = [[NSString alloc] initWithFormat:@"%@api/news/group/%@" , [self getBaseUrl], group];
    
    return url;
}

-(NSString*) getLatesNewsListUrl: (NSString*) cid
                            time: (NSString*) utc_time{
    NSString* url;
    
    DataService* dataSvr = [ITSApplication get].dataSvr;
    NSString* param = [[NSString alloc] initWithFormat:AFTER_TEMPLATE_URL, cid, utc_time, FETCH_COUNT, dataSvr.did];
    
    url = [[NSString alloc] initWithFormat:@"%@%@" , [self getBaseUrl], param];
    
    return url;
}

-(NSString*) getEarlyNewsListUrl: (NSString*) cid
                            time: (NSString*) utc_time{
    NSString* url;
    
    DataService* dataSvr = [ITSApplication get].dataSvr;
    NSString* param = [[NSString alloc] initWithFormat:BEFORE_TEMPLATE_URL, cid, utc_time, FETCH_COUNT, dataSvr.did];
    
    url = [[NSString alloc] initWithFormat:@"%@%@" , [self getBaseUrl], param];
    
    return url;
}

-(NSString*) getOfflineNewsUrl: (NSString*) cid
                          time: (NSString*) utc_time{
    NSString* url;
    
    DataService* dataSvr = [ITSApplication get].dataSvr;
    NSString* param = [[NSString alloc] initWithFormat:AFTER_TEMPLATE_URL, cid, utc_time, MAX_OFFLINE_FETCH_COUNT, dataSvr.did];
    
    url = [[NSString alloc] initWithFormat:@"%@%@" , [self getBaseUrl], param];

    return url;
}


-(NSString*) getContentUrl: (NSString*) nid{
    NSString* url;
    
    url = [[NSString alloc] initWithFormat:@"%@api/news/article/%@" , [self getBaseUrl], nid];
    
    return url;
}

-(NSString*) getBodyUrl: (NSString*) body{
    NSString* url;
    
    url = [[NSString alloc] initWithFormat:@"%@%@" , [self getBaseUrl], body];
    
    return url;
}

-(NSMutableDictionary*) getDeviceInfo{
    NSMutableDictionary* devInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    ConfigService* conf = [ConfigService get];
    NSString* ch = [conf getChannel];
    
    [devInfo setValue:[MMSystemHelper getAppPackageId] forKey:@"app"];
    if (ch != nil){
        [devInfo setValue:ch forKey:@"ch"];
    } else
        [devInfo setValue:@"" forKey:@"ch"];
    
    [devInfo setValue:[self getGroup] forKey:@"group"];
    [devInfo setValue:[MMSystemHelper getAppVersion] forKey:@"app_v"];
    [devInfo setValue:[MMSystemHelper getUA] forKey:@"ua"];
    [devInfo setValue:@"ios" forKey:@"os"];
    [devInfo setValue:[MMSystemHelper getOSVersion] forKey:@"os_v"];
    [devInfo setValue:[MMSystemHelper getLanguage] forKey:@"lang"];
    [devInfo setValue:[MMSystemHelper getCountry] forKey:@"country"];
    [devInfo setValue:[MMSystemHelper getIdForVendor] forKey:@"sn"];
    [devInfo setValue:[MMSystemHelper getIdForAD] forKey:@"aid"];
    [devInfo setValue:[NSString stringWithFormat:@"%ld", (long)[MMSystemHelper getScreenWidth]] forKey:@"sw"];
    [devInfo setValue:[NSString stringWithFormat:@"%ld", (long)[MMSystemHelper getScreenHeight]] forKey:@"sh"];
    
    SettingService* ss = [SettingService get];
    NSDictionary* uFBInfo = [ss getDictoryValue:POPO_FB_USER_INFO defValue:nil];
    //NSDictionary* uTWInfo = [ss getDictoryValue:POPO_TWITTER_USER_INFO defValue:nil];
    NSDictionary* uSWInfo = [ss getDictoryValue:POPO_SIMILARWEB_USER_INFO defValue:nil];
    if (uFBInfo != nil || uSWInfo != nil){
        NSMutableDictionary* userData = [NSMutableDictionary dictionaryWithCapacity:1];
        if (uFBInfo != nil){
            [userData setObject:uFBInfo forKey:@"fb"];
        }
        
        //if (uTWInfo != nil){
        //    [userData setObject:uTWInfo forKey:@"twitter"];
        //}
        
        if (uSWInfo != nil){
            [userData setObject:uSWInfo forKey:@"similarweb"];
        }
        
        if (userData != nil){
            [devInfo setObject:userData forKey:@"user"];
        }
    }
    
    NSString* pushToken = [ss getStringValue:POPO_IOS_PUSH_DEVICE_TOKEN defValue:@""];
    if (pushToken != nil){
        [devInfo setValue:pushToken forKey:@"pid"];
    }
    
    return devInfo;
}

-(void) doConnect{
    NSString* url = [self getConnectUrl];
    MMLogDebug(@"connect url = %@", url);
 
    NSMutableDictionary* dev = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableDictionary* info = [self getDeviceInfo];
    [dev setValue:info forKey:@"device"];
    
    NSError *error;
    NSData* devInfoD = [NSJSONSerialization dataWithJSONObject:info options:NSJSONWritingPrettyPrinted error:&error];
    NSString* devInfoStr = [[NSString alloc] initWithData:devInfoD encoding:NSUTF8StringEncoding];
    NSString* devInfoMd5 = [MMSystemHelper getMd5String:devInfoStr];
    
    SettingService* ss = [SettingService get];
    NSString* did = [ss getStringValue:POPONEWS_SERVER_DEVICE_ID defValue:nil];
    if (did != nil){
        [dev setObject:did forKey:@"did"];
    }
    
    BOOL isUpdate = NO;
    NSString* lastDeviceMd5 = [ss getStringValue:POPONEWS_CONNECT_DEVICE_INFO_MD5 defValue:nil];
    if (lastDeviceMd5 != nil){
        if (![lastDeviceMd5 isEqualToString:devInfoMd5]){
            isUpdate = YES;
        }
    } else
        isUpdate = YES;
    
    NSNumber* updateNum = [[NSNumber alloc] initWithBool:isUpdate];
    [dev setObject:updateNum forKey:@"update"];
    [ss setStringValue:POPONEWS_CONNECT_DEVICE_INFO_MD5 data:devInfoMd5];
    
    error = nil;
    //NSError *error;
    NSData* transData = [NSJSONSerialization dataWithJSONObject:dev options:NSJSONWritingPrettyPrinted error:&error];
    NSString* transStr = [[NSString alloc] initWithData:transData encoding:NSUTF8StringEncoding];
    
    MMLogDebug(@"data = %@", transStr);
    
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doPostJSON:url reqHeader:nil reqBody:dev callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"connect rsp: status = %d , code = %d", status, code);
        if (code != 200 && resultData != nil){
            @try {
                NSData* data = [resultData objectForKey:@"data"];
                NSError* err;
                NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                MMLogDebug(@"connect rsp : %@", dataStr);
            } @catch (NSException *exception) {
                //
            }
        }
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"Get connect Data rsp data: %@", dataStr);
            
            ITSApplication* poApp = [ITSApplication get];
            [poApp.dataSvr setConnectRespData:dataDic];
            
            MMEventService *es = [MMEventService getInstance];
            [es send:EVENT_CONNECT_ID eventData:EVENT_CONNECT_SUCCESS];
        } else {
            if (code == MM_HTTP_STATUS_ERROR){
                MMEventService *es = [MMEventService getInstance];
                [es send:EVENT_CONNECT_ID eventData:EVENT_CONNECT_FAILED];
            }
        }
    }];
}

-(void) getNewsListData: (NSString*) cid
                   time: (NSString*) utc_time
               timeType: (int) type{
    
    NSString* dataTime = utc_time;
    if (dataTime == nil)
        dataTime = [MMSystemHelper getTimeStampSeconds];
    
    NSString* url = nil;
    if (type == NEWS_REFRESH_TYPE_BEFORE)
        url = [self getEarlyNewsListUrl:cid time:dataTime];
    else
        url = [self getLatesNewsListUrl:cid time:dataTime];
    
    MMLogDebug(@"news data refresh url = %@", url);
    
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"Get News Data rsp: status = %d , code = %d", status, code);
        
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"Get News Data rsp data: %@", dataStr);
            
            BOOL isClear = NO;
            if (utc_time == nil && type == NEWS_REFRESH_TYPE_AFTER)
                isClear = YES;
            
            ITSApplication* poApp = [ITSApplication get];
           //[poApp.dataSvr setRefreshCategoryNews:cid newsList:dataDic isClearData:isClear];
            [poApp.dataSvr setRefreshCategoryNews:cid newsList:dataDic isClearData:isClear type:type];
            
            MMEventService *es = [MMEventService getInstance];
            [es send:[[NSString alloc] initWithFormat:@"%@_%@", EVENT_NEWS_DATA_REFRESH_PREFIX, cid]  eventData:NEWS_REFRESH_SUCCESS];
        } else {
            MMEventService *es = [MMEventService getInstance];
            [es send:[[NSString alloc] initWithFormat:@"%@_%@", EVENT_NEWS_DATA_REFRESH_PREFIX, cid]  eventData:NEWS_REFRESH_ERROR];
        }
    }];
}

-(void) getOfflineNewsByCategoryId: (NSString*) cid {
    
    NSString* dataTime = [MMSystemHelper getTimeStampSeconds];
    NSString* url = [self getOfflineNewsUrl:cid time:dataTime];
    
    MMLogDebug(@"Get Offline News url = %@", url);
    
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"Get Offline News rsp: status = %d , code = %d", status, code);
        
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"Get Offline News Data rsp data: %@", dataStr);
            
            ITSApplication* poApp = [ITSApplication get];
            [poApp.dataSvr setOfflineNews:cid newsList:dataDic];
            
            MMEventService *es = [MMEventService getInstance];
            [es send:EVENT_OFFLINE_NEWS_CHANGED  eventData:NEWS_REFRESH_SUCCESS];
        } else {
            MMEventService *es = [MMEventService getInstance];
            [es send:EVENT_OFFLINE_NEWS_CHANGED  eventData:NEWS_REFRESH_ERROR];
        }
    }];
}

-(void) getChannelsList{
    
    NSString* url = [self getEditionListUrl:[self getGroup]];
    
    MMLogDebug(@"getChannelsList url = %@", url);
    
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"Get Channel List rsp: status = %d , code = %d", status, code);
        
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"Get News Data rsp data: %@", dataStr);
            
            NSArray* chData = [dataDic objectForKey:@"data"];
            if (chData != nil){
                ITSApplication* poApp = [ITSApplication get];
                [poApp.dataSvr setPoNewsChannelList:chData];
            }
        }
    }];
}

-(void) doReportData: (NSMutableDictionary*) reqBody{
    
    NSString* url = [self getDefaultReportUrl];
    
    MMLogDebug(@"doReportData url = %@", url);
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doPostJSON:url reqHeader:nil reqBody:reqBody callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"doReportData rsp: status = %d , code = %d", status, code);
        
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"doReportData rsp data: %@", dataStr);
            
            id statusData = [dataDic objectForKey:@"status"];
            if (statusData != nil){
                MMEventService *es = [MMEventService getInstance];
                [es send:EVENT_REPORT_SEND_RESULT  eventData:DATA_SEND_SUCCESS];
                return;
            }
        }
        MMEventService *es = [MMEventService getInstance];
        [es send:EVENT_REPORT_SEND_RESULT  eventData:DATA_SEND_ERROR];
    }];
}
//577a35e6f44fc192627dce25
-(void) getDetailNewsById: (NSString*) nid
   isShowDetailPage: (BOOL) isShowDetailPage{
    if (nid == nil) return;
    
    NSString* url = [self getContentUrl:nid];
    
    MMLogDebug(@"Get News content url = %@", url);
    
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"Get News content rsp: status = %d , code = %d", status, code);
        
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"Get News content rsp data: %@", dataStr);
            
            PoPoNewsItem* tmpItem = [[PoPoNewsItem alloc] initWithDictionary:dataDic];
            NSLog(@"%@",tmpItem);
            ITSApplication* poApp = [ITSApplication get];
            [poApp.dataSvr insert2MyCommentNewsList:tmpItem];
        }
    }];
}

-(void) getNewsById: (NSString*) nid
   isShowDetailPage: (BOOL) isShowDetailPage{
    if (nid == nil) return;
    
    NSString* url = [self getContentUrl:nid];
    
    MMLogDebug(@"Get News content url = %@", url);
    
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        MMLogDebug(@"Get News content rsp: status = %d , code = %d", status, code);
        
        if (code == 200){
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            MMLogDebug(@"Get News content rsp data: %@", dataStr);
            
            PoPoNewsItem* tmpItem = [[PoPoNewsItem alloc] initWithDictionary:dataDic];
            
            // add to push news list
            ITSApplication* poApp = [ITSApplication get];
            BOOL isAdd = [poApp.dataSvr insert2PushNewsList:tmpItem saveFlag:YES];
            
            SettingService* ss = [SettingService get];
            int unreadCount = [ss getIntValue:POPO_IOS_PUSH_NEWS_UNREAD_COUNT defValue:0];
            if (isAdd == YES && isShowDetailPage == NO){
                unreadCount++;
                [ss setIntValue:POPO_IOS_PUSH_NEWS_UNREAD_COUNT data:unreadCount];
            }
            
            if (isShowDetailPage == YES){
                tmpItem.isRead = YES;
                
                if (tmpItem != nil){
                    [poApp.dataSvr setPushNews:tmpItem];
                }
                
                MMEventService *es = [MMEventService getInstance];
                [es send:EVENT_PUSH_NEWS_SHOW  eventData:nil];
            }
        }
    }];
}
-(void) getHotCommnet: (NSDictionary *) param{

    if (param == nil) {
        return;
    }
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@/api/comment/condition?i_id=%@&hottest_list=true&per_page=%@",[self getBaseUrl],[param objectForKey:@"i_id"],[param objectForKey:@"per_page"]];
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        if (code == 200) {
            
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
//            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSLog(@"%@",dataDic);
            ITSApplication* poApp = [ITSApplication get];
            if ([[param objectForKey:@"per_page"] integerValue ] == 3) {
                [poApp.dataSvr setPoDetailHotCommentList:dataDic];
            }else{
                [poApp.dataSvr setPoHotComentList:dataDic];
            }
        }
  }];
}
-(void) getMyComment: (NSDictionary *) param{
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@/api/comment/user/%@?channel=%@",[self getBaseUrl],[param objectForKey:@"uid"],[param objectForKey:@"channel"]];
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        if (code == 200) {
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            NSMutableArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
//            NSLog(@"%@",dataDic);
            ITSApplication* poApp = [ITSApplication get];
            [poApp.dataSvr setPoMyCommentList:dataDic];
        }
    }];
}
-(void) getComment: (NSDictionary *) param{
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@/api/comment?i_id=%@&page=%@&per_page=%@",[self getBaseUrl],[param objectForKey:@"i_id"],[param objectForKey:@"page"],[param objectForKey:@"per_page"]];
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        if (code == 200) {
            
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
//            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSDictionary* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSLog(@"%@",dataDic);
            ITSApplication* poApp = [ITSApplication get];
            [poApp.dataSvr setPoCommentList:dataDic];
        }
    }];
}
-(void) doFavourData: (NSString *)id{
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@/api/comment/approval?id=%@&path=null",[self getBaseUrl],id];
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doGet:url reqHeader:nil callback:^(int status, int code, NSDictionary *resultData) {
        if (code == 200) {
            
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            //            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSLog(@"%@",dataDic);
        }
    }];
}
-(void) postNewsComment: (NSDictionary *)param{
    
    NSString *url = [[NSString alloc] initWithFormat:@"%@/api/comment",[self getBaseUrl]];
    MMHttpSession* httpSession = [MMHttpSession alloc];
    [httpSession doPostJSON:url reqHeader:nil reqBody:param callback:^(int status, int code, NSDictionary *resultData)
    {
        if (code == 200) {
            NSData* data = [resultData objectForKey:@"data"];
            NSError* err;
            //        NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSMutableArray* dataDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            NSLog(@"%@",dataDic);
        }
    }];
}
@end