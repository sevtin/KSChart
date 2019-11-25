//
//  KSWebSocketConfigure.h
//  ZeroShare
//
//  Created by saeipi on 2018/8/29.
//  Copyright © 2018年 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,KSWebSocketStatus) {
    KSWebSocketStatusNone = 0,//默认/关闭
    KSWebSocketStatusConnecting,//连接中
    KSWebSocketStatusConnected,//连接成功
    KSWebSocketStatusConnectFail,//出现错误/连接失败
    KSWebSocketStatusLoseConnect//主动关闭连接
};

typedef NS_ENUM(NSInteger, KSNetworkReachabilityStatus) {
    KSNetworkReachabilityStatusUnknown          = -1,
    KSNetworkReachabilityStatusNotReachable     = 0,
    KSNetworkReachabilityStatusReachableWAN     = 1,
};


@interface KSWebSocketConfigure : NSObject
/**
 最大重连次数,默认10次
 */
@property (nonatomic, assign) int                          maxResetCount;
/**
 重连计数
 */
@property (nonatomic, assign) int                          resetCount;
/**
 重连计时
 */
@property (nonatomic, assign) int                          reconnectTime;
/**
 服务端地址
 */
@property (nonatomic, copy  ) NSString                     *urlString;
/**
 是否自动连接
 */
@property (nonatomic, assign) BOOL                         isAutoConnect;
/**
 是否发起连接
 */
@property (nonatomic, assign) BOOL                         isConnect;
/**
 网络连接是否正常
 */
@property (nonatomic, assign) BOOL                         isReachable;
/**
 状态
 */
@property (nonatomic, assign) KSWebSocketStatus              status;
@property (nonatomic, assign) KSNetworkReachabilityStatus networkStatus;

/**
 Token
 */
@property (nonatomic, copy  ) NSString                     *authorToken;
/**
 心跳间隔时间
 */
@property (nonatomic, assign) int                          heartbeatTime;
/**
 重连间隔时间
 */
@property (nonatomic, assign) int                          intervalTime;

@end

