//
//  ServerManager.h
//  QuicHotels
//
//  Created by Riyaz Lakhani on 27/11/14.
//  Copyright (c) 2014 Quicsolv Technologies Pvt. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerManager : NSObject<NSURLConnectionDataDelegate,NSXMLParserDelegate>
{
    NSMutableData *webData;
    NSXMLParser *xmlParser;
    NSString *currentElement;

}

+ (void)sendRequestForLanguageList:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequestForLogin:(NSString*)userName password:(NSString*)password accountNumber:(NSString*)accNumber language:(NSString*)language  onSucess:(void (^)(NSString *responseData))success onFailure:(void (^) (NSMutableDictionary *responseData, NSError *error))failure;
+ (void)sendRequestForGetmasterData:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequestForSysLookup:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequestForFarmSelection:(NSString*)siteId onSucess:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequestForLogout:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequestEvent:(NSString*)url idOfServiceUrl:(NSData*)data methodType:(NSString*)methodType onSucess:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequest:(NSString*)url idOfServiceUrl:(NSInteger)idOfServiceUrl headers:(NSMutableDictionary*)headers methodType:(NSString*)methodType onSucess:(void (^)(NSString *responseData))success onFailure:(void (^) (NSMutableDictionary *responseData, NSError *error))failure;

+ (void)sendRequestForFarmsData:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
+ (void)sendRequestForUsersData:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
//Added below method for getting Server Version Number-V10 issue by M. 
+ (void)getServerVersionDetails:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;

+ (void)sendRequestForCheckVersion:(NSString*)platform onSucess:(void (^)(NSString *responseData))success onFailure:(void (^) (NSMutableDictionary *responseData, NSError *error))failure;
+ (void)sendRequestForTimeoutValue:(NSString*)platform onSucess:(void (^)(NSString *responseData))success onFailure:(void (^) (NSMutableDictionary *responseData, NSError *error))failure;


+ (void)sendRequestForUserParametersData:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;
//>>>>>trello

+ (void)getAllLanguageTranslation:(void (^)(NSString *responseData))success onFailure:(void (^) (NSString *responseData, NSError *error))failure;

@end
