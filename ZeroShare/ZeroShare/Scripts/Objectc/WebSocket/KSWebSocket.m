//
//  KSWebSocket.m
//  ZeroShare
//
//  Created by saeipi on 2018/8/29.
//  Copyright © 2018年 saeipi. All rights reserved.
//

#import "KSWebSocket.h"
#define KSWeakSelf __weak typeof(self) weakSelf      = self;

static NSString *KS_Notification_WillEnterForeground = @"KS_Notification_WillEnterForeground";
static NSString *KS_Notification_DidEnterBackground  = @"KS_Notification_DidEnterBackground";
static NSString *KS_Notification_NetworkChange       = @"KS_Notification_NetworkChange";

@interface KSWebSocket ()
/**
 WebSocket
 */
@property (nonatomic,strong ) SRWebSocket           *webSocket;
/**
 心跳计时器
 */
@property (nonatomic,weak   ) NSTimer               *heartbeatTimer;

@end

@implementation KSWebSocket
/*
+ (instancetype)shareInstance {
    static KSWebSocket *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KSWebSocket alloc] init];
    });
    return instance;
}

+ (void)initWithDelegate:(id)delegate serverUrl:(NSString *)serverUrl isAutoConnect:(BOOL)isAutoConnect {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        KSWebSocket *socket = [KSWebSocket shareInstance];
        socket.delegate      = delegate;
        [socket configureServer:serverUrl isAutoConnect:isAutoConnect];
        [socket startConnect];
    });
}
*/
- (id)init {
    self = [super init];
    if (self) {
        self.configure.urlString                       = nil;
        self.configure.status                          = KSWebSocketStatusNone;
        self.configure.networkStatus                   = KSNetworkReachabilityStatusUnknown;
        [self defaultValues];
    }
    return self;
}

- (void)defaultValues {
    _configure.resetCount    = 0;
    _configure.reconnectTime = 0;
    _configure.isReachable   = YES;//方便测试
}

- (void)updateStatusForisOpen:(BOOL)isOpen {
    if (_configure.isConnect) {
        if (isOpen) {
            if (_webSocket.readyState != SR_OPEN &&
                _configure.status == KSWebSocketStatusNone &&
                _configure.isAutoConnect == YES) {
                [self defaultValues];
                [self startConnect];
            }
        }
        else{
            
        }
    }
}

-(void)configureServer:(NSString *)url isAutoConnect:(BOOL)isAutoConnect {
    _configure.urlString     = url;
    _configure.isAutoConnect = isAutoConnect;
}

- (int)readyState {
    return (int)_webSocket.readyState;
}

- (void)addNotificationListener {
    [self removeNotification];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:KS_Notification_WillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:KS_Notification_DidEnterBackground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNetworkReachabilityStatus) name:KS_Notification_NetworkChange object:nil];
}

- (void)willEnterForeground {
    [self updateStatusForisOpen:YES];
}

- (void)didEnterBackground {
    [self updateStatusForisOpen:NO];
}

-(void)updateNetworkReachabilityStatus {
    if (_configure.isReachable == YES) {
        if (_configure.networkStatus != KSNetworkReachabilityStatusReachableWAN) {
            _configure.networkStatus = KSNetworkReachabilityStatusReachableWAN;
            [self updateStatusForisOpen:YES];
        }
    }
    else{
        if (_configure.networkStatus != KSNetworkReachabilityStatusNotReachable) {
            _configure.networkStatus = KSNetworkReachabilityStatusNotReachable;
            [self close];
        }
    }
    if ([_delegate respondsToSelector:@selector(socket:isReachable:)]) {
        [_delegate socket:self isReachable:_configure.isReachable];
    }
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startConnect {
    [self updateStatusForisConnect:YES];
    [self closeConnect];//容错
    
    _configure.status                         = KSWebSocketStatusConnecting;
    NSMutableURLRequest *request              = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_configure.urlString]];
    if(_isAuthor){
        [request setValue:[NSString stringWithFormat:@"Bearer %@",self.configure.authorToken] forHTTPHeaderField:@"Authorization"];
    }
    SRWebSocket *socket                       = [[SRWebSocket alloc] initWithURLRequest:request];
    socket.delegate                           = self;
    NSOperationQueue *delegateQueue           = [[NSOperationQueue alloc] init];
    delegateQueue.maxConcurrentOperationCount = 2;
    socket.delegateOperationQueue             = delegateQueue;
    [socket open];
    self.webSocket                            = socket;
}

-(void)updateStatusForisConnect:(BOOL)isConnect {
    _configure.isConnect = isConnect;
}

/**
 主动关闭
 */
- (void)activeClose {
    [self updateStatusForisConnect:NO];
    [self close];
}

/**
 关闭并重置状态
 */
- (void)close {
    _configure.status = KSWebSocketStatusNone;
    [self closeConnect];
}
/**
 关闭连接
 */
- (void)closeConnect {
    [self removeHeartbeatTimer];
    [self closeWebSocket];
}

/**
 移除心跳定时器
 */
- (void)removeHeartbeatTimer {
    if (_heartbeatTimer) {
        [_heartbeatTimer invalidate];
        _heartbeatTimer = nil;
    }
}

