//
//  KSWebSocket.h
//  ZeroShare
//
//  Created by saeipi on 2018/8/29.
//  Copyright © 2018年 saeipi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"
#import "KSWebSocketConfigure.h"

@class KSWebSocket;

@protocol KSWebSocketDelegate <NSObject>

@optional
/**
 连接成功
 */
- (void)socketDidOpen:(KSWebSocket *)socket;
/**
 出现错误/连接失败时调用[如果设置自动重连，则不会调用]
 */
- (void)socketDidFail:(KSWebSocket *)socket;
/**
 收到消息
 */
- (void)socket:(KSWebSocket *)socket didReceivedMessage:(id)message;
/**
 异常断开,且重连失败
 */
- (void)socketReconnectionFailure:(KSWebSocket *)socket;
/**
 服务端断开
 */
- (void)socketDidClose:(KSWebSocket *)socket;
/**
 网络变化回调
 */
-(void)socket:(KSWebSocket *)socket isReachable:(BOOL)isReachable;

@end

@interface KSWebSocket : NSObject <SRWebSocketDelegate>
/**
 代理
 */
@property(nonatomic, weak) id<KSWebSocketDelegate> delegate;
/**
 是否需要认证
 */
@property (nonatomic,assign ) BOOL                     isAuthor;
/**
 配置模型
 */
@property (nonatomic, strong) KSWebSocketConfigure     *configure;
/**
 标识，多个socket身份标志
 */
@property (nonatomic, copy  ) NSString                 *identifier;

+ (instancetype)shareInstance;
/**
 单例socket初始化
 */
+ (void)initWithDelegate:(id)delegate serverUrl:(NSString *)serverUrl isAutoConnect:(BOOL)isAutoConnect;
- (void)configureServer:(NSString *)url isAutoConnect:(BOOL)isAutoConnect;
- (void)addNotificationListener;
- (void)removeNotification;
- (void)startConnect;
- (void)activeClose;
- (void)resetConnectServer;
- (void)sendMessage:(NSMutableDictionary *)message;
- (void)updateStatusForisOpen:(BOOL)isOpen;
/*
 SR_CONNECTING   = 0,
 SR_OPEN         = 1,
 SR_CLOSING      = 2,
 SR_CLOSED       = 3,
 */
- (int)readyState;

@end
