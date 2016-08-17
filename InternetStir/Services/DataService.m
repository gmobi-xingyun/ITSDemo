
//
//  DataService.m
//  PoPoNews
//
//  Created by apple on 15/4/17.
//  Copyright (c) 2015年 Gmobi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataService.h"
#import "ConfigService.h"
#import "ITSApplication.h"
#import "ITSAppConst.h"
#import "MMSystemHelper.h"
#import "MMEventService.h"
#import "NewsService.h"
#import "SettingService.h"
#import "MMDictionaryHelper.h"

//#import "Go2Reach.framework/Headers/GRAdService.h"

#define NATIVE_AD_PLACEMENT_FORMAT @"ch:{ch}/dch:{dch}/list:{cid}";
#define BANNER_AD_PLACEMENT_FORMAT @"ch:{ch}/dch:{dch}/ab:{publisher}";
#define INTERSTITIAL_AD_PLACEMENT_FORMAT @"ch:{ch}/dch:{dch}/ai:{publisher}";
#define CATEGORY_CUSTOM_LAYOUT_PERFIX @"cate_c_layout"

#define SAVED_USER_CATEGORY_LIST @"saved.user.category.data"

@implementation BaiduPlusUser

@end

@implementation PoPoBDuser

@end

@implementation WeiboUsers

@end

@implementation PoPoWEuser

@end

@implementation TwitterUser

@end

@implementation PopoTWuser

@end

@implementation GoolgePlusUser

@end

@implementation PopoGPUser

@end

@implementation FBPaging

@end

@implementation FBUser

@end

@implementation PopoFBUser

@end

@implementation PopoSocialNewItem

@end

@implementation PopoSocialDataItem

@end

@implementation OfflineCategoryItem


@end

@implementation FavourNewsItem


@end

@implementation ReadedNewsItem


@end

@implementation SettingItem


@end

@implementation LeftMenuItem

@end

@implementation loginOutMenuItem

@end

@implementation PopoNewsChannelInfo

@end

@implementation PopoNewsChannel

@end


@implementation StorageUserCategory

-(StorageUserCategory*) initWithDict: (NSDictionary*) dict{
    if (dict != nil){
        NSString* tmpCId = [dict objectForKey:@"cid"];
        if (tmpCId != nil)
            self.cid = tmpCId;
        
        NSNumber* tmpHidden = [dict objectForKey:@"hidden"];
        self.hidden = [tmpHidden boolValue];
    }
    
    return self;
}

-(NSDictionary*) toDict{
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [resultDict setObject:self.cid forKey:@"cid"];
    [resultDict setObject:[NSNumber numberWithBool:self.hidden] forKey:@"hidden"];
    
    return resultDict;
}

@end


@implementation DataService

- (void)clearFBSocialNews{


}
-(void) initPopoNewsListCategory {
    if (self.poponewsList == nil)
        self.poponewsList = [NSMutableArray arrayWithCapacity:3];
    else
        [self.poponewsList removeAllObjects];
    
    if (self.categoryList != nil){
        for(NewsCategory* cate in self.categoryList){
            PopoNewsData* poData = [PopoNewsData alloc];
            poData.category = cate;
            poData.data = nil;
            //poData.gridData = nil;
            poData.nativeAdData = nil;
         //   poData.newsList = nil;
            [self.poponewsList addObject:poData];
        }
    }
    
    if (self.socialCategory != nil){
        PopoNewsData* poData = [PopoNewsData alloc];
        poData.category = self.socialCategory;
        poData.data = nil;
        //poData.gridData = nil;
        poData.nativeAdData = nil;
     //   poData.newsList = nil;
        [self.poponewsList addObject:poData];
    }
}

-(NSString*) getServerDeviceId{
    return self.did;
}

-(NSMutableArray*) getNewsCategoryList{
    return self.categoryList;
}

-(NSMutableArray*) getLoginOutList{
    
    [self refreshloginOut];
    
    return self.loginOutList;
}
- (void)refreshloginOut{
    if (self.loginOutList == nil)
        self.loginOutList = [NSMutableArray arrayWithCapacity:3];
    else
        [self.loginOutList removeAllObjects];
    
    loginOutMenuItem* facebook = [loginOutMenuItem alloc];
    facebook.iconName = @"facebook_1";
    facebook.actionName = @"facebook";
    facebook.isLogin = NO;
    [self.loginOutList addObject:facebook];
    
    loginOutMenuItem* twitter = [loginOutMenuItem alloc];
    twitter.iconName = @"twitter_1";
    twitter.actionName = @"twitter";
    twitter.isLogin = NO;
    [self.loginOutList addObject:twitter];
    //
    loginOutMenuItem* google = [loginOutMenuItem alloc];
    google.iconName = @"google_1";
    google.actionName = @"google";
    google.isLogin = NO;
    [self.loginOutList addObject:google];
    
}
-(NSMutableArray*) getLeftMenuList{

    [self refreshLeftMenu];
    
    return self.leftMenuList;
}

-(NSMutableArray*) getShowCategoryList{
    if (self.showCategoryList == nil)
        [self refreshShowCategoryList];
    
    return self.showCategoryList;
}

-(int) getShowCategoryListActiveCount{
    if (self.showCategoryList == nil)
        [self refreshShowCategoryList];
    
    int count = 0;
    
    if (self.showCategoryList != nil){
        for (NewsCategory* item in self.showCategoryList) {
            if (item != nil){
                if (item.hidden == NO && ![item.type isEqualToString:@"social"])
                    count++;
            }
        }
    }
    
    return count;
}

-(NewsCategory*) getShowCategoryByIndex: (NSInteger) index{
    if (self.showCategoryList == nil)
        [self refreshShowCategoryList];
    
    int showIndex = 0;
    
    if (self.showCategoryList != nil){
        for (NewsCategory* item in self.showCategoryList) {
            if (item != nil){
                if (item.hidden == YES || [item.type isEqualToString:@"social"])
                    continue;
                
                if (index == showIndex)
                    return item;
                    
                if (item.hidden == NO)
                    showIndex++;
            }
        }
    }
    
    return nil;
}

-(void) refreshShowCategoryList{
    if (self.showCategoryList == nil)
        self.showCategoryList = [NSMutableArray arrayWithCapacity:3];
    else
        [self.showCategoryList removeAllObjects];
    
    SettingService* ss = [SettingService get];
    ConfigService *cf = [ConfigService get];
    NSString *ch = [cf getChannel];
    NSString *savedKey = [NSString stringWithFormat:@"%@_%@", SAVED_USER_CATEGORY_LIST, ch];
    NSArray* savedList = nil;//[ss getArrayValue:savedKey defValue:nil];  // close user set category order feature
    
    if (savedList == nil){
        for (NewsCategory* item in self.categoryList) {
            if (item != nil){
                item.hidden = NO;
                [self.showCategoryList addObject:item];
            }
        }
    } else {
        NSMutableArray* tmpCategoryList = [NSMutableArray arrayWithCapacity:1];
        for (NewsCategory* item in self.categoryList) {
            if (item != nil){
                item.hidden = NO;
                [tmpCategoryList addObject:item];
            }
        }
        
        for (int i = 0; i < [savedList count]; i++) {
            NSDictionary* cData = [savedList objectAtIndex:i];
            StorageUserCategory* tmpCate = [StorageUserCategory alloc];
            [tmpCate initWithDict:cData];
            
            for (int j = 0; j < [tmpCategoryList count]; j++) {
                NewsCategory* tItem = [tmpCategoryList objectAtIndex:j];
                if ([tItem.cId isEqualToString:tmpCate.cid]){
                    tItem.hidden = tmpCate.hidden;
                    [tmpCategoryList removeObject:tItem];
                    
                    [self.showCategoryList addObject:tItem];
                    break;
                }
            }
            
        }
        
        
        for (NSInteger m = [tmpCategoryList count] - 1; m >= 0; m--) {
            NewsCategory* tItem = [tmpCategoryList objectAtIndex:m];
            
            if (tItem != nil){
                if ([tItem.type isEqualToString:@"social"]){
                    [self.showCategoryList addObject:tItem];
                } else {
                    [self.showCategoryList insertObject:tItem atIndex:0];
                }
            }
        }
    }
}

-(void) saveShowCategoryList{
    if (self.showCategoryList != nil){
        NSMutableArray* saveArray = nil;
        StorageUserCategory* tmpCate = [StorageUserCategory alloc];
        
        for (NewsCategory* item in self.showCategoryList) {
            if (item != nil){
                if ([item.type isEqualToString:@"social"])
                    continue;
                
                if (saveArray == nil)
                    saveArray = [NSMutableArray arrayWithCapacity:1];
                
                tmpCate.cid = item.cId;
                tmpCate.hidden = item.hidden;
                
                NSDictionary* tData = [tmpCate toDict];
                [saveArray addObject:tData];
            }
        }
        
        if (saveArray != nil){
            ConfigService *cf = [ConfigService get];
            NSString *ch = [cf getChannel];
            NSString *savedKey = [NSString stringWithFormat:@"%@_%@", SAVED_USER_CATEGORY_LIST, ch];
            SettingService* ss = [SettingService get];
            [ss setArrayValue:savedKey data:saveArray];
        }
    }
}

-(void) refreshLeftMenu{
    if (self.leftMenuList == nil)
        self.leftMenuList = [NSMutableArray arrayWithCapacity:3];
    else
        [self.leftMenuList removeAllObjects];
    
    LeftMenuItem* fav = [LeftMenuItem alloc];
    fav.iconName = @"范冰冰";
    fav.actionName = @"我的收藏";
    [self.leftMenuList addObject:fav];

    LeftMenuItem* comment = [LeftMenuItem alloc];
    comment.iconName = @"范冰冰";
    comment.actionName = @"留言追蹤";
    [self.leftMenuList addObject:comment];
    // fav
    LeftMenuItem* download = [LeftMenuItem alloc];
    download.iconName = @"范冰冰";
    download.actionName = @"貼圖下載";
    [self.leftMenuList addObject:download];
    
    LeftMenuItem* feed = [LeftMenuItem alloc];
    feed.iconName = @"范冰冰";
    feed.actionName = @"買數位產品";
    [self.leftMenuList addObject:feed];

    LeftMenuItem* histroy = [LeftMenuItem alloc];
    histroy.iconName = @"范冰冰";
    histroy.actionName = @"買點數";
    [self.leftMenuList addObject:histroy];

//    LeftMenuItem* download = [LeftMenuItem alloc];
//    download.iconName = @"sidebar_offlinedownload";
//    download.actionName = PPN_NSLocalizedString(@"LMenuDownload", nil);
//    [self.leftMenuList addObject:download];

    LeftMenuItem* settings = [LeftMenuItem alloc];
    settings.iconName = @"范冰冰";
    settings.actionName = @"粉絲牆";
    [self.leftMenuList addObject:settings];
    
    LeftMenuItem* menu = [LeftMenuItem alloc];
    menu.iconName = @"范冰冰";
    menu.actionName = @"購買清單";
    [self.leftMenuList addObject:menu];
}

-(NSMutableArray*) getSettingList{

//    if (self.settingList != nil){
//        return self.settingList;
//    }
    
    if (self.settingList == nil)
        self.settingList = [NSMutableArray arrayWithCapacity:3];
    else
        [self.settingList removeAllObjects];
    
    
    ITSApplication* poApp = [ITSApplication get];
    DataService* ds = poApp.dataSvr;
    
    NSMutableArray* chList = [ds getPoNewsChannelList];
    
    if (chList != nil && [chList count] > 1){
        SettingItem* edition = [SettingItem alloc];
        edition.iconName = @"set_edition";
        
        edition.settingName = ITS_NSLocalizedString(@"SettingEdition", nil);
        edition.type = SettingTypeDetail;
        edition.actionType = SETTING_ACTION_EDITION;
        [self.settingList addObject:edition];
    }
    
    SettingItem* clearCache = [SettingItem alloc];
    clearCache.iconName = @"set_clean";
    clearCache.settingName = ITS_NSLocalizedString(@"SettingClearCache", nil);
    clearCache.type = SettingTypeButton;
    clearCache.actionType = SETTING_ACTION_CLEAN_CACHE;
    [self.settingList addObject:clearCache];
    
    SettingItem* video = [[SettingItem alloc] init];
    video.iconName = @"setting_autoplay";
    video.settingName = ITS_NSLocalizedString(@"SettingVideo", nil);
    video.type = SettingTypeSwitch;
    video.actionType = SETTING_ACTION_VIDEO;
    video.isSwitch = NO;
    [self.settingList addObject:video];
    
    SettingItem* feedBack = [SettingItem alloc];
    feedBack.iconName = @"set_feed";
    feedBack.settingName = ITS_NSLocalizedString(@"SettingFeedBack", nil);
    feedBack.type = SettingTypeDetail;
    feedBack.actionType = SETTING_ACTION_FEEDBACK;
    [self.settingList addObject:feedBack];

    SettingItem* about = [SettingItem alloc];
    about.iconName = @"set_about";
    about.settingName = ITS_NSLocalizedString(@"SettingAbout", nil);
    about.type = SettingTypeDetail;
    about.actionType = SETTING_ACTION_ABOUT;
    [self.settingList addObject:about];
    
    return self.settingList;
}