/**
 销毁Socket
 */
- (void)closeWebSocket {
    if (_webSocket) {
        _webSocket.delegate = nil;
        [_webSocket close];
        _webSocket          = nil;
    }
}

/**
 开启心跳定时器
 */
-(void)startHeartbeat {
    KSWeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimer *timer          = [NSTimer scheduledTimerWithTimeInterval:self.configure.heartbeatTime target:self selector:@selector(sendHeartbeatMessage) userInfo:nil repeats:YES];
        weakSelf.heartbeatTimer = timer;
    });
    /*
    NSTimer *timer     = [NSTimer scheduledTimerWithTimeInterval:self.configure.heartbeatTime target:self selector:@selector(sendHeartbeatMessage) userInfo:nil repeats:YES];
    _heartbeatTimer    = timer;
     NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
    [runLoop run];*/
}

/**
 发送心跳消息
 */
- (void)sendHeartbeatMessage {
    [self.webSocket sendPing:nil];
    //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
    //NSMutableDictionary *message = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"heartbeatKey",@"heartbeatValue", nil];
    //[self sendMessage:message];
}

/**
 重连服务端
 */
- (void)resetConnectServer {
    if (_configure.resetCount >= _configure.maxResetCount) {//重连结束
        if ([_delegate respondsToSelector:@selector(socketReconnectionFailure:)]) {
            [_delegate socketReconnectionFailure:self];
        }
        return;
    }
    if (_configure.isReachable == NO) {
        return;
    }
    _configure.resetCount++;
    KSWeakSelf;
    /*
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.configure.reconnectTime * NSEC_PER_SEC)), queue, ^{
         [weakSelf startConnect];
    });
    */
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.configure.reconnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [weakSelf startConnect];
     });
    _configure.reconnectTime += self.configure.intervalTime;
}

- (void)sendMessage:(NSMutableDictionary *)message {
    if (_webSocket.readyState != SR_OPEN) {
        return;
    }
    NSData *data  = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];
    //NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self.webSocket send:data];
}

#pragma mark Receive Messages
/**
 收到服务端数据时调用
 Called when any message was received from a web socket.
 This method is suboptimal and might be deprecated in a future release.
 
 @param webSocket An instance of `SRWebSocket` that received a message.
 @param message   Received message. Either a `String` or `NSData`.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
    KSWeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(socket:didReceivedMessage:)]) {
            [weakSelf.delegate socket:weakSelf didReceivedMessage:message];
        }
    });
}

/**
 Called when a frame was received from a web socket.
 
 @param webSocket An instance of `SRWebSocket` that received a message.
 @param string    Received text in a form of UTF-8 `String`.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string {
    //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
}

/**
 Called when a frame was received from a web socket.
 
 @param webSocket An instance of `SRWebSocket` that received a message.
 @param data      Received data in a form of `NSData`.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithData:(NSData *)data {
     //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
}

#pragma mark Status & Connection

/**
 连接服务端成功时调用
 Called when a given web socket was open and authenticated.
 
 @param webSocket An instance of `SRWebSocket` that was open.
 */
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
    _configure.status = KSWebSocketStatusConnected;
    [self defaultValues];
    [self startHeartbeat];
    
    KSWeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(socketDidOpen:)]) {
            [weakSelf.delegate socketDidOpen:weakSelf];
        }
    });
}

/**
 出现错误/连接失败时调用
 Called when a given web socket encountered an error.
 
 @param webSocket An instance of `SRWebSocket` that failed with an error.
 @param error     An instance of `NSError`.
 */
- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
    _configure.status = KSWebSocketStatusConnectFail;
    
    [self close];
    if (_configure.isAutoConnect) {
        [self resetConnectServer];
    }
    
    KSWeakSelf;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([weakSelf.delegate respondsToSelector:@selector(socketDidFail:)]) {
            [weakSelf.delegate socketDidFail:weakSelf];
        }
    });
}

/**
 close时调用[主动close不会调用]
 Called when a given web socket was closed.
 
 @param webSocket An instance of `SRWebSocket` that was closed.
 @param code      Code reported by the server.
 @param reason    Reason in a form of a String that was reported by the server or `nil`.
 @param wasClean  Boolean value indicating whether a socket was closed in a clean state.
 */
- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
    //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
    _configure.status = KSWebSocketStatusConnectFail;
    
    [self close];
    if (_configure.isAutoConnect) {
        [self resetConnectServer];
    }
    
    if ([self.delegate respondsToSelector:@selector(socketDidClose:)]) {
        KSWeakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.delegate socketDidClose:weakSelf];
        });
    }
}

/**
 Called when a pong data was received in response to ping.
 
 @param webSocket An instance of `SRWebSocket` that received a pong frame.
 @param pongData  Payload that was received or `nil` if there was no payload.
 */
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(nullable NSData *)pongData {
     //NSLog(@"%s:%@",__FUNCTION__,[NSThread currentThread]);
}

-(KSWebSocketConfigure *)configure {
    if (_configure == nil) {
        _configure = [[KSWebSocketConfigure alloc] init];
    }
    return _configure;
}

@end
