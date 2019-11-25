//
//  KSWebSocketConfigure.m
//  ZeroShare
//
//  Created by saeipi on 2018/8/29.
//  Copyright © 2018年 saeipi. All rights reserved.
//

#import "KSWebSocketConfigure.h"

@implementation KSWebSocketConfigure

-(instancetype)init {
    if (self = [super init]) {
        self.maxResetCount = 100;
        self.heartbeatTime = 30;
        self.intervalTime = 2;
    }
    return self;
}

@end