-(void) setConnectRespData: (NSDictionary*) dicData{
    if (dicData != nil){
        
        MMLogDebug(@"Connect Rsp : %@", [MMSystemHelper DictTOjsonString:dicData]);
        
        SettingService* ss = [SettingService get];
        [ss setDictoryValue:CONFIG_LAST_CONNECT_INFO data:dicData];
        
        NSString* tmpData = [dicData objectForKey:@"baseUrl"];
        if (tmpData != nil)
            self.fileBaseUrl = tmpData;
        
        NSArray* tmpCateList = [dicData objectForKey:@"categories"];
        if (tmpCateList != nil){
            NSMutableArray* newCateList = [NSMutableArray arrayWithCapacity:1];
            for(NSDictionary* item in tmpCateList){
                if (item != nil){
                    NewsCategory* cate = [[NewsCategory alloc] initWithDictionary:item];
                    //if (cate != nil && [cate.type compare:@"news"] == NSOrderedSame){
                    if (cate != nil){
                        if ([cate.type isEqualToString:@"social"]){
                            self.socialCategory = cate;
                        } else {
                            cate.hidden = NO;
                            [newCateList addObject:cate];
                        }
                        
                        NSString* customCId = [NSString stringWithFormat:@"%@_%@", CATEGORY_CUSTOM_LAYOUT_PERFIX, cate.cId];
                        NSString* customLayout = [ss getStringValue:customCId defValue:nil];
                        if (customLayout != nil)
                            cate.layout = customLayout;
                    }
                }
            }
            self.categoryList = newCateList;
            [self initPopoNewsListCategory];

            //[self initFBUsersData];
           
            //[self initTWUsersData];
            //[app.twSvr initTWNewsData];
            
            //[self initWEUsersData];
            //[app.weSvr initWBNewsData];
            
            [self initUser];

        }
        
        tmpData = [dicData objectForKey:@"channel"];
        if (tmpData != nil){
            self.connectRspCh = tmpData;
            ConfigService* cs = [ConfigService get];
            [cs setChannel:tmpData];
        }
        
        NSDictionary* tmpChInfoList = [dicData objectForKey:@"channelInfo"];
        if (tmpChInfoList != nil){
            NSString* tmpCountry = [tmpChInfoList objectForKey:@"country"];
            NSString* tmpLang = [tmpChInfoList objectForKey:@"lang"];
            NSString* tmpMiniKit = [tmpChInfoList objectForKey:@"minikit"];
            NSDictionary *natDic = [tmpChInfoList objectForKey:@"ad1"];
            NSDictionary *intDic = [tmpChInfoList objectForKey:@"ad2"];
            NSDictionary *banDic = [tmpChInfoList objectForKey:@"ad3"];
            NSDictionary *ad4 = [tmpChInfoList objectForKey:@"ad4"];
            NSDictionary *ad5 = [tmpChInfoList objectForKey:@"ad5"];
            NSDictionary *extra = [tmpChInfoList objectForKey:@"extra"];
            NSMutableArray *share = [extra objectForKey:@"share"];
            NSMutableArray *login = [tmpChInfoList objectForKey:@"three_login"];
            PopoNewsChannelInfo* miniKitCh = [PopoNewsChannelInfo alloc];
            miniKitCh.shareItem = [[NSMutableArray alloc] init];
            miniKitCh.threeLogin = [[NSMutableArray alloc] init];
            if (login != nil) {
                miniKitCh.threeLogin = login;
            }

            if (natDic != nil) {
                NativeAd *nativeAd = [NativeAd alloc];
                [nativeAd setValuesForKeysWithDictionary:natDic];
//                nativeAd.count = [natDic objectForKey:@"count"];
//                nativeAd.enabled = [[natDic objectForKey:@"enabled"] boolValue];
                miniKitCh.nativeAd = nativeAd;
            }
            if (intDic != nil) {
                InterstitialAd *interstitalAd = [InterstitialAd alloc];
                [interstitalAd setValuesForKeysWithDictionary:intDic];
//                interstitalAd.enabled = [[intDic objectForKey:@"enabled"] boolValue];
//                interstitalAd.time = [intDic objectForKey:@"time"];
                miniKitCh.InterstitialAd = interstitalAd;
            }
            if (banDic != nil) {
                BannerAd *bannerAd = [BannerAd alloc];
                [bannerAd setValuesForKeysWithDictionary:banDic];
//                bannerAd.enabled = [[banDic objectForKey:@"enabled"] boolValue];
                miniKitCh.bannerAd = bannerAd;
            }
            if (ad4 != nil) {
                Interstitial *ad = [Interstitial alloc];
                [ad setValuesForKeysWithDictionary:ad4];
                miniKitCh.ad = ad;
            }
            if (ad5 != nil){
                DetailAd *dAd = [DetailAd alloc];
                [dAd setValuesForKeysWithDictionary:ad5];
                miniKitCh.detailAd = dAd;
            }
            if (tmpCountry != nil && tmpLang != nil && tmpMiniKit != nil){
               
                miniKitCh.country = tmpCountry;
                miniKitCh.lang = tmpLang;
                miniKitCh.ch = tmpMiniKit;
            }
            self.minikitCh = miniKitCh;
        }
        
        [self initNativeAds];
        [self initUser];
        [self initDetailNativeAds];
        
        NSArray* tmpRspChList = [dicData objectForKey:@"channels"];
        [self setPoNewsChannelList:tmpRspChList];
        
        tmpData = [dicData objectForKey:@"did"];
        if (tmpData != nil) {
            self.did = tmpData;
            SettingService* ss = [SettingService get];
            [ss setStringValue:POPONEWS_SERVER_DEVICE_ID data:tmpData];
        }
        
        tmpData = [dicData objectForKey:@"group"];
        if (tmpData != nil)
            self.connectRspGroup = tmpData;
        
        NSNumber* tmpUpdate = [dicData objectForKey:@"update"];
        if (tmpUpdate != nil){
            self.update = (int)[tmpUpdate integerValue];
        }
        
        // init last news
        if (self.poponewsList != nil) {
            NewsService* ns = [NewsService get];
            for (int i = 0; i < [self.poponewsList count]; i++) {
                PopoNewsData* item = [self.poponewsList objectAtIndex:i];
                NewsCategory* cate = item.category;
                if (cate != nil){
                    NSMutableArray* storageData = [ns getStorageNewsListByCID:cate.cId];
                    [self setRefreshCategoryNewsByStroage:cate.cId newsList:storageData];
                }
            }
        }
    }
}
-(void) initNativeAds{
    
    BOOL AdIsOpen = self.minikitCh.nativeAd.enabled;
    int count = [self.minikitCh.nativeAd.count intValue];
    self.itemData = [[PopoNewsData alloc] init];
    if (self.itemData.nativeAdData == nil){
        self.itemData.nativeAdData = [NSMutableArray arrayWithCapacity:1];
    }
    if (AdIsOpen == YES) {
        NativeAdItem *item = [[NativeAdItem alloc] init];
        int percent = [self.minikitCh.nativeAd.fb intValue];
        int value = [self getRandomValue];
        if (value <= percent) {
            [item initWithData:FACEBOOK_LIST_PLACEMENT_ID :count :@"fbAd"];
        }else{
            [item initWithData:FACEBOOK_LIST_PLACEMENT_ID :count :@"gmobiAd"];
        }
        [item load];
        [self.itemData.nativeAdData addObject:item];
    }
    if (self.fbAd == nil) {
        self.fbAd = [NSMutableArray arrayWithCapacity:1];
    }
    if (self.gmobiAd == nil) {
        self.gmobiAd = [NSMutableArray arrayWithCapacity:1];
    }
}

-(void) initDetailNativeAds{
    BOOL AdIsOpen = self.minikitCh.detailAd.enabled;
    if (AdIsOpen == YES) {
        
        if (self.minikitCh.detailAd != nil && self.minikitCh.detailAd.enabled == YES){
            self.gmobiDetailAdItem = [[PNNativeAdItem alloc] init];
            
            [self.gmobiDetailAdItem initWithData:@"article_inside" count:20 ];
            [self.gmobiDetailAdItem load];
        }
    }
}


-(int)getRandomValue {
    int value = arc4random()%100 + 1;
    return value;
}

-(NativeAdItem*)getNativeAdItem:(NSString*)cid{

    NativeAdItem *adItem;
    if (self.poponewsList != nil && cid != nil){
        for (PopoNewsData* item in self.poponewsList) {
            if (item != nil){
                if ([item.category.cId compare:cid] == NSOrderedSame){
                    if (item.nativeAdData != nil){
                        adItem = [item.nativeAdData objectAtIndex:0];
                    }
                }
            }
        }
    }
    
    return adItem;
}

-(void) refreshCategoryNews: (NSString*) cid
                refreshType: (int) type {
    BOOL isNetConnect = [MMSystemHelper isConnectedToNetwork];
    if (isNetConnect == NO){
        if (type == NEWS_REFRESH_TYPE_AFTER){
            // do nothing
        } else if (type == NEWS_REFRESH_TYPE_BEFORE){
            // load storage data
            NewsService* ns = [NewsService get];
            NSMutableArray* storageData = [ns getStorageNewsListByCID:cid];
            [self setRefreshCategoryNewsByStroage:cid newsList:storageData];
        }
        MMEventService *es = [MMEventService getInstance];
        [es send:[[NSString alloc] initWithFormat:@"%@_%@", EVENT_NEWS_DATA_REFRESH_PREFIX, cid]  eventData:NEWS_REFRESH_SUCCESS];
    } else {
//        NSMutableArray* datas = [self getCategoryDataByID:cid];
//        NSString* newsTime = nil;    
//        if (datas != nil && [datas count] > 0){
//            PoPoNewsItem* newsItem = nil;
//            if (type == NEWS_REFRESH_TYPE_AFTER){
//                newsItem = [datas objectAtIndex:0];
//                if (newsItem.initType == NEWS_INIT_TYPE_CLIENT)
//                    newsItem = nil;
//            } else if (type == NEWS_REFRESH_TYPE_BEFORE){
//                NSInteger dataCount = [datas count];
//                newsItem = [datas objectAtIndex:dataCount-1];
//                if (newsItem.initType == NEWS_INIT_TYPE_CLIENT){
//                    // load storage data
//                    NewsService* ns = [NewsService get];
//                    NSMutableArray* storageData = [ns getStorageNewsListByCID:cid];
//                    if (storageData != nil){
//                        [self setRefreshCategoryNewsByStroage:cid newsList:storageData];
//                        MMEventService *es = [MMEventService getInstance];
//                        [es send:[[NSString alloc] initWithFormat:@"%@_%@", EVENT_NEWS_DATA_REFRESH_PREFIX, cid]  eventData:NEWS_REFRESH_SUCCESS];
//                        return;
//                    }
//                }
//            }
//            
//            if (newsItem != nil)
//                newsTime = [[NSString alloc] initWithFormat:@"%llu", newsItem.releaseTime];
//        }
        
        NewsCategory *cate = [self getCategoryByID:cid];
        NSString* newsTime = nil;
        if (type == NEWS_REFRESH_TYPE_AFTER) {
            newsTime = [NSString stringWithFormat:@"%llu",cate.afterTime];
        }else{
            newsTime = [NSString stringWithFormat:@"%llu",cate.beforeTime];
        }
        //[[ITSApplication get].remoteSvr getNewsListData:cid time:newsTime timeType:type];
    }
}

