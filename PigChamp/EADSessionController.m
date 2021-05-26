/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Provides an interface for communication with an EASession. Also the delegate for the EASession input and output stream objects.
 */

#import "EADSessionController.h"
@interface EADSessionController ()

@property (nonatomic, strong) EASession *session;
@property (nonatomic, strong) NSMutableData *readData;
@property (nonatomic, strong) NSArray *supportedProtocolsStrings;

@end

NSString *EADSessionDataReceivedNotification = @"EADSessionDataReceivedNotification";
NSString *EADSessionDataReceivedOnSearchNotification = @"EADSessionDataReceivedOnSearchNotification";
NSString *EADSessionDataReceivedOnSowDetailsReportNotification = @"EADSessionDataReceivedOnSowDetailsReportNotification";
NSString *EADSessionDataReceivedOnReportsNotification = @"EADSessionDataReceivedOnReportsNotification";


@implementation EADSessionController

+ (EADSessionController *)sharedController
{
    static EADSessionController *sessionController = nil;
    if (sessionController == nil) {
        sessionController = [[EADSessionController alloc] init];
    }
    return sessionController;
}

- (BOOL)openSession
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    self.supportedProtocolsStrings = [mainBundle objectForInfoDictionaryKey:@"UISupportedExternalAccessoryProtocols"];

    NSArray *protocolStrings = [_accessory protocolStrings];
    for(NSString *protocolString in protocolStrings)
    {
            if (_accessory)
            {
                for ( NSString *item in self.supportedProtocolsStrings)
                {
                    if ([item compare: protocolString] == NSOrderedSame)
                    {
                        self.session = [[EASession alloc] initWithAccessory:_accessory
                                                                forProtocol:protocolString];
                        //It creates a session for the designated protocol and configures the input and output streams of the session.
                        if (self.session)
                        {
                            [[self.session inputStream] setDelegate:self];
                            [[self.session inputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                                                  forMode:NSDefaultRunLoopMode];
                            [[self.session inputStream] open]; //Here
                            [[self.session outputStream] setDelegate:self];
                            [[self.session outputStream] scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                                                   forMode:NSDefaultRunLoopMode];
                            [[self.session outputStream] open];
                        }
                    }
                }
            }
    }
    return (_session != nil);
}

- (void)closeSession
{
    [[_session inputStream] close];
    [[_session inputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session inputStream] setDelegate:nil];
    [[_session outputStream] close];
    [[_session outputStream] removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [[_session outputStream] setDelegate:nil];
    
    _session = nil;
    _readData = nil;
}

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString
{
    NSLog(@"setupControllerForAccessory entered protocolString is %@", protocolString);
    _accessory = accessory;
   // _protocolString = [protocolString copy];
}

//- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
//{
//    NSMutableData *_data;
//    NSMutableString *fullDataString = [[NSMutableString alloc] init];
//
//    switch (eventCode)
//    {
//        case NSStreamEventNone:
//            NSLog(@"NSStreamEventNone");
//            break;
//
//        case NSStreamEventOpenCompleted:
//            NSLog(@"NSStreamEventOpenCompleted");
//            break;
//
//        case NSStreamEventHasBytesAvailable:
//            NSLog(@"NSStreamEventHasBytesAvailable");
//
//            //Here we read data from input stream when command written on the hardware device.
//            @try {
//                if(!_data) {
//                    _data = [NSMutableData data];
//                }
//                uint8_t buf[1024];
//                unsigned int len = 0;
//                len = [(NSInputStream *)aStream read:buf maxLength:1024];
//                if(len)
//                {
//                    [_data appendBytes:(const void *)buf length:len];
//                    NSLog(@"%@",_data);
//                    fullDataString = [[NSMutableString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
//                    NSLog(@"%@",fullDataString);
//
//                    [self sendData:fullDataString];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedNotification object:self userInfo:nil];
//                }
//                else
//                {
//                    NSLog(@"no buffer!");
//                }
//            }
//            @catch (NSException *exception) {
//                NSLog(@"%@",[exception description]);
//            }
//            @finally {
//
//            }
//            break;
//
//        case NSStreamEventHasSpaceAvailable:
//            NSLog(@"NSStreamEventHasSpaceAvailable");
//            break;
//
//        case NSStreamEventErrorOccurred: // Do something for Error event
//            break;
//
//        case NSStreamEventEndEncountered: // Do something for End event
//            break;
//
//        default:
//            NSLog(@"default");
//            break;
//    }
//}

// high level read method
- (NSData *)readData:(NSUInteger)bytesToRead
{
    NSData *data = nil;
    if ([_readData length] >= bytesToRead) {
        NSRange range = NSMakeRange(0, bytesToRead);
        data = [_readData subdataWithRange:range];
        [_readData replaceBytesInRange:range withBytes:NULL length:0];
    }
    return data;
}

// get number of bytes read into local buffer
- (NSUInteger)readBytesAvailable
{
    return [_readData length];
}

// low level read method - read data while there is data and space available in the input buffer
- (void)_readData {
#define EAD_INPUT_BUFFER_SIZE 128
    uint8_t buf[EAD_INPUT_BUFFER_SIZE];
    while ([[_session inputStream] hasBytesAvailable])
    {
        NSInteger bytesRead = [[_session inputStream] read:buf maxLength:EAD_INPUT_BUFFER_SIZE];
        if (_readData == nil) {
            _readData = [[NSMutableData alloc] init];
        }
        [_readData appendBytes:(void *)buf length:bytesRead];
        NSLog(@"read %ld bytes from input stream", (long)bytesRead);
    }

    NSUserDefaults *pref =[NSUserDefaults standardUserDefaults];
    NSLog(@"current page %@", [pref valueForKey:@"CurrentPage"]);

    if ([[pref valueForKey:@"CurrentPage"] isEqualToString:@"OnDataEntryScreen"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedNotification object:self userInfo:nil];
    }
    else if ([[pref valueForKey:@"CurrentPage"] isEqualToString:@"OnSearchScreen"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedOnSearchNotification object:self userInfo:nil];
    }
    else if ([[pref valueForKey:@"CurrentPage"] isEqualToString:@"OnSowDetailsReportScreen"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedOnSowDetailsReportNotification object:self userInfo:nil];
    }
    else if ([[pref valueForKey:@"CurrentPage"] isEqualToString:@"OnReportsScreen"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:EADSessionDataReceivedOnReportsNotification object:self userInfo:nil];
    }
}

//asynchronous NSStream handleEvent method
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode) {
        case NSStreamEventNone:
            break;
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self _readData];
            break;
        case NSStreamEventHasSpaceAvailable:
          //  [self _writeData];
            break;
        case NSStreamEventErrorOccurred:
            break;
        case NSStreamEventEndEncountered:
            break;
        default:
            break;
    }
}
@end
