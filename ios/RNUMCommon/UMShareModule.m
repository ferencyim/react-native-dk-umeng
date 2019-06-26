//
//  ShareModule.h
//  UMComponent
//
//  Created by wyq.Cloudayc on 11/09/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "UMShareModule.h"
#import <UMShare/UMShare.h>
//#import <UShareUI/UShareUI.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
//#import <MessageUI/MessageUI.h>
static NSString * const openShareUrl = @"openShareUrl";
@interface UMShareModule()
@property (nonatomic, strong) UIViewController *smsViewController;
@end
@implementation UMShareModule

RCT_EXPORT_MODULE();
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(instancetype)init{
    self = [super init];
    if (self) {
        [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(shareResult:) name:openShareUrl object:nil];
    }
    return self;
}


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (UMSocialPlatformType)platformType:(NSInteger)platform
{
    switch (platform) {
        case 0: // QQ
            return UMSocialPlatformType_QQ;
        case 1: // Sina
            return UMSocialPlatformType_Sina;
        case 2: // wechat
            return UMSocialPlatformType_WechatSession;
        case 3:
            return UMSocialPlatformType_WechatTimeLine;
        case 4:
            return UMSocialPlatformType_Qzone;
        case 5:
            return UMSocialPlatformType_Email;
        case 6:
            return UMSocialPlatformType_Sms;
        case 7:
            return UMSocialPlatformType_Facebook;
        case 8:
            return UMSocialPlatformType_Twitter;
        case 9:
            return UMSocialPlatformType_WechatFavorite;
        case 10:
            return UMSocialPlatformType_GooglePlus;
        case 11:
            return UMSocialPlatformType_Renren;
        case 12:
            return UMSocialPlatformType_TencentWb;
        case 13:
            return UMSocialPlatformType_Douban;
        case 14:
            return UMSocialPlatformType_FaceBookMessenger;
        case 15:
            return UMSocialPlatformType_YixinSession;
        case 16:
            return UMSocialPlatformType_YixinTimeLine;
        case 17:
            return UMSocialPlatformType_Instagram;
        case 18:
            return UMSocialPlatformType_Pinterest;
        case 19:
            return UMSocialPlatformType_EverNote;
        case 20:
            return UMSocialPlatformType_Pocket;
        case 21:
            return UMSocialPlatformType_Linkedin;
        case 22:
            return UMSocialPlatformType_UnKnown; // foursquare on android
        case 23:
            return UMSocialPlatformType_YouDaoNote;
        case 24:
            return UMSocialPlatformType_Whatsapp;
        case 25:
            return UMSocialPlatformType_Line;
        case 26:
            return UMSocialPlatformType_Flickr;
        case 27:
            return UMSocialPlatformType_Tumblr;
        case 28:
            return UMSocialPlatformType_AlipaySession;
        case 29:
            return UMSocialPlatformType_KakaoTalk;
        case 30:
            return UMSocialPlatformType_DropBox;
        case 31:
            return UMSocialPlatformType_VKontakte;
        case 32:
            return UMSocialPlatformType_DingDing;
        case 33:
            return UMSocialPlatformType_UnKnown; // more
        default:
            return UMSocialPlatformType_QQ;
    }
}

- (void)shareWithText:(NSString *)text icon:(NSString *)icon link:(NSString *)link title:(NSString *)title platform:(NSInteger)platform completion:(UMSocialRequestCompletionHandler)completion
{
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    if (link.length > 0) {
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:text thumImage:icon];
        shareObject.webpageUrl = link;

        messageObject.shareObject = shareObject;
    } else if (icon.length > 0) {
        id img = nil;
        if ([icon hasPrefix:@"http"]) {
            img = icon;
        } else {
            if ([icon hasPrefix:@"/"]) {
                img = [UIImage imageWithContentsOfFile:icon];
            } else {
                img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:icon ofType:nil]];
            }
        }
        UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
        shareObject.thumbImage = img;
        shareObject.shareImage = img;
        messageObject.shareObject = shareObject;

        messageObject.text = text;
    } else if (text.length > 0) {
        messageObject.text = text;
    }else {
        if (completion) {
            completion(nil, [NSError errorWithDomain:@"UShare" code:-3 userInfo:@{@"message": @"invalid parameter"}]);
            return;
        }
    }
    [[UMSocialManager defaultManager] shareToPlatform:platform messageObject:messageObject currentViewController:nil completion:completion];
}

