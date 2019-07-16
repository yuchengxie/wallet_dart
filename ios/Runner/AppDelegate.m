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

const int BLUE_CONNCTED = 1;
const int BLUE_DISCONNECTED = 0;
const int BLUE_INIT = -1;
//NSString * BLUENOTCONNCTED=@"蓝牙未连接,请先连接蓝牙";
NSString * BLUENOTCONNCTED=@"-1";
//NSString * BLUECONNECTEDSUCCESS=@"蓝牙连接成功";
NSString * BLUECONNECTEDSUCCESS=@"1";
//NSString * BLUEDISCONNECTED=@"蓝牙断开";
NSString * BLUEDISCONNECTED=@"0";

@implementation AppDelegate {
    FlutterEventSink _eventSink;
    FlutterViewController* controller;
    int _blueToothState;
}

- (BOOL)application:(UIApplication*)application
didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    [GeneratedPluginRegistrant registerWithRegistry:self];
    _blueToothState = BLUE_INIT;
    controller =
    (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* bluetootheChannel = [FlutterMethodChannel
                                               methodChannelWithName:@"hzf.bluetooth"
                                               binaryMessenger:controller];
    __weak typeof(self) weakSelf = self;
    
    [bluetootheChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                              FlutterResult result) {
        NSLog(@">>> method=%@ arguments = %@", call.method, call.arguments);
        if([@"connectBlueTooth" isEqualToString:call.method]){
            NSString *bleName=call.arguments[0];
            NSString *pinCode=call.arguments[1];
            [weakSelf connectBlueTooth:bleName :pinCode];
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
        
        
//        else if ([@"selectApp" isEqualToString:call.method]){
//            NSString * appSelectID=call.arguments[0];
//            NSString * resSelect =[weakSelf selectApp:appSelectID];
//            result(resSelect);
//        }else if ([@"verifPIN" isEqualToString:call.method]){
//            NSString * strCode=call.arguments[0];
//            NSString * resVerify= [weakSelf verifPIN:strCode];
//            result(resVerify);
//        }else if ([@"sign" isEqualToString:call.method]){
//            NSString * signCmdHexStr=call.arguments[0];
//            NSString * resSign=[weakSelf sign:signCmdHexStr];
//            result(resSign);
//        }
    }];
    
    FlutterEventChannel *blueStateChnnel=[FlutterEventChannel eventChannelWithName:@"hzf.bluetoothState" binaryMessenger:controller];
    [blueStateChnnel setStreamHandler:self];
    shareSdk=[NZSIMSDK shareSdk];
    shareSdk.sim_delegate=self;
    ikey=[[NZIKey alloc]init];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (FlutterError*)onListenWithArguments:(id)arguments
                             eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    [self sendBlueToothConnectStateEvent];
    return nil;
}

- (void)sendBlueToothConnectStateEvent {
    if (!_eventSink || _blueToothState==BLUE_INIT) return;
    NSString * strState=_blueToothState == BLUE_CONNCTED? BLUECONNECTEDSUCCESS:BLUEDISCONNECTED;
    _eventSink(strState);
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _eventSink = nil;
    return nil;
}

#pragma mark -bluetooth
- (NSString*)connectBlueTooth: (NSString*)bleName :(NSString*) pinCode {
    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
    __block NSString* res;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int code=[shareSdk ConnectWithBleName:bleName andBleAuthCode:pinCode];
        res = code == 0? @"success": @"failed";
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
    return res;
}

-(void)disConnectBlueTooth{
    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [shareSdk DisConnectBLE];
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
}

-(Boolean)isBlueToothConnected{
    if(_blueToothState==BLUE_CONNCTED) return true;
    return false;
}

//接口测试返回 其他代表失败//0代表成功
-(NSString*)selectApp:(NSString *) appSelectID{
    NSLog(@"appSelectID: %@",appSelectID);
    if(![self isBlueToothConnected]) return BLUENOTCONNCTED;
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

//-(NSString*)verifPIN:(NSString *)codeStr{
//    if(![self isBlueToothConnected]) return BLUENOTCONNCTED;
//    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
//    __block NSString* res=@"";
//    NSData * d=[self convertHexStrToData:codeStr];
//    NSLog(@"d: %@",d);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *r=[shareSdk SendSynchronized:d];
//        res=[self convertDataToHexStr:r];
//        dispatch_semaphore_signal(sema);
//    });
//    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
//    return res;
//}
//
//-(NSString *)sign:(NSString*)signCmdHexStr{
//    if(![self isBlueToothConnected]) return BLUENOTCONNCTED;
//    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
//    __block NSString* res=@"";
//    NSData * d = [self convertHexStrToData:signCmdHexStr];
//    
//    NSLog(@"d: %@",d);
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *r=[shareSdk SendSynchronized:d];
//        res=[self convertDataToHexStr:r];
//        dispatch_semaphore_signal(sema);
//    });
//    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
//    return res;
//}

-(NSString*)transmit:(NSString *)sendStr{
    if(![self isBlueToothConnected]) return BLUENOTCONNCTED;
    dispatch_semaphore_t sema =dispatch_semaphore_create(0);
    __block NSString* res=@"";
    NSData * d=[self convertHexStrToData:sendStr];
    NSLog(@"发送指令: %@",d);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *r=[shareSdk SendSynchronized:d];
        res=[self convertDataToHexStr:r];
        NSLog(@"接收消息: %@",res);
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema,DISPATCH_TIME_FOREVER);
    return res;
}

#pragma mark - NZBLESDK delegate
-(void)didConnectSuc{
    dispatch_async(dispatch_get_main_queue(), ^{
        _blueToothState=BLUE_CONNCTED;
        [self sendBlueToothConnectStateEvent];
    });
}

-(void)didDisConnect {
    NSLog(@"bluetooth disconnect!");
    dispatch_async(dispatch_get_main_queue(), ^{
        _blueToothState=BLUE_DISCONNECTED;
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

