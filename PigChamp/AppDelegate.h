//
//  AppDelegate.h
//  PigChamp
//
//  Created by Venturelabour on 20/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "ServerManager.h"

//#define kTimeoutUserInteraction 60
//#define API_BASE_URL @"https://rdstest.pigchamp.com/"
#define API_BASE_URL @"https://dev-pc-mobile.farmsstaging.com/"

@interface AppDelegate : UIResponder <UIApplicationDelegate,NSStreamDelegate>
{
    NSTimer *idleTimer;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) int delegateTimeoutValue;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
