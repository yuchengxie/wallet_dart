#import "AppDelegate.h"
#import <Flutter/Flutter.h>
#import "GeneratedPluginRegistrant.h"
#import "NZIKey.h"
#import "NZSIMSDK.h"

@interface AppDelegate()<NZSIMSDKDelegate>{
    NZSIMSDK *shareSdk;
    NZIKey *ikey;
}
@end
NSString* const CMD_PUB_ADDR=@"80220200020000";
NSString* const CMD_PUB_KEY=@"8022000000";
NSString* const CMD_PUB_KEY_HASH=@"8022010000";
//const int BLUE_CONNCTED = 1;
//const int BLUE_DISCONNECTED = 0;
//const int BLUE_INIT = -1;
//NSString * BLUENOTCONNCTED=@"蓝牙未连接,请先连接蓝牙";
//NSString * BLUENOTCONNCTED=@"-1";
//NSString * BLUECONNECTEDSUCCESS=@"蓝牙连接成功";
NSString * BLUECONNECTED=@"1";
//NSString * BLUEDISCONNECTED=@"蓝牙断开";
NSString * BLUEDISCONNECTED=@"0";

@implementation AppDelegate {
    FlutterEventSink _eventSink;
    FlutterViewController* controller;
    NSString* blueState;
    NSString * pubAddr;
    NSString * pubKey;
    NSString * pubHash;
}

- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
//    blueState = @"";
    controller =
    (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* bluetootheChannel = [FlutterMethodChannel
                                               methodChannelWithName:@"hzf.bluetooth"
                                               binaryMessenger:controller];
    FlutterEventChannel *blueStateChnnel=[FlutterEventChannel eventChannelWithName:@"hzf.bluetoothState" binaryMessenger:controller];
    [blueStateChnnel setStreamHandler:self];
    
    __weak typeof(self) weakSelf = self;
    
    shareSdk=[NZSIMSDK shareSdk];
    shareSdk.sim_delegate=self;
    ikey=[[NZIKey alloc]init];
    
    [bluetootheChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                              FlutterResult result) {
        NSLog(@">>> method=%@ arguments = %@", call.method, call.arguments);
        if([@"connectBlueTooth" isEqualToString:call.method]){
            NSString *bleName=call.arguments[0];
            NSString *pinCode=call.arguments[1];
            [shareSdk ConnectWithBleName:bleName andBleAuthCode:pinCode];
        }else if([@"disConnectBlueTooth" isEqualToString:call.method]){
            [weakSelf disConnectBlueTooth];
        }else if([@"transmit" isEqualToString:call.method]){
            NSString * sendStr=call.arguments[0];
            NSString * res=[weakSelf transmit:sendStr];
            result(res);
        }else if ([@"selectApp" isEqualToString:call.method]){
            NSString * appSelectID=call.arguments[0];
            NSString * resSelect =[weakSelf selectApp:appSelectID];
            result(resSelect);
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (FlutterError*)onListenWithArguments:(id)arguments
                             eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [self sendBlueToothConnectStateEvent];
    return nil;
}

- (void)sendBlueToothConnectStateEvent {
    if (!_eventSink) return;
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         blueState,@"state",
                         pubAddr, @"pubAddr",
                         pubKey, @"pubKey",
                         pubHash,@"pubHash", nil ];
    _eventSink(dic);
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

#pragma mark -bluetooth
-(void)disConnectBlueTooth{
    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [shareSdk DisConnectBLE];
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
}

-(Boolean)isBlueToothConnected{
    if(blueState==BLUECONNECTED) return true;
    return false;
}

//接口测试返回 其他代表失败//0代表成功
-(NSString*)selectApp:(NSString *) appSelectID{
    NSLog(@"appSelectID: %@",appSelectID);
    if(![self isBlueToothConnected]) return BLUEDISCONNECTED;
    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
    __block NSString* res=@"";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int code = [ikey selectApplet:appSelectID];
        res = code ==0?@"1":@"0";
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
    return res;
}

-(NSString*)transmit:(NSString *)sendStr{
    if(![self isBlueToothConnected]) return BLUEDISCONNECTED;
    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
    __block NSString* res=@"";
    NSData * d=[self convertHexStrToData:sendStr];
    NSLog(@"发送指令: %@",d);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *r=[shareSdk SendSynchronized:d];
        res=[self convertDataToHexStr:r];
        if(res.length>4 && [[res substringFromIndex:res.length-4] isEqualToString:@"9000"]){
            res=[res substringToIndex:res.length-4];
        }
        NSLog(@"接收消息: %@",res);
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
    return res;
}

#pragma mark - NZBLESDK delegate
-(void)didConnectSuc{
    dispatch_async(dispatch_get_main_queue(), ^{
        blueState=BLUECONNECTED;
        pubAddr=[self transmit:CMD_PUB_ADDR];
        pubKey=[self transmit:CMD_PUB_KEY];
        pubHash=[self transmit:CMD_PUB_KEY_HASH];
        [self sendBlueToothConnectStateEvent];
    });
}

-(void)didDisConnect {
    dispatch_async(dispatch_get_main_queue(), ^{
        blueState=BLUEDISCONNECTED;
        pubAddr=@"";
        pubKey=@"";
        pubHash=@"";
        [self sendBlueToothConnectStateEvent];
    });
}

#pragma mark - hex util
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

@end

