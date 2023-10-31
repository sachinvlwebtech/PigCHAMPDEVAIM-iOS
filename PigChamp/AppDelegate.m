//
//  AppDelegate.m
//  PigChamp
//
//  Created by Venturelabour on 20/10/15.
//  Copyright © 2015 Venturelabour. All rights reserved.
//

#import "AppDelegate.h"
#import <Google/Analytics.h>
#import "CoreDataHandler.h"
#import "EADSessionController.h"

@interface AppDelegate (){
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.delegateTimeoutValue = 0;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"baseURL"] != nil)
    {
        NSString * strURL = [defaults valueForKey:@"baseURL"];
        [defaults setObject:strURL forKey:@"baseURL"];
        [defaults synchronize];
    }
    else
    {
        [defaults setObject:API_BASE_URL forKey:@"baseURL"];
    }
    
    [defaults removeObjectForKey:@"login_state"];
    [defaults synchronize];
    //***added some delay for Splashscreen Bug-27339 By M.
    sleep(4.0);
    // Override point for customization after application launch.
    //[[UINavigationBar appearance] setBarTintColor:[UIColor redColor]];
    //***code changed below for the bug raised by Matrin for bc color flickr By M.
   // self.window.backgroundColor = [UIColor blackColor];
    self.window.backgroundColor = [UIColor colorWithRed: 0.25 green: 0.25 blue: 0.25 alpha: 1.00];
    //self.window.backgroundColor = [UIColor colorWithRed: 0.64 green: 0.25 blue: 0.22 alpha: 1.00];//A44139
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    //
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    MenuViewController *leftMenu = (MenuViewController*)[mainStoryboard
                                                         instantiateViewControllerWithIdentifier:@"MenuViewController"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    // Creating a custom bar button for right menu
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"Menu"] forState:UIControlStateNormal];
    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleRightMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].rightBarButtonItem = rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    
    //
    
    //    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:.5]];
    //    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    //    [[UINavigationBar appearance] setTranslucent:NO];
    //     [application setStatusBarHidden:NO];
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //[self.navigationController.navigationBar setTranslucent:NO];
    // Optional: configure GAI options.
    
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    //
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if ([[pref valueForKey:@"selectedLanguage"] length]==0) {
        [pref setValue:@"English (US)" forKey:@"selectedLanguage"];
    }
    [pref setValue:@"0" forKey:@"reload"];
    [pref setValue:@"1" forKey:@"isBarcode"];
    [pref setValue:@"0" forKey:@"reloadWeb"];
    [pref setValue:@"0" forKey:@"isRFID"];
    [pref synchronize];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Check if the user has returned from the Settings app
     /* if (self.viewControllerBeforeSettings) {
          // You can now access self.viewControllerBeforeSettings and take appropriate action.
          // For example, you can push it onto the navigation stack or present it.
          // Reset the stored view controller.
         // self.viewControllerBeforeSettings = nil;
          NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
          if ([[userDefault valueForKey:@"login_state"]  isEqual: @"logged_in"]){

             // [self.window.rootViewController presentViewController:self animated:YES completion:nil];
              NSLog(@"I am in stilll logged in just handle here redirection");
         } else {
             // User is not authenticated, show the login screen.
             // Example:
             // [self.window.rootViewController presentViewController:ViewController animated:YES completion:nil];
         }
      }*/
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    //For closing sess
    EADSessionController *sessionController = [EADSessionController  sharedController];
    [sessionController closeSession];
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:@"login_state"]; //Code added by priyanka 2nd july//
    [userDefault synchronize];
    
    [self saveContext];
    
}
/*- (void)viewControllerWillRedirectToSettings:(UIViewController *)viewController {
    // Store the current view controller
    self.viewControllerBeforeSettings = viewController;
}*/
#pragma mark - Core Data stack
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Venturelabour.PigChamp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PigChamp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES,
                              NSInferMappingModelAutomaticallyOption:@YES};
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PigChamp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

//Code change by Priyanka 28th June 18 for Automatically signing out after 30 min of inactivity//
- (void)resetIdleTimer
{
    if (!idleTimer) {
        idleTimer = [NSTimer scheduledTimerWithTimeInterval:self.delegateTimeoutValue target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:idleTimer forMode:NSDefaultRunLoopMode];
    } else {
        if (fabs([idleTimer.fireDate timeIntervalSinceNow]) < self.delegateTimeoutValue - 1.) {
            idleTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.delegateTimeoutValue];
        }
    }
}

