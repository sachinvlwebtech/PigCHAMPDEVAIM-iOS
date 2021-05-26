/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Provides an interface for communication with an EASession. Also the delegate for the EASession input and output stream objects.
 */

@import Foundation;
@import ExternalAccessory;

extern NSString *EADSessionDataReceivedNotification;
extern NSString *EADSessionDataReceivedOnSearchNotification;
extern NSString *EADSessionDataReceivedOnSowDetailsReportNotification;
extern NSString *EADSessionDataReceivedOnReportsNotification;

// NOTE: EADSessionController is not threadsafe, calling methods from different threads will lead to unpredictable results
@interface EADSessionController : NSObject <EAAccessoryDelegate, NSStreamDelegate>

+ (EADSessionController *)sharedController;
@property (nonatomic, readonly) EAAccessory *accessory;

- (void)setupControllerForAccessory:(EAAccessory *)accessory withProtocolString:(NSString *)protocolString;
- (BOOL)openSession;
- (NSUInteger)readBytesAvailable;
- (NSData *)readData:(NSUInteger)bytesToRead;
- (void)closeSession;

@end