-(BOOL) insertNewsItem: (NSMutableArray*) list
                 news: (PoPoNewsItem*) item{
    BOOL same = NO;
    BOOL ret = NO;
    int i = 0;

    if (list == nil || item == nil)
        return ret;
    
    int listCount = (int)[list count];
    for (i = 0; i < listCount; i++) {
       // PoPoNewsItem* newItem = [list objectAtIndex:i];
        id news = [list objectAtIndex:i];
        if ([news isKindOfClass:[PoPoNewsItem class]]) {
            PoPoNewsItem* newItem = news;
            if (newItem != nil){
                if ([newItem.nId compare:item.nId] == NSOrderedSame) {
                    same = YES;
                    
                    if (item.isOfflineDL == YES && newItem.isOfflineDL == NO){
                        newItem.isOfflineDL = YES;
                    }
                    
                    break;
                }
                
                if (newItem.releaseTime < item.releaseTime) {
                    [list insertObject:item atIndex:i];
                    ret = YES;
                    break;
                }
            }
        }
    }
    
    if (same == NO && ret == NO){
        [list addObject:item];
        ret = YES;
    }
    
    return ret;
}
-(void) setRefreshCategoryNew: (NSString*) cid
                      newsList: (NSArray*) dicData
                   isClearData: (BOOL) clear {
    if (cid == nil || dicData == nil || self.poponewsList == nil)
        return;
    
    NewsService* ns = [NewsService get];
    
    for (PopoNewsData* itemData in self.poponewsList){
        NSString* itemCid = itemData.category.cId;
        if (itemData.data == nil)
            itemData.data = [NSMutableArray arrayWithCapacity:1];
        
        if ([itemCid compare:cid] == NSOrderedSame){
            
            NSString* itemLayout = itemData.category.layout ;
            // category layout is "grid"
            
            if (clear == YES){
                [itemData.data removeAllObjects];
            }
            
            for (NSDictionary* newsDataItem in dicData) {
                PoPoNewsItem* tmpItem = [[PoPoNewsItem alloc] initWithDictionary:newsDataItem];
                [tmpItem setNewsInitType:NEWS_INIT_TYPE_SERVER];
                
                if (tmpItem != nil) {
                    
                    // init mood data
                    if (ns != nil){
                        NSDictionary* savedData = [ns getPopoNewsItem:tmpItem.nId];
                        PoPoNewsItem* savedNew = [[PoPoNewsItem alloc] initWithDictionary:savedData];
                        if (savedNew != nil){
                            NSString* moodMyType = [savedNew.mood getMyMoodType];
                            if (moodMyType != nil)
                                [tmpItem.mood setMyMoodType:moodMyType];
                            [ns savePopoNewsItem:tmpItem.nId data:[tmpItem toDictionaryData]];
                        } else {
                            [ns savePopoNewsItem:tmpItem.nId data:newsDataItem];
                        }
                    }
                    // check is favour
                    BOOL isFind = [self isInFavourList:tmpItem];
                    if (isFind == YES){
                        tmpItem.isMyFav = YES;
                        tmpItem.didFav = YES;
                        tmpItem.fav++;
                        if (tmpItem.fav > 1) {
                            tmpItem.fav = 1;
                        }
                    }
                    
                    // check read list
                    BOOL isRead = [self isInReadList:tmpItem];
                    if (isRead == YES)
                        tmpItem.isRead = YES;
                    [self insertNewsItem:itemData.data news:tmpItem];

                    
                }
            }
            
            break;
        }
    }
}
-(void) setRefreshCategoryNews: (NSString*) cid
                      newsList: (NSArray*) dicData
                   isClearData: (BOOL) clear type:(int)type{
    if (cid == nil || dicData == nil || self.poponewsList == nil)
        return;
    
    NewsService* ns = [NewsService get];
    NewsCategory *cate = [self getCategoryByID:cid];

    for (PopoNewsData* itemData in self.poponewsList){
        NSString* itemCid = itemData.category.cId;
        if (itemData.data == nil)
            itemData.data = [NSMutableArray arrayWithCapacity:1];
        
        if ([itemCid compare:cid] == NSOrderedSame){
            if (clear == YES){
                [itemData.data removeAllObjects];
            }
            for (NSDictionary* newsDataItem in dicData) {
                PoPoNewsItem* tmpItem = [[PoPoNewsItem alloc] initWithDictionary:newsDataItem];
                [tmpItem setNewsInitType:NEWS_INIT_TYPE_SERVER];
             
                if (cate.afterTime == 0) {
                    cate.afterTime = tmpItem.releaseTime;
                }
                if (cate.beforeTime == 0) {
                    cate.beforeTime = tmpItem.releaseTime;
                }
                if (cate.afterTime < tmpItem.releaseTime ) {
                    cate.afterTime = tmpItem.releaseTime;
                }
                if (cate.beforeTime > tmpItem.releaseTime) {
                    cate.beforeTime = tmpItem.releaseTime;
                }
    
                // 
                {
                    BOOL isUnlike = NO;
                    for (PoPoNewsItem *unLikeNews in self.unLikeNewsList) {
                        if ([unLikeNews.nId compare:tmpItem.nId] == NSOrderedSame) {
                            isUnlike = YES;
                            break;
                        }
                    }
                    if (isUnlike == YES)
                        continue;
                }
                
                if (tmpItem != nil) {
                
                    // init mood data
                    if (ns != nil){
                        NSDictionary* savedData = [ns getPopoNewsItem:tmpItem.nId];
                        PoPoNewsItem* savedNew = [[PoPoNewsItem alloc] initWithDictionary:savedData];
                        if (savedNew != nil){
                            NSString* moodMyType = [savedNew.mood getMyMoodType];
                            if (moodMyType != nil)
                                [tmpItem.mood setMyMoodType:moodMyType];
                            [ns savePopoNewsItem:tmpItem.nId data:[tmpItem toDictionaryData]];
                        } else {
                            [ns savePopoNewsItem:tmpItem.nId data:newsDataItem];
                        }
                    }
                    // check is favour
                    BOOL isFind = [self isInFavourList:tmpItem];
                    if (isFind == YES){
                        tmpItem.isMyFav = YES;
                        tmpItem.didFav = YES;
                        tmpItem.fav++;
//                        if (tmpItem.fav > 1) {
//                            tmpItem.fav = 1;
//                        }
                    }
                    
                    // check read list
                    BOOL isRead = [self isInReadList:tmpItem];
                    if (isRead == YES)
                        tmpItem.isRead = YES;
                    if (itemData != nil && itemData.data != nil){
                        [self insertNewsItem:itemData.data news:tmpItem];
                    }
                }
            }
            
            NSMutableArray* newsGridList = nil;
            NSString* itemLayout = itemData.category.layout;
           
            [self getNewsNewsListWithAdList:cid :type];
            
            NSString *forKey = [NSString stringWithFormat:@"%@",cid];
            int getLastCount = [[[NSUserDefaults standardUserDefaults] objectForKey:forKey] intValue];
            NSInteger count = itemData.data.count - getLastCount;
            int lastCount = (int)itemData.data.count;

            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",lastCount] forKey:forKey];
            // category layout is "grid"
            
            [itemData resetTopPhotoIndex];
            break;
        }
    }
}
//unlike
-(BOOL) insert2UnLikeNewsList: (PoPoNewsItem*) item
                     saveFlag: (BOOL) saved{
    if (item == nil)
        return NO;
    
    BOOL isFind = NO;
    
    if (self.unLikeNewsList == nil){
        self.unLikeNewsList = [NSMutableArray arrayWithCapacity:1];
    }
    
    for (PoPoNewsItem* tmpItem in self.unLikeNewsList) {
        if (tmpItem != nil){
            PoPoNewsItem* newsItem = tmpItem;
            if (newsItem == item || [newsItem.nId compare:item.nId] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    if (isFind == NO){
        [self.unLikeNewsList insertObject:item atIndex:0];
        
        long listCount = [self.unLikeNewsList count];
        if (listCount > MAX_UNLIKE_NEWS_COUNT){
            [self.unLikeNewsList removeObjectAtIndex:listCount-1];
        }
        
        if (saved == YES){
            // save to db
            NewsService* ns = [NewsService get];
            [ns saveUnLikeNewsItem:item.nId data:[item toDictionaryData]];
        }
        return YES;
    }
    
    return NO;


}
-(void) initUnLikeNewsList{

    NewsService* ns = [NewsService get];
    NSMutableArray* pList = [ns getStorageUnLikeNewsList];
    if (pList != nil){
        if (self.unLikeNewsList != nil){
            [self.unLikeNewsList removeAllObjects];
            self.unLikeNewsList = nil;
        }
        self.unLikeNewsList = [NSMutableArray arrayWithArray:pList];
    }
}
-(NSMutableArray*) getUnLikeNewsList{
    
    return self.unLikeNewsList;
}
-(void) setRefreshCategoryNewsByStroage: (NSString*) cid
                               newsList: (NSMutableArray*) newsData{
    if (cid == nil || newsData == nil || self.poponewsList == nil)
        return;
//    NewsCategory *cate = [self getCategoryByID:cid];

    for (int i = 0; i < [self.poponewsList count]; i++) {
        PopoNewsData* itemData = [self.poponewsList objectAtIndex:i];
        NSString* itemCid = itemData.category.cId;
        if (itemData.data == nil)
            itemData.data = [NSMutableArray arrayWithCapacity:1];
        
        if ([itemCid compare:cid] == NSOrderedSame){
            NSString* itemLayout = itemData.category.layout;
            // category layout is "grid"
            for (int j = 0; j < [newsData count]; j++) {
                PoPoNewsItem* tmpItem = [newsData objectAtIndex:j];
//                {
//                    BOOL isUnlike = NO;
//                    for (PoPoNewsItem *unLikeNews in self.unLikeNewsList) {
//                        if ([unLikeNews.nId compare:tmpItem.nId] == NSOrderedSame) {
//                            isUnlike = YES;
//                            break;
//                        }
//                    }
//                    if (isUnlike == YES)
//                        continue;
//                }
                
                if (tmpItem != nil) {
                    // check is favour
                    BOOL isFind = [self isInFavourList:tmpItem];
                    if (isFind == YES){
                        tmpItem.isMyFav = YES;
                        tmpItem.didFav = YES;
                        tmpItem.fav++;
//                        if (tmpItem.fav > 1) {
//                            tmpItem.fav = 1;
//                        }
                    }
                    // check read list
                    BOOL isRead = [self isInReadList:tmpItem];
                    if (isRead == YES)
                        tmpItem.isRead = YES;
                    [self insertNewsItem:itemData.data news:tmpItem];
                }
            }
            
            NSMutableArray* newsGridList = nil;
//            if (itemData.newsList == nil) {
//                itemData.newsList = itemData.data;
//            }
           // [self getNewsNewsListWithAdList:cid :NEWS_REFRESH_TYPE_BEFORE];
           [self getNewsNewsListWithAdList:cid :NEWS_REFRESH_TYPE_BEFORE];
            NSInteger count = itemData.data.count - itemData.lastCount;
            itemData.lastCount = (int)itemData.data.count;
            
            NSMutableArray *newsList = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < itemData.data.count; i++) {
                if (i >= itemData.data.count - count) {
                    id item = [itemData.data objectAtIndex:i];
                    [newsList addObject:item];
                }
            }
            for (NSInteger i = 0; i < newsList.count; i++) {
                id tmpItem = nil;
                tmpItem = [newsList objectAtIndex:i];
            }
            
            [itemData resetTopPhotoIndex];
            break;
        }
    }
}
-(void) setRefreshCategoryNewsByStroages: (NSString*) cid
                      newsList: (NSMutableArray*) newsData{
    if (cid == nil || newsData == nil || self.poponewsList == nil)
        return;
    
    for (int i = 0; i < [self.poponewsList count]; i++) {
        PopoNewsData* itemData = [self.poponewsList objectAtIndex:i];
        NSString* itemCid = itemData.category.cId;
        if (itemData.data == nil)
            itemData.data = [NSMutableArray arrayWithCapacity:1];
        
        if ([itemCid compare:cid] == NSOrderedSame){
            NSString* itemLayout = itemData.category.layout;
            // category layout is "grid"
            
            for (int j = 0; j < [newsData count]; j++) {
                PoPoNewsItem* tmpItem = [newsData objectAtIndex:j];
                if (tmpItem != nil) {
                    // check is favour
                    BOOL isFind = [self isInFavourList:tmpItem];
                    if (isFind == YES){
                        tmpItem.isMyFav = YES;
                        tmpItem.didFav = YES;
                        tmpItem.fav++;
//                        if (tmpItem.fav > 1) {
//                            tmpItem.fav = 1;
//                        }
                    }
                    // check read list
                    BOOL isRead = [self isInReadList:tmpItem];
                    if (isRead == YES)
                        tmpItem.isRead = YES;
                    [self insertNewsItem:itemData.data news:tmpItem];
                    
                    // [self insertNewsItem:itemData.gridData news:tmpItem];
                    //添加数据
                }
            }
            //[itemData resetTopPhotoIndex];
            break;
        }
    }
}

-(int) getCategoryListActiveCount{
    int count = 0;
    if (self.categoryList != nil){
        for (NewsCategory* item in self.categoryList) {
            if (item != nil){
                if (item.hidden == NO)
                    count++;
            }
        }
    }
    return count;
}

-(int) getCategoryNewsCount: (NSString*) cid{
    int count = 0;
    //BOOL AdIsOpen = self.minikitCh.nativeAd.enabled;
        if (self.poponewsList != nil && cid != nil){
            for (PopoNewsData* item in self.poponewsList) {
                if (item != nil){
                    if ([item.category.cId compare:cid] == NSOrderedSame){
                        if (item.data.count != 0)
//                            if (item.newsList == nil) {
//                                item.newsList = item.data;
//                            }
//                        if (AdIsOpen == YES) {
//                            count = (int)[item.newsList count];
//                        }else{
//                            count = (int)[item.data count];
//                        }
                        count = (int)[item.data count];
                    }
                }
            }
        }
        return count;
}
-(int )getGridCategoryNewsCount:(NSString *) cid{

    int count = 0;
    return count;
   
}
-(NewsCategory*) getCategoryByIndex: (int) index{
    NewsCategory* category = nil;
    
    if (self.categoryList != nil && index < [self.categoryList count])
        category = [self.categoryList objectAtIndex:index];
    
    return category;
}

-(NewsCategory*) getCategoryByID: (NSString*) cid{
    NewsCategory* category = nil;
    
    if (self.categoryList != nil && cid != nil){
        for (NewsCategory* item in self.categoryList) {
            if (item != nil){
                if ([item.cId compare:cid] == NSOrderedSame){
                    category = item;
                    break;
                }
            }
        }
    }

    return category;
}

-(NSMutableArray*) getCategoryDataByID: (NSString*) cid {
    NSMutableArray* data = nil;
    
    if (self.poponewsList != nil && cid != nil){
        for (PopoNewsData* item in self.poponewsList) {
            if (item != nil){
                if ([item.category.cId compare:cid] == NSOrderedSame){
                    data = item.data;
                    break;
                }
            }
        }
    }
    
    return data;
}

-(PoPoNewsItem*) getNewsItemByNid: (NSString*) cid
                           newsId: (NSString*) nid {
    PoPoNewsItem* news = nil;
    if (self.categoryList != nil && cid != nil){
        for (PopoNewsData* item in self.poponewsList) {
            if (item != nil){
                if ([item.category.cId compare:cid] == NSOrderedSame){
                    NSMutableArray* newsList = item.data;
                    for (id item in newsList) {
                        if ([item isKindOfClass:[PoPoNewsItem class]]) {
                            PoPoNewsItem *newsItem = item;
                            if ([newsItem.nId compare:nid] == NSOrderedSame){
                                news = newsItem;
                                break;
                            }
                        }
                    }
                    break;
                }
            }
        }
    }
    return news;
}

-(id) getNewsItemAtIndex: (PopoNewsData*) item
                       index: (int) idx{
    id news = nil;
    [item resetTopPhotoIndex];
    if (item != nil && item.data != nil && [item.data count] > idx){
        if (idx == 0 && item.topPhotoIndex != -1){
            news = [item.data objectAtIndex:item.topPhotoIndex ];
        } else {
            if (item.topPhotoIndex != -1){
                int dataIndex = idx;
                if (item.topPhotoIndex >= idx){
                    dataIndex -= 1;
                }
                news = [item.data objectAtIndex:dataIndex];
            } else {
                news = [item.data objectAtIndex:idx];
            }
        }
    }
    return news;
}
-(GRInterstitialAd*) getInterstitialAd: (NSString*)publisher {
    GRAdService* adService = [GRServices get:GR_SERVICE_TYPE_AD];
//    ConfigService *cf = [ConfigService get];
//    NSString *ch = [cf getChannel];
//    NSString *dch = @"";
//    NSString *str = INTERSTITIAL_AD_PLACEMENT_FORMAT;
//    NSString *placement1 = [str stringByReplacingOccurrencesOfString:@"{ch}" withString:ch];
//    NSString *placement2 = [placement1 stringByReplacingOccurrencesOfString:@"{dch}" withString:dch];
//    NSString *placement = [placement2 stringByReplacingOccurrencesOfString:@"{publisher}" withString:publisher];
    GRInterstitialAd *nAd = [adService getInterstitialAd:publisher];
    return nAd;
}
-(GRBannerAd*) getBannerAd :(NSString*)publisher{
    GRAdService* adService = [GRServices get:GR_SERVICE_TYPE_AD];
//    ConfigService *cf = [ConfigService get];
//    NSString *ch = [cf getChannel];
//    NSString *dch = @"";
//    NSString *str = BANNER_AD_PLACEMENT_FORMAT;
//    NSString *placement1 = [str stringByReplacingOccurrencesOfString:@"{ch}" withString:ch];
//    NSString *placement2 = [placement1 stringByReplacingOccurrencesOfString:@"{dch}" withString:dch];
//    NSString *placement = [placement2 stringByReplacingOccurrencesOfString:@"{publisher}" withString:publisher];
    GRBannerAd* nAd = [adService getBannerAd:FACEBOOK_ARTICLE_BANNER_PLACEMENT_ID imageWidth:[UIScreen mainScreen].bounds.size.width-20 imageHeight:60 requiredFields:nil];
    
    return nAd;
}
-(NSString*) getNativedAdPlacement: (NSString*) cid{
    
    ConfigService *cf = [ConfigService get];
    NSString *ch = [cf getChannel];
    NSString *dch = @"";
    NSString *str = NATIVE_AD_PLACEMENT_FORMAT;
    NSString *placement1 = [str stringByReplacingOccurrencesOfString:@"{ch}" withString:ch];
    NSString *placement2 = [placement1 stringByReplacingOccurrencesOfString:@"{dch}" withString:dch];
    NSString *placement = [placement2 stringByReplacingOccurrencesOfString:@"{cid}" withString:cid];
    
    return placement;
}
-(id) getCategoryShowItem: (NSString*) layout
                  cid: (NSString*) cid
                index: (int) idx {
    
    int trueIndex = idx;
//    if ([layout compare:NEWS_LAYOUT_TYPE_GRID] == NSOrderedSame) {
//        return [self getGridNewsItem:cid index:trueIndex];
//    }else{
//        return [self getNewsItem:cid index:trueIndex];
//    }
    return [self getNewsItem:cid index:trueIndex];

}
-(id) getNewsItem: (NSString*) cid
                   index: (int) idx{
    id news = nil;
    
   // BOOL isOpen = self.minikitCh.nativeAd.enabled;
  
        if (self.poponewsList != nil && cid != nil){
            for (PopoNewsData* item in self.poponewsList) {
                if (item != nil){
                    if (item.category.cId == cid) {
                        news = [self getNewsItemAtIndex:item index:idx];
                        break;
                    } else if ([item.category.cId compare:cid] == NSOrderedSame){
                        news = [self getNewsItemAtIndex:item index:idx];
                        break;
                    }
                }
            }
        }
    return news;
}
-(void) removeNewsItem: (NSString *)nid{
    
    if (self.poponewsList != nil && nid != nil) {
        for (PopoNewsData *item in self.poponewsList) {
            if (item != nil) {
                for (NSInteger i = 0; i < item.data.count; i++) {
                    id news = [item.data objectAtIndex:i];
                    if ([news isKindOfClass:[PoPoNewsItem class]]) {
                        PoPoNewsItem *newsItem = news;
                        if ([newsItem.nId compare:nid] == NSOrderedSame) {
                            [item.data removeObjectAtIndex:i];
                            return;
                        }
                    }
                }
            }
        }
    }
}


// parser remote service response data
-(void) parserNewsItemData: (PoPoNewsItem*) item
                      data: (NSDictionary*) dic{
    if (dic == nil || item == nil)
        return;
    
    NSString* tmpData = [dic objectForKey:NEWS_ITEM_ID];
    if (tmpData != nil)
        item.nId = tmpData;
    
    tmpData = [dic objectForKey:NEWS_ITEM_CATEGORY_ID];
    if (tmpData != nil)
        item.cId = tmpData;
    
    NSNumber* numData = [dic objectForKey:NEWS_ITEM_RELEASE_TIME];
    if (numData != nil)
        item.releaseTime = numData.intValue;
    
    tmpData = [dic objectForKey:NEWS_ITEM_TITLE];
    if (tmpData != nil)
        item.title = tmpData;
    
    NSArray* mmData = [dic objectForKey:NEWS_ITEM_MM];
    if (mmData != nil){
        NSMutableArray* tmpArray = [NSMutableArray arrayWithCapacity:2];
        for(NSDictionary* item in mmData){
            NewsImage* image = [[NewsImage alloc] initWithDictionary:item];
            //[self parserNewsImage:image data:item];
            [tmpArray addObject:image];
        }
        item.images = tmpArray;
    }
    
    numData = [dic objectForKey:NEWS_ITEM_FAV];
    if (numData != nil)
        item.fav = numData.intValue;
    
    NSDictionary* moodData = [dic objectForKey:NEWS_ITEM_MOOD];
    if (moodData != nil){
        NewsMood* mood = [[NewsMood alloc] initWithDictionary:moodData];
        //[self parserNewsMood:mood data:moodData];
        item.mood = mood;
    }
    
    tmpData = [dic objectForKey:NEWS_ITEM_PREVIEW];
    if (tmpData != nil)
        item.preview = tmpData;
    
    
    tmpData = [dic objectForKey:NEWS_ITEM_PDOMAIN];
    if (tmpData != nil)
        item.pDomain = tmpData;
    
    tmpData = [dic objectForKey:NEWS_ITEM_SOURCE];
    if (tmpData != nil)
        item.source = tmpData;
    
    tmpData = [dic objectForKey:NEWS_ITEM_BODY];
    if (tmpData != nil)
        item.body = tmpData;
    
    tmpData = [dic objectForKey:NEWS_ITEM_TYPE];
    if (tmpData != nil)
        item.type = tmpData;
    
    tmpData = [dic objectForKey:NEWS_ITEM_PNAME];
    if (tmpData != nil)
        item.pName = tmpData;
    
    tmpData = [dic objectForKey:NEWS_ITEM_PICON];
    if (tmpData != nil)
        item.pIcon = tmpData;
}


-(id) getCurrentDetailNewsItem{
    return self.currentDetailNews;
}

-(void) setCurrentDetailNewsItem: (id) item{
    self.currentDetailNews = item;
}

-(NSMutableArray*) getPoNewsChannelList {
    if (self.popoNewChannelList == nil) {
        SettingService* ss = [SettingService get];
        NSArray* array = [ss getArrayValue:CONFIG_CHANNELS_DATA defValue:nil];
        [self setPoNewsChannelList:array];
    }
    return self.popoNewChannelList;
}

-(void) setPoNewsChannelList: (NSArray*) array{
    if (array == nil)
        return;
    
    if (self.popoNewChannelList == nil){
        self.popoNewChannelList = [NSMutableArray arrayWithCapacity:1];
    } else
        [self.popoNewChannelList removeAllObjects];
    
    SettingService* ss = [SettingService get];
    [ss setArrayValue:CONFIG_CHANNELS_DATA data:array];
    
    ConfigService* cs = [ConfigService get];
    int chCount = 0;
    NSString* currentCH = [cs getChannel];
    for(NSDictionary* item in array){
        if (item != nil){
            NSString* tmpId = [item objectForKey:@"id"];
            NSString* tmpName = [item objectForKey:@"name"];
            NSString* tmpCountry = [item objectForKey:@"country"];
            NSString* tmpIcon = [item objectForKey:@"icon"];
            NSString* tmpLang = [item objectForKey:@"lang"];
            BOOL isChecked = NO;
            
            if (currentCH == nil){
                if (chCount == 0){
                    [cs setChannel:tmpId];
                    isChecked = YES;
                }
            } else {
                if ([currentCH compare:tmpId] == NSOrderedSame){
                    isChecked = YES;
                }
            }
            
            if (tmpId != nil && tmpName != nil && tmpCountry != nil && tmpIcon != nil && tmpLang != nil){
                PopoNewsChannel* poCh = [PopoNewsChannel alloc];
                poCh.chId = tmpId;
                poCh.name = tmpName;
                poCh.icon = tmpIcon;
                poCh.lang = tmpLang;
                poCh.country = tmpCountry;
                poCh.isChecked = isChecked;
                [self.popoNewChannelList addObject:poCh];
            }
            chCount++;
        }
    }
}

-(void) clearCategoryData{
    // categoryList
    // showCategoryList
    // popoNewChannelList
    // poponewsList
    // downloadList
    // gpChannels
    
    if (self.popoNewChannelList != nil){
        [self.popoNewChannelList removeAllObjects];
        self.popoNewChannelList = nil;
    }
    
    if (self.showCategoryList != nil){
        [self.showCategoryList removeAllObjects];
        self.showCategoryList = nil;
    }
    
    if (self.categoryList != nil){
        [self.categoryList removeAllObjects];
        self.categoryList = nil;
    }
    
    if (self.poponewsList != nil){
        for (PopoNewsData* data in self.poponewsList){
            if (data != nil){
                data.category = nil;
                [data.data removeAllObjects];
                data.data = nil;
            }
        }
        [self.poponewsList removeAllObjects];
        self.poponewsList = nil;
    }
    
    if (self.downLoadList != nil){
        ITSApplication* app = [ITSApplication get];
        //[app.offlineSvr stopDwonload];
        for (int i = 0; i < [self.downLoadList count]; i++) {
            OfflineCategoryItem* item = [self.downLoadList objectAtIndex:i];
            if (item.downloadList != nil)
                [item.downloadList removeAllObjects];
            if (item.newsList != nil)
                [item.newsList removeAllObjects];
        }
        [self.downLoadList removeAllObjects];
        self.downLoadList = nil;
    }
    
    if (self.popoGPData != nil){
        PopoGPUser* gpUsers = self.popoGPData.socialData;
        if (gpUsers != nil && gpUsers.users != nil){
            for (int i = 0; i < [gpUsers.users count]; i++) {
                GoolgePlusUser* tmpGPUser = [gpUsers.users objectAtIndex:i];
                if (tmpGPUser.data != nil)
                    [tmpGPUser.data removeAllObjects];
            }
            [gpUsers.users removeAllObjects];
        }
        self.socialCategory = nil;
        self.popoGPData = nil;
    }
    if (self.popoBDData != nil){
        PoPoBDuser* gpUsers = self.popoBDData.socialData;
        if (gpUsers != nil && gpUsers.users != nil){
            for (int i = 0; i < [gpUsers.users count]; i++) {
                BaiduPlusUser* tmpGPUser = [gpUsers.users objectAtIndex:i];
                if (tmpGPUser.data != nil)
                    [tmpGPUser.data removeAllObjects];
            }
            [gpUsers.users removeAllObjects];
        }
        self.socialCategory = nil;
        self.popoBDData = nil;
    }
}

-(void) calculateCacheSize{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    // create MMlogs folder
    NSString* detailPageFolder = [NSString stringWithFormat:@"%@/cache/articles", documentPath];
    NSString* imageCacheFolder = [NSString stringWithFormat:@"%@/MMImageCache", documentPath];
    
    long detailSize = [MMSystemHelper fileSizeForDir:detailPageFolder];
    long imageSize = [MMSystemHelper fileSizeForDir:imageCacheFolder];
    
    self.cacheDataSize = detailSize+imageSize;
    
    MMEventService *es = [MMEventService getInstance];
    [es send:EVENT_CACHE_SIZE_REFRESHED eventData:nil];
}

-(void) refreshCacheDataSize {
    NSThread* cacheThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(calculateCacheSize)
                                                    object:nil];
    [cacheThread start];
}

-(void) setCacheFolderSize: (long) size{
    self.cacheDataSize = size;
}

-(long) getCacheFolderSize{
    return self.cacheDataSize;
}

-(void) doClearCacheInThread{

    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    
    NSString* detailPageFolder = [NSString stringWithFormat:@"%@/cache/articles", documentPath];
    NSString* imageCacheFolder = [NSString stringWithFormat:@"%@/MMImageCache", documentPath];
    [MMSystemHelper removeFileForDir:detailPageFolder];
    [MMSystemHelper removeFileForDir:imageCacheFolder];
    
    MMEventService *es = [MMEventService getInstance];
    [es send:EVENT_CACHE_CLEARED eventData:nil];
}

-(void) clearCacheFolder {
    NSThread* clearCacheThread = [[NSThread alloc] initWithTarget:self
                                                    selector:@selector(doClearCacheInThread)
                                                      object:nil];
    [clearCacheThread start];
}


// read news
-(void) insert2ReadNewsList: (NSString*) nId
                 categoryId: (NSString*) cId {
    if (nId == nil || cId == nil)
        return;
    
    BOOL isFind = NO;
    
    if (self.readNewsList == nil){
        self.readNewsList = [NSMutableArray arrayWithCapacity:1];
    }
    
    for (ReadedNewsItem* item in self.readNewsList) {
        if (item != nil){
            if ([item.nId compare:nId] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    if (isFind == NO){
        ReadedNewsItem* readItem = [ReadedNewsItem alloc];
        readItem.cId = cId;
        readItem.nId = nId;
        [self.readNewsList insertObject:readItem atIndex:0];
        
        long listCount = [self.readNewsList count];
        if (listCount > MAX_READED_NEWS_COUNT){
            [self.readNewsList removeObjectAtIndex:listCount-1];
        }
        
        // save to db
        NewsService* ns = [NewsService get];
        [ns saveReadNewsList:self.readNewsList];
    }
}

-(BOOL) isInReadList: (PoPoNewsItem*) item{
    BOOL isFind = NO;
    if (item == nil || self.readNewsList == nil)
        return isFind;
    
    for (ReadedNewsItem* readItem in self.readNewsList) {
        if (readItem != nil){
            if ([readItem.nId compare:item.nId] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    return isFind;
}

-(NSMutableArray*) getReadNewsList{
    return self.readNewsList;
}
//myCommentNews list
-(NSMutableArray*) getMyCommentNewsList{
    return self.myCommentNewsList;
}
-(PoPoNewsItem*) getTapMyCommentNews:(NSString *)nid{
    id item = nil;
    if (self.myCommentNewsList != nil && nid != nil){
        for (PoPoNewsItem* newsItem in self.myCommentNewsList) {
            if (newsItem != nil){
                if ([newsItem.nId compare:nid] == NSOrderedSame) {
                    item = newsItem;
                }
            }
        }
    }
    return item;
}
-(void) insert2MyCommentNewsList:(PoPoNewsItem*) item{
    if (item == nil)
        return;
    
    BOOL isFind = NO;
    
    if (self.myCommentNewsList == nil){
        self.myCommentNewsList = [NSMutableArray arrayWithCapacity:1];
    }
    for (PoPoNewsItem *newsItem in self.myCommentNewsList) {
        if (newsItem != nil) {
            if ([item.nId compare:newsItem.nId] == NSOrderedSame) {
                isFind = YES;
                break;
            }
        }
    }
    if (isFind == NO){
        [self.myCommentNewsList insertObject:item atIndex:0];
    }
    long listCount = [self.myCommentNewsList count];
    if (listCount > MAX_READED_NEWS_COUNT){
        [self.myCommentNewsList removeObjectAtIndex:listCount-1];
    }
}
// favour list
-(void) insert2FavourList: (PoPoNewsItem*) item
                 saveFlag: (BOOL) saved
               isPushNews: (BOOL) isPushNews {
    if (item == nil)
        return;
    
    BOOL isFind = NO;
    
    if (self.favourNewsList == nil){
        self.favourNewsList = [NSMutableArray arrayWithCapacity:1];
    }
    
    for (FavourNewsItem* tmpItem in self.favourNewsList) {
        if (tmpItem != nil){
            PoPoNewsItem* newsItem = tmpItem.data;
            if (newsItem == item || [newsItem.nId compare:item.nId] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    if (isFind == NO ){
        FavourNewsItem* favourItem = [FavourNewsItem alloc];
        favourItem.checked = NO;
        favourItem.data = item;
        
        [self.favourNewsList insertObject:favourItem atIndex:0];
        
        item.isMyFav = YES;
        item.didFav = YES;
        item.fav++;
        
        long listCount = [self.favourNewsList count];
        if (listCount > MAX_FAVOUR_NEWS_COUNT){
            [self.favourNewsList removeObjectAtIndex:listCount-1];
        }
        
        if (saved == YES){
           
            // save to db
            NewsService* ns = [NewsService get];
            [ns saveFavourNews:item.nId data:[item toDictionaryData]];
            
            if (isPushNews == YES){
                [ns saveFeedNewsItem:item.nId data:[item toDictionaryDataHasReadStatus]];
            } else {
                // update news
                [ns savePopoNewsItem:item.nId data:[item toDictionaryData]];
            }
        }
    }
}

-(void) removeFavourById: (PoPoNewsItem*) item{
    if (item == nil)
        return;
    
    BOOL isFind = NO;
    
    if (self.favourNewsList == nil)
        return;
    
    int index = 0;
    for (FavourNewsItem* tmpItem in self.favourNewsList) {
        if (tmpItem != nil){
            PoPoNewsItem* newsItem = tmpItem.data;
            if (newsItem == item || [newsItem.nId compare:item.nId] == NSOrderedSame){
                isFind = YES;
                [self.favourNewsList removeObjectAtIndex:index];
                break;
            }
        }
        index++;
    }
    
    if (isFind == YES){
        item.isMyFav = NO;
        item.fav--;
        if (item.fav < 0)
            item.fav = 0;
        
        // save to db
        NewsService* ns = [NewsService get];
        [ns saveFavourNews:item.nId data:nil];
        // update news
        [ns savePopoNewsItem:item.nId data:[item toDictionaryData]];
    }
}

-(BOOL) isInFavourList:(PoPoNewsItem*) item{
    BOOL isFind = NO;
    if (item == nil || self.favourNewsList == nil)
        return isFind;
    
    for (FavourNewsItem* tmpItem in self.favourNewsList) {
        if (tmpItem != nil){
            PoPoNewsItem* newsItem = tmpItem.data;
            if (newsItem == item || [newsItem.nId compare:item.nId] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    return isFind;
}

-(NSMutableArray*) getFavourList{
    return self.favourNewsList;
}

-(void) removeAllSelFavour{
    if (self.favourNewsList == nil)
        return;
    
    long count = [self.favourNewsList count];
    
    for (int i = 0; i < count; i++) {
        FavourNewsItem* tmpItem = [self.favourNewsList objectAtIndex:i];
        if (tmpItem != nil){
            if (tmpItem.checked == YES) {
                PoPoNewsItem* item = tmpItem.data;
                
                item.isMyFav = NO;
                item.fav--;
                if (item.fav < 0)
                    item.fav = 0;
                
                // save to db
                NewsService* ns = [NewsService get];
                [ns saveFavourNews:item.nId data:nil];
                // update news
                [ns savePopoNewsItem:item.nId data:[item toDictionaryData]];
                
                [self.favourNewsList removeObjectAtIndex:i];
                i--;
                count--;
            }
        }
    }
}

-(void) clearFavourAllSel{
    for (FavourNewsItem* tmpItem in self.favourNewsList) {
        if (tmpItem != nil){
            tmpItem.checked = NO;
        }
    }
}
//回复的回复
/*
-(NSString *)getCommentRpath:(NSInteger *)index :(NSInteger)section :(NSInteger)row{
    
    NSString *path = @"";
    if (section == 0) {
        if (self.hotCommentList != nil) {
            CommentCellFrame *commentFreaem = [self.hotCommentList objectAtIndex:row];
            if (index >= commentFreaem.commentItem.replyPath.count) {
                if (commentFreaem.commentItem.replyPath.count > 0) {
                    NSInteger count = commentFreaem.commentItem.replyPath.count - 1;
                    path = [commentFreaem.commentItem.replyPath objectAtIndex:count];
                }else{
                    path = commentFreaem.commentItem.path;
                }
            }else{
                path = [commentFreaem.commentItem.replyPath objectAtIndex:index];
            }
        }
    }else{
        if(self.commentList != nil){
            CommentCellFrame *commentFreaem = [self.commentList objectAtIndex:row];
            if (index >= commentFreaem.commentItem.replyPath.count) {
                if (commentFreaem.commentItem.replyPath.count > 0) {
                    NSInteger count = commentFreaem.commentItem.replyPath.count - 1;
                    path = [commentFreaem.commentItem.replyPath objectAtIndex:count];
                }else{
                    path = commentFreaem.commentItem.path;
                }
                
            }else{
                path =  [commentFreaem.commentItem.replyPath objectAtIndex:index];
            }
        }//1*1465805781759/2*1466059551646/3*1466059678654
    }
    return path;
}

// comment
-(NSString *)getCommentPath:(int *)index :(NSInteger)section {
    
    NSString *path = @"";
  
    if (section == 0) {
        if (index >= 0) {
            if (self.hotCommentList != nil) {
                CommentCellFrame *commentFreaem = [self.hotCommentList objectAtIndex:index];
                path =  commentFreaem.commentItem.path;
            }
        }else{
            CommentCellFrame *commentFream = [self.hotCommentList objectAtIndex:0];
            path = commentFream.commentItem.path;
        }
    }else{
        if (index >= 0) {
            if(self.commentList != nil){
                CommentCellFrame *commentFreaem = [self.commentList objectAtIndex:index];
                path =  commentFreaem.commentItem.path;
            }
        }else{
            CommentCellFrame *commentFreaem = [self.commentList objectAtIndex:0];
            path =  commentFreaem.commentItem.path;
        }
    }
    return path;
}
- (NSMutableArray *) getMyCommentList{
    return self.myCommentList;
}
-(void) getMyCommentList:(NSDictionary *)dic{
    if (self.myCommentList == nil) {
        self.myCommentList = [NSMutableArray arrayWithCapacity:3];
    }else{
        [self.myCommentList removeAllObjects];
    }
    [[PopoApplication get].remoteSvr getMyComment:dic];
}
- (void)setPoMyCommentList:(NSMutableArray*)data{
    
    if (data != nil) {
        for (NSDictionary* dic in data) {
            
            MyCommentItem *item = [[MyCommentItem alloc] init];
            item.u_name = [dic objectForKey:@"u_name"];
            item.u_avatar = [dic objectForKey:@"u_avatar"];
            item._at = [dic objectForKey:@"_at"];
            item.content = [dic objectForKey:@"content"];
            item.t_id = [dic objectForKey:@"t_id"];
            item.u_id = [dic objectForKey:@"u_id"];
            item.path = [dic objectForKey:@"path"];
            item.forereply_at = [[dic objectForKey:@"fore_reply"] objectForKey:@"_at"];
            item.forereply_content = [[dic objectForKey:@"fore_reply"] objectForKey:@"content"];
            item.forereply_id = [[dic objectForKey:@"fore_reply"] objectForKey:@"_id"];
            item.forereply_nid = [[dic objectForKey:@"fore_reply"] objectForKey:@"i_id"];
            item.forereply_path = [[dic objectForKey:@"fore_reply"] objectForKey:@"path"];
            item.forereply_uAvatar = [[dic objectForKey:@"fore_reply"] objectForKey:@"u_avatar"];
            item.forereply_uid = [[dic objectForKey:@"fore_reply"] objectForKey:@"u_id"];
            item.forereply_uName = [[dic objectForKey:@"fore_reply"] objectForKey:@"u_name"];

            PoPoNewsItem *data = [[PoPoNewsItem alloc] init];
            data.title = [[dic objectForKey:@"items"] objectForKey:@"title"];
            data.source = [[dic objectForKey:@"items"] objectForKey:@"source"];
            data.pDomain = [[dic objectForKey:@"items"] objectForKey:@"p_domain"];
            data.go2source = [[[dic objectForKey:@"items"] objectForKey:@"go2source"] intValue];
            data.nId = [[dic objectForKey:@"items"] objectForKey:@"_id"];
            data.preview = [[dic objectForKey:@"items"] objectForKey:@"preview"];
            item.data = data;
            MyCommentCellFrame* commentFrame = [[MyCommentCellFrame alloc] init];
            commentFrame.myCommentItem = item;
            [self.myCommentList addObject:commentFrame];
            
            [[PopoApplication get].remoteSvr getDetailNewsById:data.nId isShowDetailPage:YES];
        }
    }
    
    MMEventService *es = [MMEventService getInstance];
    [es send:[[NSString alloc] initWithFormat:@"%@_%@", EVENT_NEWS_DATA_REFRESH_PREFIX, self.user.uId]  eventData:NEWS_REFRESH_SUCCESS];
    
}
- (NSMutableArray *) getCommentList{
    
    return self.commentList;
}

- (void)setPoCommentList:(NSDictionary*)data{
    
    PoPoNewsItem* item = [self getCurrentDetailNewsItem];
    SettingService* ss = [SettingService get];
    self.comment_count = [[data objectForKey:@"count"] intValue];
    [ss setIntValue:item.nId data:self.comment_count];
    if ([data objectForKey:@"data"] != nil) {
        for (NSDictionary *dic in [data objectForKey:@"data"]) {
            CommentItem *commentItem = [[CommentItem alloc] init];
            commentItem.replys = [[NSMutableArray alloc] init];
            commentItem.replyPath = [[NSMutableArray alloc] init];
            commentItem.u_id = [dic objectForKey:@"u_id"];
            commentItem._at = [dic objectForKey:@"_at"];
            commentItem.content = [dic objectForKey:@"content"];
            commentItem.i_id = [dic objectForKey:@"i_id"];
            commentItem.avatar = [dic objectForKey:@"u_avatar"];
            commentItem.approval = [dic objectForKey:@"approval"];
            commentItem.name = [dic objectForKey:@"u_name"];
            commentItem._id = [dic objectForKey:@"_id"];
            NSMutableArray *reply = [dic objectForKey:@"reply"];
            commentItem.replyCount = 0;
            for (NSDictionary *rDic in reply) {
                ReplyItem *item = [[ReplyItem alloc] init];
                item.u_name = [rDic objectForKey:@"u_name"];
                item.t_name = [rDic objectForKey:@"t_name"];
                item.content = [rDic objectForKey:@"content"];
                item.tId = [rDic objectForKey:@"t_id"];
                item.uId = [rDic objectForKey:@"u_id"];
                
                [item setValuesForKeysWithDictionary:rDic];
                commentItem.replyItem = item;
                commentItem.replyCount += 1;
                commentItem.r_path = [rDic objectForKey:@"path"];
//                commentItem.repil_content = [rDic objectForKey:@"content"];
                [commentItem.replys addObject:commentItem.replyItem];
                [commentItem.replyPath addObject:commentItem.r_path];
            }
            if(commentItem.replys.count > 0){
                commentItem.replyCount = commentItem.replys.count;
            }
            CommentCellFrame *commentFreaem = [[CommentCellFrame alloc] init];
            commentFreaem.commentItem = commentItem;
            commentItem.isFavour = [ss getBooleanValue:commentItem._id defValue:NO];
            [commentItem  setValuesForKeysWithDictionary:dic];
            commentItem.isShow = NO;
            [self.commentList addObject:commentFreaem];
        }
    }
//    PoPoNewsItem *item = [self getCurrentDetailNewsItem];

    MMEventService *es = [MMEventService getInstance];
    [es send:[[NSString alloc] initWithFormat:@"%@_%@", EVENT_NEWS_DATA_REFRESH_PREFIX,item.nId ]  eventData:NEWS_REFRESH_SUCCESS];
}
-(void) getCommentList:(NSDictionary *)dic{
    if (self.commentList == nil) {
        self.commentList = [NSMutableArray arrayWithCapacity:3];
    }else{
        [self.commentList removeAllObjects];
    }
    [[PopoApplication get].remoteSvr getComment:dic];
}
-(void) refreshCommentList: (NSDictionary*) dic{

    [[PopoApplication get].remoteSvr getComment:dic];
    
}
- (NSMutableArray *) getDetailHotCommentList{

    return self.detailHotCommentList;
}
- (void)setPoDetailHotCommentList:(NSMutableArray*)data{
    SettingService* ss = [SettingService get];
    
    if (data != nil) {
        for (NSDictionary *dic in data) {
            CommentItem *commentItem = [[CommentItem alloc] init];
            commentItem.replys = [[NSMutableArray alloc] init];
            commentItem.u_id = [dic objectForKey:@"u_id"];
            commentItem._at = [dic objectForKey:@"_at"];
            commentItem.content = [dic objectForKey:@"content"];
            commentItem.i_id = [dic objectForKey:@"i_id"];
            commentItem.avatar = [dic objectForKey:@"u_avatar"];
            commentItem.approval = [dic objectForKey:@"approval"];
            commentItem.name = [dic objectForKey:@"u_name"];
            commentItem._id = [dic objectForKey:@"_id"];
//            NSMutableArray *reply = [dic objectForKey:@"reply"];
            commentItem.replyCount = 0;
//            for (NSDictionary *rDic in reply) {
//                commentItem.r_path = [rDic objectForKey:@"path"];
//                commentItem.repil_content = [rDic objectForKey:@"content"];
//            }
            commentItem.replys = nil;
            CommentCellFrame *commentFream = [[CommentCellFrame alloc] init];
            commentFream.commentItem = commentItem;
            commentItem.isFavour = [ss getBooleanValue:commentItem._id defValue:NO];
//            [commentItem  setValuesForKeysWithDictionary:dic];
            commentItem.isShow = NO;
            [self.detailHotCommentList addObject:commentFream];
        }
    }
}
-(void) refreshDetailHotCommentList:(NSDictionary *)dic{
    if (self.detailHotCommentList == nil) {
        self.detailHotCommentList = [NSMutableArray arrayWithCapacity:3];
    }else{
        [self.detailHotCommentList removeAllObjects];
    }
    [[PopoApplication get].remoteSvr getHotCommnet:dic];

}
- (NSMutableArray *) getHotCommentList{

    return self.hotCommentList;
}
-(void)setPoHotComentList:(NSMutableArray*)data{

    SettingService* ss = [SettingService get];

    if (data != nil) {
        for (NSDictionary *dic in data) {
            CommentItem *commentItem = [[CommentItem alloc] init];
            commentItem.replyPath = [[NSMutableArray alloc] init];
            commentItem.replys = [[NSMutableArray alloc] init];
            commentItem.u_id = [dic objectForKey:@"u_id"];
            commentItem._at = [dic objectForKey:@"_at"];
            commentItem.content = [dic objectForKey:@"content"];
            commentItem.i_id = [dic objectForKey:@"i_id"];
            commentItem.avatar = [dic objectForKey:@"u_avatar"];
            commentItem.approval = [dic objectForKey:@"approval"];
            commentItem.name = [dic objectForKey:@"u_name"];
            commentItem._id = [dic objectForKey:@"_id"];
            NSMutableArray *reply = [dic objectForKey:@"reply"];
            commentItem.replyCount = 0;
            for (NSDictionary *rDic in reply) {
                ReplyItem *item = [[ReplyItem alloc] init];
                item.u_name = [rDic objectForKey:@"u_name"];
                item.t_name = [rDic objectForKey:@"t_name"];
                item.content = [rDic objectForKey:@"content"];
                item.tId = [rDic objectForKey:@"u_id"];
                [item setValuesForKeysWithDictionary:rDic];
                commentItem.replyItem = item;
                commentItem.r_path = [rDic objectForKey:@"path"];
//                commentItem.repil_content = [rDic objectForKey:@"content"];
                [commentItem.replys addObject:commentItem.replyItem];
                [commentItem.replyPath addObject:commentItem.r_path];
            }
            if(commentItem.replys.count > 0){
                commentItem.replyCount = commentItem.replys.count;
            }
            CommentCellFrame *commentFream = [[CommentCellFrame alloc] init];
            commentFream.commentItem = commentItem;
            commentItem.isFavour = [ss getBooleanValue:commentItem._id defValue:NO];
            [commentItem  setValuesForKeysWithDictionary:dic];
            commentItem.isShow = NO;
            [self.hotCommentList addObject:commentFream];
        }
    }
}
-(void) refreshHotCommentList:(NSDictionary *)dic{
    if (self.hotCommentList == nil) {
        self.hotCommentList = [NSMutableArray arrayWithCapacity:3];
    }else{
        [self.hotCommentList removeAllObjects];
    }
    [[PopoApplication get].remoteSvr getHotCommnet:dic];
}
 
 */
// download
-(void) refreshOfflineDownloadCategoryList{
    if (self.downLoadList == nil)
        self.downLoadList = [NSMutableArray arrayWithCapacity:3];
    else
        [self.downLoadList removeAllObjects];
    
    for (NewsCategory* item in self.categoryList) {
        if (item != nil){
            OfflineCategoryItem* offlineItem = [OfflineCategoryItem alloc];
            offlineItem.category = item;
            offlineItem.progress = 0;
            offlineItem.checked = NO;
            offlineItem.isHideen = YES;
            offlineItem.downloadList = nil;
            offlineItem.downloadStatus = DOWNLOAD_STATUS_INIT;
            offlineItem.newsList = nil;
            offlineItem.isNewsSync = NO;
            
            [self.downLoadList addObject:offlineItem];
        }
    }
}

- (NSMutableArray*) getDownLoadList {
    if (self.downLoadList == nil)
        [self refreshOfflineDownloadCategoryList];
    return self.downLoadList;
}

-(void) clearDownloadChecked{
    if (self.downLoadList == nil)
        return;
    
    for (int i =0; i < [self.downLoadList count]; i++) {
        OfflineCategoryItem* offlineItem = [self.downLoadList objectAtIndex:i];
        offlineItem.checked = NO;
        offlineItem.downloadStatus = DOWNLOAD_STATUS_INIT;
        offlineItem.progress = 0;
    }
}

-(void) setOfflineNews: (NSString*) cid
              newsList: (NSArray*) dicData {
    if (self.downLoadList == nil || cid == nil || dicData == nil)
        return;
    NewsService* ns = [NewsService get];
    for (OfflineCategoryItem* item in self.downLoadList) {
        if (item != nil) {
            if ([item.category.cId compare:cid] == NSOrderedSame){
                item.downloadStatus = DOWNLOAD_STATUS_GET_NEWS;
                for (NSDictionary* newsDataItem in dicData) {
                    PoPoNewsItem* tmpItem = [[PoPoNewsItem alloc] initWithDictionary:newsDataItem];
                    tmpItem.isOfflineDL = YES;
                    if (tmpItem != nil){
                        if (item.newsList == nil)
                            item.newsList = [NSMutableArray arrayWithCapacity:1];
                        [item.newsList addObject:tmpItem];
                        if (ns != nil)
                            [ns savePopoNewsItem:tmpItem.nId data:[tmpItem toDictionaryData]];
                    }
                }
            }
        }
    }
}

-(NSInteger) getSocialUserCount: (int) type{
    NSInteger userCount = 0;
    if (type == SOCIAL_TYPE_FACEBOOK){
        if (self.popoFBData != nil){
            PopoFBUser* fbUsers = self.popoFBData.socialData;
            if (fbUsers != nil && fbUsers.users != nil){
                userCount = [fbUsers.users count];
            }
        }
    } else if (type == SOCIAL_TYPE_GOOGLE){
        if (self.popoGPData != nil){
            PopoGPUser* gpUsers = self.popoGPData.socialData;
            if (gpUsers != nil && gpUsers.users != nil){
                userCount = [gpUsers.users count];
            }
        }
    }else if (type == SOCIAL_TYPE_TWITTER){
        if (self.popoTWData != nil) {
            PopoTWuser *twUsers = self.popoTWData.socialData;
            if (twUsers != nil && twUsers.friends != nil) {
                 userCount = [twUsers.friends count];
            }
        }
    }else if (type == SOCIAL_TYPE_WEIBO){
    
        if (self.popoWEData != nil) {
            PoPoWEuser *weUsers = self.popoWEData.socialData;
            if (weUsers != nil && weUsers.friends != nil) {
                userCount = [weUsers.friends count];
            }
        }
    }else if (type == SOCIAL_TYPE_BAIDU){
        
        if (self.popoBDData != nil) {
            PoPoBDuser *bdUsers = self.popoBDData.socialData;
            if (bdUsers != nil && bdUsers.users != nil) {
                userCount = [bdUsers.users count];
            }
        }
    }
    
    return userCount;
}

-(void) setSocialSwitchStatus: (int) type
                       status: (BOOL) status{
    if (type == SOCIAL_TYPE_FACEBOOK){
        if (self.popoFBData != nil){
            self.popoFBData.isOpen = status;
            SettingService* ss = [SettingService get];
            [ss setBooleanValue:SOCIAL_FACEBOOK_SWITCH_ON_KEY data:status];
        }
    } else if (type == SOCIAL_TYPE_GOOGLE){
        if (self.popoGPData != nil){
            self.popoGPData.isOpen = status;
            SettingService* ss = [SettingService get];
            [ss setBooleanValue:SOCIAL_GOOGLE_SWITCH_ON_KEY data:status];
        }
    }else if (type == SOCIAL_TYPE_TWITTER){
        if (self.popoTWData != nil) {
            self.popoTWData.isOpen = status;
            SettingService *ss = [SettingService get];
            [ss setBooleanValue:SOCIAL_TWITTER_SWITCH_ON_KEY data:status];
        }
    }else if (type == SOCIAL_TYPE_WEIBO){
        if (self.popoWEData != nil) {
            self.popoWEData.isOpen = status;
            SettingService *ss = [SettingService get];
            [ss setBooleanValue:SOCIAL_WEIBO_SWITCH_ON_KEY data:status];
        }
    }else if (type == SOCIAL_TYPE_BAIDU){
        if (self.popoBDData != nil) {
            self.popoBDData.isOpen = status;
            SettingService *ss = [SettingService get];
            [ss setBooleanValue:SOCIAL_BAIDU_SWITCH_ON_KEY data:status];
        }
    }
}

-(NSMutableArray*) getSocialUserList: (int) type{
    NSMutableArray* userList = nil;
    
    if (type == SOCIAL_TYPE_FACEBOOK){
        if (self.popoFBData != nil){
            PopoFBUser* fbUsers = self.popoFBData.socialData;
            if (fbUsers != nil){
                userList= fbUsers.users;
            }
        }
    } else if (type == SOCIAL_TYPE_GOOGLE){
        if (self.popoGPData != nil){
            PopoGPUser* gpUsers = self.popoGPData.socialData;
            if (gpUsers != nil){
                userList  = gpUsers.users;
            }
        }
    }else if (type == SOCIAL_TYPE_TWITTER){
        if (self.popoTWData != nil) {
            PopoTWuser *twUsers = self.popoTWData.socialData;
            if (twUsers != nil) {
               
                TwitterUser *t = [[TwitterUser alloc] init];
                    for (int i = 0; i < twUsers.friends.count; i++) {
                        for (int j = 0; j < twUsers.friends.count - i - 1; j++) {
                            TwitterUser *user = [twUsers.friends objectAtIndex:j];
                            TwitterUser *userNest = [twUsers.friends objectAtIndex:j+1];
                            if ([user.followers_count  compare:userNest.followers_count] == NSOrderedAscending ) {
                                t = twUsers.friends[j];
                                twUsers.friends[j] = twUsers.friends[j + 1];
                                twUsers.friends[j + 1] = t;
                            }
                        }
                   }
             }
            userList = twUsers.friends;
        }
    }else if (type == SOCIAL_TYPE_WEIBO){
        if (self.popoWEData != nil){
            PoPoWEuser* weUsers = self.popoWEData.socialData;
            if (weUsers != nil){
                userList  = weUsers.friends;
            }
        }
    }else if (type == SOCIAL_TYPE_BAIDU){
        if (self.popoBDData != nil){
            PoPoBDuser* bdUsers = self.popoBDData.socialData;
            if (bdUsers != nil){
                userList  = bdUsers.users;
            }
        }
    }
    
    return userList;
}
-(void) setTWSocial: (NSDictionary*) dic
          isServer: (BOOL) isServer{
    if (dic == nil)
        return;
    
    if (self.popoTWData == nil){
        self.popoTWData = [PopoSocialDataItem alloc];
        self.popoTWData.type = SOCIAL_TYPE_TWITTER;
        
        SettingService* ss = [SettingService get];
        self.popoTWData.isOpen = [ss getBooleanValue:SOCIAL_TWITTER_SWITCH_ON_KEY defValue:NO];
        
        //self.popoFBData.isOpen = NO;
        if (self.popoTWData.socialData == nil){
            PopoTWuser* popTWUsers = [PopoTWuser alloc];
            popTWUsers.friends = [NSMutableArray arrayWithCapacity:1];
            self.popoTWData.socialData = popTWUsers;
        }
    }
    
    SettingService* ss = [SettingService get];
    
    PopoTWuser* twUsers = self.popoTWData.socialData;
    if (twUsers != nil && twUsers.friends != nil && [twUsers.friends count] > 0 && isServer == YES){
        NSMutableArray* serverUsersList = [NSMutableArray arrayWithCapacity:1];
    
        NSArray* likeData = [dic objectForKey:@"users"];
        if (likeData != nil){
            for(NSDictionary* item in likeData){
                TwitterUser* user = [TwitterUser alloc];
                
                NSString* tmpData = [item objectForKey:@"id_str"];
                if (tmpData != nil)
                    user.uId = tmpData;
                
                if (user.uId != nil){
                    NSString* userKey = [NSString stringWithFormat:@"twitter_%@", user.uId];
                    user.checked = [ss getBooleanValue:userKey defValue:YES];
                } else {
                    user.checked = YES;
                }
                
                tmpData = [item objectForKey:@"name"];
                if (tmpData != nil)
                    user.name = tmpData;
                tmpData = [item objectForKey:@"followers_count"];
                if (tmpData != nil) {
                    user.followers_count = tmpData;
                }
                [serverUsersList addObject:user];
            }
        }
        
        PopoTWuser* popTWUsers = self.popoTWData.socialData;
        
        for (int i = 0; i < [serverUsersList count]; i++) {
            TwitterUser* tmpUser = [serverUsersList objectAtIndex:i];
            for (int i = 0; i < [popTWUsers.friends count]; i++) {
                TwitterUser* addedUser = [popTWUsers.friends objectAtIndex:i];
                if ([addedUser.uId isEqualToString:tmpUser.uId]){
                    tmpUser.data = addedUser.data;
                    break;
                }
            }
        }
        
        [popTWUsers.friends removeAllObjects];
        popTWUsers.friends = nil;
        popTWUsers.friends = serverUsersList;
    } else {
        
        NSArray* likeData = [dic objectForKey:@"users"];
        if (likeData != nil){
            
            long likesCount = [likeData count];
            if (likesCount == 0){
                ITSApplication* app = [ITSApplication get];
            }
            
            for(NSDictionary* item in likeData){
                TwitterUser* user = [TwitterUser alloc];
                
                NSString* tmpData = [item objectForKey:@"id_str"];
                if (tmpData != nil)
                    user.uId = tmpData;
                
                if (user.uId != nil){
                    NSString* userKey = [NSString stringWithFormat:@"twitter_%@", user.uId];
                    user.checked = [ss getBooleanValue:userKey defValue:YES];
                } else {
                    user.checked = YES;
                }
                
                tmpData = [item objectForKey:@"name"];
                if (tmpData != nil)
                    user.name = tmpData;
                
                tmpData = [item objectForKey:@"followers_count"];{
                    if (tmpData != nil) {
                        user.followers_count = tmpData;
                    }
                }
                PopoTWuser* popTWUsers = self.popoTWData.socialData;
                BOOL isSame = NO;
                for (int i = 0; i < [popTWUsers.friends count]; i++) {
                    TwitterUser* addedUser = [popTWUsers.friends objectAtIndex:i];
                    if ([addedUser.uId isEqualToString:user.uId]){
                        isSame = YES;
                        break;
                    }
                }
                if (isSame == NO)
                    [popTWUsers.friends addObject:user];
            }
        }
    }
   
}


-(void) initFBUsersData{
    if (self.popoFBData == nil){
        self.popoFBData = [PopoSocialDataItem alloc];
        self.popoFBData.type = SOCIAL_TYPE_FACEBOOK;
        
        SettingService* ss = [SettingService get];
        self.popoFBData.isOpen = [ss getBooleanValue:SOCIAL_FACEBOOK_SWITCH_ON_KEY defValue:NO];
        
        if (self.popoFBData.socialData == nil){
            PopoFBUser* popFBUsers = [PopoFBUser alloc];
            popFBUsers.users = [NSMutableArray arrayWithCapacity:1];
            self.popoFBData.socialData = popFBUsers;
        }
        
        // if open init stroage data
    }
}

-(void) setFBSocial: (NSDictionary*) dic
          isServer: (BOOL) isServer{
    if (dic == nil)
        return;
    
    if (self.popoFBData == nil){
        self.popoFBData = [PopoSocialDataItem alloc];
        self.popoFBData.type = SOCIAL_TYPE_FACEBOOK;
        
        SettingService* ss = [SettingService get];
        self.popoFBData.isOpen = [ss getBooleanValue:SOCIAL_FACEBOOK_SWITCH_ON_KEY defValue:NO];
        
        //self.popoFBData.isOpen = NO;
        if (self.popoFBData.socialData == nil){
            PopoFBUser* popFBUsers = [PopoFBUser alloc];
            popFBUsers.users = [NSMutableArray arrayWithCapacity:1];
            self.popoFBData.socialData = popFBUsers;
        }
    }
    
    SettingService* ss = [SettingService get];
    
    PopoFBUser* fbUsers = self.popoFBData.socialData;
    if (fbUsers != nil && fbUsers.users != nil && [fbUsers.users count] > 0 && isServer == YES){
        NSMutableArray* serverUsersList = [NSMutableArray arrayWithCapacity:1];
        
        NSArray* likeData = [dic objectForKey:@"data"];
        if (likeData != nil){
            for(NSDictionary* item in likeData){
                FBUser* user = [FBUser alloc];
                
                NSString* tmpData = [item objectForKey:@"id"];
                if (tmpData != nil)
                    user.uId = tmpData;
                
                if (user.uId != nil){
                    NSString* userKey = [NSString stringWithFormat:@"Facebook_%@", user.uId];
                    user.checked = [ss getBooleanValue:userKey defValue:YES];
                } else {
                    user.checked = YES;
                }
                
                tmpData = [item objectForKey:@"name"];
                if (tmpData != nil)
                    user.name = tmpData;
                
                [serverUsersList addObject:user];
            }
        }
        
        PopoFBUser* popFBUsers = self.popoFBData.socialData;
        
        for (int i = 0; i < [serverUsersList count]; i++) {
            FBUser* tmpUser = [serverUsersList objectAtIndex:i];
            for (int j = 0; j < [popFBUsers.users count]; j++) {
                FBUser* addedUser = [popFBUsers.users objectAtIndex:j];
                if ([addedUser.uId isEqualToString:tmpUser.uId]){
                    tmpUser.data = addedUser.data;
                    break;
                }
            }
        }
        
        [popFBUsers.users removeAllObjects];
        popFBUsers.users = nil;
        popFBUsers.users = serverUsersList;
    } else {

        NSArray* likeData = [dic objectForKey:@"data"];
        if (likeData != nil){
            
            long likesCount = [likeData count];
            if (likesCount == 0){
                ITSApplication* app = [ITSApplication get];
                //[app.fbSvr setIsUserInitialized:NO];
            }
            
            for(NSDictionary* item in likeData){
                FBUser* user = [FBUser alloc];
               // [user setValuesForKeysWithDictionary:item];
                NSString* tmpData = [item objectForKey:@"id"];
                if (tmpData != nil)
                    user.uId = tmpData;
                
                if (user.uId != nil){
                    NSString* userKey = [NSString stringWithFormat:@"Facebook_%@", user.uId];
                    user.checked = [ss getBooleanValue:userKey defValue:YES];
                } else {
                    user.checked = YES;
                }
                
                tmpData = [item objectForKey:@"name"];
                if (tmpData != nil)
                    user.name = tmpData;
                
                PopoFBUser* popFBUsers = self.popoFBData.socialData;
                BOOL isSame = NO;
                for (int i = 0; i < [popFBUsers.users count]; i++) {
                    FBUser* addedUser = [popFBUsers.users objectAtIndex:i];
                    if ([addedUser.uId isEqualToString:user.uId]){
                        isSame = YES;
                        break;
                    }
                }
                if (isSame == NO)
                    [popFBUsers.users addObject:user];
            }
        }
    }
    
    NSDictionary* pagingData = [dic objectForKey:@"paging"];
    if (pagingData != nil){
        NSDictionary* cursorsData = [pagingData objectForKey:@"cursors"];
        if (cursorsData != nil){
            FBPaging* fbPage = [FBPaging alloc];
            NSString* tmpData = [cursorsData objectForKey:@"after"];
            if (tmpData != nil)
                fbPage.next = tmpData;
            
            tmpData = [cursorsData objectForKey:@"before"];
            if (tmpData != nil)
                fbPage.previous = tmpData;
            
            PopoFBUser* popFBUsers = self.popoFBData.socialData;
            popFBUsers.likePaging = fbPage;
            //self.popFBUsers.likePaging = fbPage;
        }
    }
   
}

-(void) setSocialNewsToList: (NSMutableArray*) list
                     newsId: (NSString*) nId
                   newsItem: (id) item
                   newsType: (int) type
                    addType: (BOOL) isTop{
    if (list == nil || item == nil)
        return;
    BOOL isFind = NO;
    long listCount = [list count];
    for (int i = 0; i < listCount; i++) {
        PopoSocialNewItem* tmp = [list objectAtIndex:i];
        if (tmp != nil && [tmp.nId compare:nId] == NSOrderedSame){
            isFind = YES;
            break;
        }
    }
    
    PopoSocialNewItem* nItem = [PopoSocialNewItem alloc];
    nItem.data = item;
    nItem.nId = nId;
    nItem.type = type;
    
    if (isFind == NO){
        if (isTop){
            [list insertObject:nItem atIndex:0];
        } else
            [list addObject:nItem];
    }
}



-(void) updateFBUserPaging: (NSString*) uId
                      data: (NSDictionary*) dic
               resetPaging: (BOOL) flag{
    
    if(uId == nil || dic == nil || self.popoFBData == nil)
        return;
    //if(uId == nil || dic == nil || self.popFBUsers == nil)
    //    return;
    long uCount = 0;
//    if (self.popFBUsers.users != nil)
//        uCount = [self.popFBUsers.users count];
    
    PopoFBUser* popFBUsers = self.popoFBData.socialData;
    if (popFBUsers.users != nil)
        uCount = [popFBUsers.users count];
    
    for(int i = 0; i < uCount; i++){
        //FBUser* user = [self.popFBUsers.users objectAtIndex:i];
        FBUser* user = [popFBUsers.users objectAtIndex:i];
        if (user != nil && [user.uId compare:uId] == NSOrderedSame){
            
            if (user.dataPaging != nil && flag == NO)
                return;
            
            if (user.dataPaging == nil)
                user.dataPaging = [FBPaging alloc];
            
            NSString* tmpData = [dic objectForKey:@"next"];
            if (tmpData != nil)
                user.dataPaging.next = tmpData;
            
            tmpData = [dic objectForKey:@"previous"];
            if (tmpData != nil)
                user.dataPaging.previous = tmpData;
            
            break;
        }
    }
}
-(NSString*) getTWCategoryId{
    NSString* fbcId = @"notset";
    if (self.categoryList != nil) {
        for(NewsCategory* cate in self.categoryList){
            if (cate != nil){
                if ([cate.type compare:@"twitter"] == NSOrderedSame){
                    fbcId = cate.cId;
                }
            }
        }
    }
    
    return fbcId;
}
-(NSString*) getFBCategoryId{
    NSString* fbcId = @"notset";
    if (self.categoryList != nil) {
        for(NewsCategory* cate in self.categoryList){
            if (cate != nil){
                if ([cate.type compare:@"facebook"] == NSOrderedSame){
                    fbcId = cate.cId;
                }
            }
        }
    }
    
    return fbcId;
}
-(NSString*) getWBCategoryId{
    NSString* fbcId = @"notset";
    if (self.categoryList != nil) {
        for(NewsCategory* cate in self.categoryList){
            if (cate != nil){
                if ([cate.type compare:@"weibo"] == NSOrderedSame){
                    fbcId = cate.cId;
                }
            }
        }
    }
    
    return fbcId;
}
-(void) clearTWSocialNews{
    if (self.popoTWData != nil){
        PopoTWuser* popTWUsers = self.popoTWData.socialData;
        if (popTWUsers.friends != nil){
            [popTWUsers.friends removeAllObjects];
            popTWUsers = nil;
        }
        self.popoTWData = nil;
    }
    if (self.poponewsList != nil){
        for (PopoNewsData* data in self.poponewsList){
            if (data != nil){
                NewsCategory* cate = data.category;
                if (cate.type != nil && [cate.type compare:@"social"] == NSOrderedSame){
                    if (data.data != nil){
                        [data.data removeAllObjects];
                        data.data = nil;
                    }
                    return;
                }
            }
        }
    }
}

-(void) clearWBSocialNews{
    if (self.popoWEData != nil){
        PoPoWEuser* popFBUsers = self.popoWEData.socialData;
        if (popFBUsers.friends != nil){
            [popFBUsers.friends removeAllObjects];
            popFBUsers = nil;
        }
        self.popoWEData = nil;
    }
    if (self.poponewsList != nil){
        for (PopoNewsData* data in self.poponewsList){
            if (data != nil){
                NewsCategory* cate = data.category;
                if (cate.type != nil && [cate.type compare:@"weibo"] == NSOrderedSame){
                    if (data.data != nil){
                        [data.data removeAllObjects];
                        data.data = nil;
                    }
                    
                    return;
                }
            }
        }
    }
}

-(void) initGPSocial{
//    if (self.categoryList != nil){
//        NewsCategory* gpCate = nil;
//        for (NewsCategory* item in self.categoryList) {
//            if ([item.type compare:@"social"] == NSOrderedSame){
//                gpCate = item;
//                break;
//            }
//        }
    if (self.popoGPData == nil){
        self.popoGPData = [PopoSocialDataItem alloc];
        self.popoGPData.type = SOCIAL_TYPE_GOOGLE;
        SettingService* ss = [SettingService get];
        self.popoGPData.isOpen = [ss getBooleanValue:SOCIAL_GOOGLE_SWITCH_ON_KEY defValue:YES];
        self.popoGPData.socialData = nil;
    }
    
    if (self.socialCategory != nil){
        NewsCategory* gpCate = self.socialCategory;
    
        if (gpCate != nil){
            if (self.popoGPData != nil){
//                self.popoGPData = [PopoSocialDataItem alloc];
//                self.popoGPData.type = SOCIAL_TYPE_GOOGLE;
//                SettingService* ss = [SettingService get];
//                self.popoGPData.isOpen = [ss getBooleanValue:SOCIAL_GOOGLE_SWITCH_ON_KEY defValue:NO];
//                //self.popoGPData.isOpen = NO;
                if (self.popoGPData.socialData == nil && gpCate.extra != nil){
                    PopoGPUser* popGPUsers = [PopoGPUser alloc];
                    popGPUsers.users = [NSMutableArray arrayWithCapacity:1];
                    self.popoGPData.socialData = popGPUsers;
                    
                    SocialCategoryItem* gpCateCh = nil;
                    for (SocialCategoryItem* tmpCateCh in gpCate.extra) {
                        if (tmpCateCh != nil && [tmpCateCh.name compare:@"google"] == NSOrderedSame){
                            gpCateCh = tmpCateCh;
                            break;
                        }
                    }
                    SettingService* ss = [SettingService get];
                    if (gpCateCh != nil && gpCateCh.channels != nil){
                        for (GooglePlusChannelItem* chItem in gpCateCh.channels) {
                            GoolgePlusUser* gpUser = [GoolgePlusUser alloc];
                            gpUser.uId = [MMSystemHelper getMd5String:chItem.name];
                            gpUser.name = chItem.name;
                            gpUser.link = chItem.rssUrl;
                            gpUser.links = chItem.rssUrls;
                            if (gpUser.uId != nil){
                                NSString* userKey = [NSString stringWithFormat:@"Google_%@", gpUser.uId];
                                gpUser.isChecked = [ss getBooleanValue:userKey defValue:YES];
                            } else
                                gpUser.isChecked = YES;
                            gpUser.data = nil;
                            
                            [popGPUsers.users addObject:gpUser];
                        }
                    }
                }
            }
        }
    }
}

-(NSString*) getGPNewsPicFromDesp: (NSString*) desp{
    NSString* imgUrl = nil;
    
    if (desp != nil){
        NSRange startRange = [desp rangeOfString:@"<img src=\""];
        if (startRange.length == 0)
            return nil;
        NSString* tmpStr1 = [desp substringFromIndex:startRange.location+10];
        
        // @"\" alt=\"\" border=\"1\" width=\"80\" height=\"80\">"
        NSRange endRange = [tmpStr1 rangeOfString:@"\""];
        if (endRange.length == 0)
            return nil;
        NSString* tmpStr2 = [tmpStr1 substringToIndex:endRange.location];
        
        imgUrl = [NSString stringWithFormat:@"http:%@", tmpStr2];
    }
    
    return imgUrl;
}
-(NSString*) getBDNewsPicFromDesp: (NSString*) desp{
    NSString* imgUrl = nil;
    if (desp != nil){
        if ([desp rangeOfString:@"img border"].location != NSNotFound) {
            NSArray *arr = [desp componentsSeparatedByString:@"src="];
            NSString *str = [arr objectAtIndex:1];
            NSArray *http = [str componentsSeparatedByString:@">"];
            NSString *picStr = [http objectAtIndex:0];
            NSArray *pic = [picStr componentsSeparatedByString:@"http://"];
            NSString *newStr = [pic objectAtIndex:1];
            NSArray *lastStr = [newStr componentsSeparatedByString:@"=30"];
            imgUrl = [NSString stringWithFormat:@"http://%@=30",[lastStr objectAtIndex:0]];
        }

    }
    return imgUrl;
}

-(void) updateCategoryShowType: (NSString*) cId
                          type: (NSString*) type{
    if (cId == nil || type == nil)
        return;
    
    NewsCategory* category = [self getCategoryByID:cId];
    category.layout = type;
    
    // save to db
    SettingService* ss = [SettingService get];
    NSString* customCId = [NSString stringWithFormat:@"%@_%@", CATEGORY_CUSTOM_LAYOUT_PERFIX, cId];
    [ss setStringValue:customCId data:type];
    
    // refresh gridData
    PopoNewsData* dataCate = nil;
    if (self.poponewsList != nil && cId != nil){
        for (PopoNewsData* item in self.poponewsList) {
            if (item != nil){
                if (item.category.cId == cId) {
                    dataCate = item;
                    break;
                } else if ([item.category.cId compare:cId] == NSOrderedSame){
                    dataCate = item;
                    break;
                }
            }
        }
    }
}

- (void)getNewsNewsListWithAdList:(NSString* )cid :(int)type{
    
    BOOL isHadNetwork = [MMSystemHelper isConnectedToNetwork];
    
    if (type == NEWS_REFRESH_TYPE_BEFORE && isHadNetwork == YES) {
        if (self.poponewsList != nil && cid != nil){
            for (PopoNewsData* item in self.poponewsList) {
                if (item != nil){
                    if ([item.category.cId compare:cid] == NSOrderedSame){

                        if (item.data == nil) {
                            item.data = [NSMutableArray arrayWithCapacity:1];
                    }
                        [self getNewsAdItemAtIndex:item];
                    }
                }
            }
        }
    }
}
-(int)getRandomValue :(int)percent{
    int value = arc4random()%percent * 2 + 1;
    return value;
}
- (void)getNewsAdItemAtIndex:(PopoNewsData*)item{
    
    static NSInteger  idx = 0;
    static NSInteger fbIdx = 0;
    BOOL isEnabled = self.minikitCh.nativeAd.enabled;
    if (isEnabled == YES) {
        for (NativeAdItem *AdItem in self.itemData.nativeAdData) {
//            NSInteger fbAdCount = AdItem.adsManager.uniqueNativeAdCount;
//            if (AdItem.FbIsLoad == YES ) {
//                    fbIdx = item.data.count;
//                    id itemNews = [item.data objectAtIndex:fbIdx - 5];
//                    if ([itemNews isKindOfClass:[PoPoNewsItem class]]) {
//                        if (item.data.count > 0 && AdItem.index < fbAdCount) {
//                            FBNativeAd *fbAd = [self.fbAd objectAtIndex:AdItem.index];
//                            [item.data insertObject:fbAd atIndex:fbIdx - 5];
//                            AdItem.index += 1;
//                            
//                            ITSApplication* poApp = [ITSApplication get];
//                            //[poApp.reportSvr recordAdPurchase:fbAd.placementID type:@"facebook"];
//                        }
//                    }
//            }
            
                if (AdItem.isLoad == NO) {
                    [AdItem load];
                }else if (AdItem.isLoad == YES){
                    NSInteger count = [AdItem getCount:AdItem];
                    idx = item.data.count;
                    if (idx > 5) {
                        id itemNews = [item.data objectAtIndex:idx - 5];
                        if ([itemNews isKindOfClass:[PoPoNewsItem class]]) {
                            if (item.data.count > 0 && AdItem.index < count) {
                                GRAdItem* grAd = [self.gmobiAd objectAtIndex:AdItem.index];
                                [item.data insertObject:[self.gmobiAd objectAtIndex:AdItem.index] atIndex:idx - 5];
                                AdItem.index += 1;
                                
                                GRNativeAd* gAd = grAd.ad;
                                ITSApplication* poApp = [ITSApplication get];
                                //[poApp.reportSvr recordAdPurchase:gAd.placement type:@"gmobi"];
                            }
                       }
                  }
             }
        }
    }

}


// push news
-(BOOL) checkPushNewsId: (NSString*) nid{
    if (self.pushNewsList == nil) return NO;
    BOOL isFind = NO;
    for (PoPoNewsItem* tmpItem in self.pushNewsList) {
        if (tmpItem != nil){
            PoPoNewsItem* newsItem = tmpItem;
            if ([newsItem.nId compare:nid] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    return isFind;
}

-(BOOL) insert2PushNewsList: (PoPoNewsItem*) item
                   saveFlag: (BOOL) saved {
    if (item == nil)
        return NO;
    
    BOOL isFind = NO;
    
    if (self.pushNewsList == nil){
        self.pushNewsList = [NSMutableArray arrayWithCapacity:1];
    }
    
    for (PoPoNewsItem* tmpItem in self.pushNewsList) {
        if (tmpItem != nil){
            PoPoNewsItem* newsItem = tmpItem;
            if (newsItem == item || [newsItem.nId compare:item.nId] == NSOrderedSame){
                isFind = YES;
                break;
            }
        }
    }
    
    if (isFind == NO){
        [self.pushNewsList insertObject:item atIndex:0];
        
        long listCount = [self.pushNewsList count];
        if (listCount > MAX_PUSH_NEWS_COUNT){
            [self.pushNewsList removeObjectAtIndex:listCount-1];
        }
        
        if (saved == YES){
            // save to db
            NewsService* ns = [NewsService get];
            [ns saveFeedNewsItem:item.nId data:[item toDictionaryDataHasReadStatus]];
        }
        return YES;
    }
    
    return NO;
}

-(void) updatePushNewsToStorage: (PoPoNewsItem*) item{
    if (item == nil) return;
    NewsService* ns = [NewsService get];
    [ns saveFeedNewsItem:item.nId data:[item toDictionaryDataHasReadStatus]];
}

-(NSMutableArray*) getPushNewsList{
    return self.pushNewsList;
}

-(void) initPushNewsList {
    NewsService* ns = [NewsService get];
    NSMutableArray* pList = [ns getStorageFeedNewsList];
    if (pList != nil){
        if (self.pushNewsList != nil){
            [self.pushNewsList removeAllObjects];
            self.pushNewsList = nil;
        }
        self.pushNewsList = [NSMutableArray arrayWithArray:pList];
    }
}

-(void) getPushNewsDetail: (NSString*) nId
         isShowDetailPage: (BOOL) isShowDetailPage{
    //[[ITSApplication get].remoteSvr getNewsById:nId isShowDetailPage:isShowDetailPage];
}

-(void) initUser{
    
    self.user = [[PopoUser alloc] init];
    [self.user initWithData];
    
    // load last login user info;
    SettingService* ss = [SettingService get];
    NSDictionary *data = [ss getDictoryValue:CONFIG_USERLOGIN_INFO defValue:nil];
    if (data != nil){
        self.user.uId = [MMDictionaryHelper selectString:(NSMutableDictionary*)data path:@"data/user/_id" def:nil];
        self.user.avatar = [MMDictionaryHelper selectString:(NSMutableDictionary*)data path:@"data/user/avatar" def:nil];
        self.user.userName = [MMDictionaryHelper selectString:(NSMutableDictionary*)data path:@"data/user/name" def:nil];
        self.user.email = [MMDictionaryHelper selectString:(NSMutableDictionary*)data path:@"data/user/email" def:nil];
        
        [self.user.primary removeAllObjects];
        NSArray* primaryData = [MMDictionaryHelper select:(NSMutableDictionary*)data path:@"data/primary" def:nil];
        if (primaryData != nil){
            for (int i = 0; i < [primaryData count]; i++) {
                NSDictionary* pData = [primaryData objectAtIndex:i];
                if (pData != nil){
                    PopoThirdUser* u = [PopoThirdUser alloc];
                    u.type = [MMDictionaryHelper selectString:(NSMutableDictionary*)pData path:@"type" def:nil];
                    u.openid = [MMDictionaryHelper selectString:(NSMutableDictionary*)pData path:@"open_id" def:nil];
                    u.email = [MMDictionaryHelper selectString:(NSMutableDictionary*)pData path:@"email" def:nil];
                    [self.user.primary addObject:u];
                }
            }
        }
        
        if (self.user.uId != nil)
            self.user.isLogin = YES;
    }
}
@end