+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication  annotation:(id)annotation{
    BOOL result =  [[UMSocialManager defaultManager]handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
//     [[UMShareListener new]shareResult:result];
//    [self performSelector:@selector(shareResult:) withObject:@(result)];
    [[NSNotificationCenter defaultCenter]postNotificationName:openShareUrl object:nil userInfo:@{@"result":@(result)}];
    return result;
}
+(BOOL)handleOpenURL:(NSURL *)url{
    BOOL result = [[UMSocialManager defaultManager]handleOpenURL:url];
//    [self shareResult:result];
//    [self performSelector:@selector(shareResult:) withObject:@(result)];
    [[NSNotificationCenter defaultCenter]postNotificationName:openShareUrl object:nil userInfo:@{@"result":@(result)}];

    return result;
}
//是否安装某个平台
RCT_EXPORT_METHOD(isInstall:(NSInteger)param resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
     UMSocialPlatformType plf = [self platformType:param];
    if ( [[UMSocialManager defaultManager]isInstall:plf]) {
        resolve(@(0));
    } else {
        reject(@"1",@"未安装该平台",nil);
    }
}

// 当前平台是否支持分享
RCT_EXPORT_METHOD(isSupport:(NSInteger)param resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    UMSocialPlatformType plf = [self platformType:param];
    if ([[UMSocialManager defaultManager]isSupport:plf]) {
        resolve(@(0));
    } else {
        reject(@"1",@"本平台不支持分享",nil);
    }
}

//获取客户端安装平台
RCT_EXPORT_METHOD(clientInstallPlatform:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    if ([UMSocialManager defaultManager].platformTypeArray.count > 0) {
        resolve([UMSocialManager defaultManager].platformTypeArray);
    }else{
         reject(@"1",@"客户端未安装任何分享平台",nil);
    }
}

RCT_EXPORT_METHOD(share:(NSDictionary*)params resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *text  = params[@"text"];
    NSString *icon  = params[@"image"];;
    NSString *link  = params[@"weburl"];;
    NSString *title  = params[@"title"];;
    NSString *platform  = params[@"sharemedia"];;
    
    UMSocialPlatformType plf = [self platformType:platform.integerValue];
    if (plf == UMSocialPlatformType_UnKnown) {
        if (reject) {
            //      completion(@[@(UMSocialPlatformType_UnKnown), @"invalid platform"]);
            reject(@"1",@"invalid platform",nil);
            return;
        }
    }
//    UMShareSmsObject
    [self shareWithText:text icon:icon link:link title:title platform:plf completion:^(id result, NSError *error) {
        
        if (error) {
            
            NSString *msg = error.userInfo[@"NSLocalizedFailureReason"];
            if (!msg) {
                msg = error.userInfo[@"message"];
            }
            if (!msg) {
                msg = @"share failed";
            }
            NSInteger stcode =error.code;
            if(stcode == 2009){
                stcode = -1;
            }
            //        completion(@[@(stcode), msg]);
            reject(@(stcode).stringValue,msg,nil);
        } else {
            //        completion(@[@200, @"share success"]);
            resolve(@(0));
        }
    }];
    
}

RCT_EXPORT_METHOD(shareboard:(NSString *)text icon:(NSString *)icon link:(NSString *)link title:(NSString *)title platform:(NSArray *)platforms completion:(RCTResponseSenderBlock)completion)
{
    NSMutableArray *plfs = [NSMutableArray array];
    for (NSNumber *plf in platforms) {
        [plfs addObject:@([self platformType:plf.integerValue])];
    }
    if (plfs.count > 0) {
        //    [UMSocialUIManager setPreDefinePlatforms:plfs];
    }
    //  [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
    //    [self shareWithText:text icon:icon link:link title:title platform:platformType completion:^(id result, NSError *error) {
    //      if (completion) {
    //        if (error) {
    //          NSString *msg = error.userInfo[@"NSLocalizedFailureReason"];
    //          if (!msg) {
    //            msg = error.userInfo[@"message"];
    //          }if (!msg) {
    //            msg = @"share failed";
    //          }
    //          NSInteger stcode =error.code;
    //          if(stcode == 2009){
    //            stcode = -1;
    //          }
    //          completion(@[@(stcode), msg]);
    //        } else {
    //          completion(@[@200, @"share success"]);
    //        }
    //      }
    //    }];
    //  }];
}

//设置平台
RCT_EXPORT_METHOD(setAccount:(NSDictionary*)params resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
      UMSocialPlatformType plf = [self platformType: [RCTConvert NSInteger:params[@"type"]]];
//    NSInteger plaform = [RCTConvert NSInteger:params[@"type"]];
    if (plf == UMSocialPlatformType_Sms) {
        if ([[UMSocialManager defaultManager]setPlaform:plf appKey:nil appSecret:nil redirectURL:nil]) {

            resolve(@(0));
        } else {
            reject(@"1",@"失败",nil);
        }
    } else {
        if ([[UMSocialManager defaultManager]setPlaform:plf appKey:params[@"appId"] appSecret:params[@"secret"] redirectURL:params[@"redirectURL"]]) {
            
            resolve(@(0));
        } else {
            
            reject(@"1",@"失败",nil);
        }
    }
}



RCT_EXPORT_METHOD(auth:(NSInteger)platform completion:(RCTResponseSenderBlock)completion)
{
    UMSocialPlatformType plf = [self platformType:platform];
    if (plf == UMSocialPlatformType_UnKnown) {
        if (completion) {
            completion(@[@(UMSocialPlatformType_UnKnown), @"invalid platform"]);
            return;
        }
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:plf currentViewController:nil completion:^(id result, NSError *error) {
        if (completion) {
            if (error) {
                NSString *msg = error.userInfo[@"NSLocalizedFailureReason"];
                if (!msg) {
                    msg = error.userInfo[@"message"];
                }if (!msg) {
                    msg = @"share failed";
                }
                NSInteger stCode = error.code;
                if(stCode == 2009){
                    stCode = -1;
                }
                completion(@[@(stCode), @{}, msg]);
            } else {
                UMSocialUserInfoResponse *authInfo = result;
                
                NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:8];
                retDict[@"uid"] = authInfo.uid;
                retDict[@"openid"] = authInfo.openid;
                retDict[@"unionid"] = authInfo.unionId;
                retDict[@"accessToken"] = authInfo.accessToken;
                retDict[@"refreshToken"] = authInfo.refreshToken;
                retDict[@"expiration"] = authInfo.expiration;
                
                retDict[@"name"] = authInfo.name;
                retDict[@"iconurl"] = authInfo.iconurl;
                retDict[@"gender"] = authInfo.unionGender;
                
                NSDictionary *originInfo = authInfo.originalResponse;
                retDict[@"city"] = originInfo[@"city"];
                retDict[@"province"] = originInfo[@"province"];
                retDict[@"country"] = originInfo[@"country"];
                
                completion(@[@200, retDict, @""]);
            }
        }
    }];
}

#pragma 给js 发送消息
- (NSArray<NSString *> *)supportedEvents
{
    return @[@"shareCallBack"];
}


-(void)shareResult:(NSNotification *)notification{
    NSNumber * result = notification.userInfo[@"result"];
     [self sendEventWithName:@"shareCallBack" body:result];
}

@end