- (void)idleTimerExceeded
{
    idleTimer = nil;
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault valueForKey:@"login_state"])
    {
//                UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
//                                                                                           message:[self getTranslatedTextForString:@"Your session has been expired. Please login again."]
//                                                                                    preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction* ok = [UIAlertAction
//                                     actionWithTitle:[self getTranslatedTextForString:@"Ok"]
//                                     style:UIAlertActionStyleDefault
//                                     handler:^(UIAlertAction * action) {
//
//                                         [userDefault removeObjectForKey:@"login_state"]; //Code added by priyanka 2nd july//
//                                         [userDefault synchronize];
//
//                                         [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
//
//                                         [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
//                                         [myAlertController dismissViewControllerAnimated:YES completion:nil];
//                                     }];
//
//                [myAlertController addAction: ok];
//                [self.window.rootViewController presentViewController:myAlertController animated:YES completion:nil];
        
        
        UIWindow* topWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        topWindow.rootViewController = [UIViewController new];
        topWindow.windowLevel = UIWindowLevelAlert + 1;

        UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"PigCHAMP"
                                                                                   message:[self getTranslatedTextForString:@"Your session has been expired. Please login again."]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 7, 40, 40)];
        logoImageView.image = [UIImage imageNamed:@"menuLogo.jpg"];
        UIView *controllerView = myAlertController.view;
        [controllerView addSubview:logoImageView];
        [controllerView bringSubviewToFront:logoImageView];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:[self getTranslatedTextForString:@"Ok"]
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {

                                   [[SlideNavigationController sharedInstance] closeMenuWithCompletion:nil];
                                    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];

                                 [userDefault removeObjectForKey:@"login_state"]; //Code added by priyanka 2nd july//
                                 [userDefault synchronize];
                                 
                                 //Call logout API//
                                 [ServerManager sendRequestForLogout:^(NSString *responseData) {
                                     NSLog(@"Logout response %@",responseData);
                                 } onFailure:^(NSString *responseData, NSError *error) {
                                 }];
  
                                 [[SlideNavigationController sharedInstance]popToRootViewControllerAnimated:YES];
                                 [myAlertController dismissViewControllerAnimated:YES completion:nil];
                             }];

        [myAlertController addAction: ok];
        //   [self.window.rootViewController presentViewController:myAlertController animated:YES completion:nil];

        [topWindow makeKeyAndVisible];
        [topWindow.rootViewController presentViewController:myAlertController animated:YES completion:nil];
    }
    
    [self resetIdleTimer];
}

- (UIResponder *)nextResponder
{    
    [self resetIdleTimer];
    return [super nextResponder];
}

-(NSString*)getTranslatedTextForString:(NSString*)Checkstring
{
    NSString *strSearchTitle;
    NSArray* resultArray1 = [[CoreDataHandler sharedHandler] getTranslatedText:[[NSMutableArray alloc] initWithObjects:Checkstring,nil]];
    NSMutableDictionary *dictMenu = [[NSMutableDictionary alloc]init];
    if (resultArray1.count!=0){
        for (int i=0; i<resultArray1.count; i++){
            [dictMenu setObject:[[resultArray1 objectAtIndex:i]valueForKey:@"translatedText"] forKey:[[[resultArray1 objectAtIndex:i]valueForKey:@"englishText"] uppercaseString]];
        }
        for (int i=0; i<1; i++) {
            if (i==0)
            {
                if ([dictMenu objectForKey:[Checkstring uppercaseString]] && ![[dictMenu objectForKey:[Checkstring uppercaseString]] isKindOfClass:[NSNull class]]) {
                    if ([[dictMenu objectForKey:[Checkstring uppercaseString]] length]>0) {
                        strSearchTitle = [dictMenu objectForKey:[Checkstring uppercaseString]]?[dictMenu objectForKey:[Checkstring uppercaseString]]:@"";
                    }
                    else
                    {
                        strSearchTitle = Checkstring;
                    }
                }
            }
        }
    }
    else
    {
        strSearchTitle = Checkstring;
    }
    return strSearchTitle;
}

@end
