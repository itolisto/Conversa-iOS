//
//  AppDelegate.m
//  Conversa
//
//  Created by Edgar Gomez on 12/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "AppDelegate.h"

#import "Log.h"
#import "Branch.h"
#import "Account.h"
#import "Message.h"
#import "Customer.h"
#import "Business.h"
#import "Constants.h"
#import "Appirater.h"
#import "YapContact.h"
#import "SettingsKeys.h"
#import "PopularSearch.h"
#import "ParseValidation.h"
#import "DatabaseManager.h"
#import "BusinessCategory.h"
#import "OneSignalService.h"
#import "CustomAblyRealtime.h"
@import Parse;
@import Fabric;
@import ParseUI;
@import Buglife;
@import GoogleMaps;
@import Crashlytics;

@interface AppDelegate ()
    
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[Appirater setAppId:@"464200063"];
    
    // Set Google Maps
    [GMSServices provideAPIKey:@"AIzaSyDnp-8x1YyMNjhmi4R7O3foOcdkfMa4cNs"];
    
    // Set Fabric
    [Fabric with:@[[Answers class], [Crashlytics class]]];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    // Register subclassing for using as Parse objects
    [Account registerSubclass];
    [Message registerSubclass];
    [Business registerSubclass];
    [Customer registerSubclass];
    [PopularSearch registerSubclass];
    [BusinessCategory registerSubclass];
    
    // Initialize Parse.
    [Parse setApplicationId:@"39H1RFC1jalMV3cv8pmDGPRh93Bga1mB4dyxbLwl"
                  clientKey:@"YC3vORNGt6I4f8yEsO6TyGF97XbmitofOrrS5PCC"];
    
    // Initialize Reachability
    // Reachability *reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Start Monitoring
    // [reachability startNotifier];
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"Home directory: %@",NSHomeDirectory());
#endif
    
    if (![DatabaseManager existsYapDatabase]) {
        /*
         * First Launch
         * Create password and save to keychain
         */
        NSString *newPassword = @"123456789";//[PasswordGenerator passwordWithLength:DefaultPasswordLength];
        NSError *error = nil;
        [[DatabaseManager sharedInstance] setDatabasePassphrase:newPassword remember:YES error:&error];
        
        if (error) {
            DDLogError(@"Password Error: %@",error);
        }
        
        // Default settings
        [SettingsKeys setTutorialShownSetting:NO];
    }
        
    [[DatabaseManager sharedInstance] setupDatabaseWithName:kYapDatabaseName];
    
    // Define controller to take action
    UIViewController *rootViewController = nil;
    rootViewController = [self defaultNavigationController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootViewController;
    // Make the receiver the main window and displays it in front of other windows
    [self.window makeKeyAndVisible];
    // The number to display as the app’s icon badge.
    application.applicationIconBadgeNumber = 0;

    [[Buglife sharedBuglife] startWithAPIKey:@"AtLX2qYcNMTEhESEpKO8egtt"];
    [Buglife sharedBuglife].invocationOptions = LIFEInvocationOptionsShake;

    // Set Appirater settings
    [Appirater setOpenInAppStore:NO];
    [Appirater appLaunched:YES];
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            // params are the deep linked params associated with the link that the user clicked -> was re-directed to this app
            // params will be empty if no data found
            // ... insert custom logic here ...
            // Change view controller to go
            NSLog(@"deep link data: %@", params.description);
        }
    }];
    
    [[OneSignalService sharedInstance] launchWithOptions:launchOptions];
    
    return YES;
}

- (UIViewController*)defaultNavigationController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    Account *account = [Account currentUser];
    BOOL hasAccount = NO;
    
    if (account) {
        hasAccount = YES;
        [SettingsKeys setNotificationsCheck:NO];
    }
    
    /**
     * Proceso para nombrar controladores en Storyboard
     * 1. Seleccionar Storyboard
     * 2. Seleccionar Scene deseada
     * 3. Abrir Identity inspector
     * 4. Propiedad Storyboard ID se escribe nombre
     */
    if (hasAccount) {
        return [storyboard instantiateViewControllerWithIdentifier:@"HomeView"];
    } else {
        if([SettingsKeys getTutorialShownSetting]) {
            return [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        } else {
            return [storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[EDQueue sharedInstance] stop];
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
    [[EDQueue sharedInstance] setDelegate:self];
    [[EDQueue sharedInstance] start];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%s with error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark - Branch methods -

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // pass the url to the handle deep link call
    [[Branch getInstance] handleDeepLink:url];
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    return handledByBranch;
}

#pragma mark - EDQueueDelegate method -

- (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }

    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }

    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)queue:(EDQueue *)queue processJob:(NSDictionary *)job completion:(void (^)(EDQueueResult))block
{
    @try {
        if ([[job objectForKey:@"task"] isEqualToString:@"getCustomerData"]) {
            NSError *error;
            NSString *objectId = [PFCloud callFunction:@"getCustomerId" withParameters:@{} error:&error];

            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ParseValidation validateError:error controller:[self topViewController]];
                });
                block(EDQueueResultCritical);
            } else {
                [SettingsKeys setCustomerId:objectId];
                block(EDQueueResultSuccess);
            }
        } else if ([[job objectForKey:@"task"] isEqualToString:@"favorite"]) {
            NSDictionary *data = [job objectForKey:@"data"];

            if (data) {
                if ([data objectForKey:@"favorite"]) {
                    [PFCloud callFunctionInBackground:@"favorite"
                                       withParameters:@{@"business": [data objectForKey:@"business"],
                                                        @"favorite": @YES}
                                                block:^(NSNumber * _Nullable object, NSError * _Nullable error)
                    {
                        if (error) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [ParseValidation validateError:error controller:[self topViewController]];
                            });
                            block(EDQueueResultCritical);
                        } else {
                            block(EDQueueResultSuccess);
                        }
                    }];
                } else {
                    [PFCloud callFunctionInBackground:@"favorite"
                                       withParameters:@{@"business": [data objectForKey:@"business"]}
                                                block:^(NSNumber * _Nullable object, NSError * _Nullable error)
                     {
                         if (error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [ParseValidation validateError:error controller:[self topViewController]];
                             });
                             block(EDQueueResultCritical);
                         } else {
                             block(EDQueueResultSuccess);
                         }
                     }];
                }
            }
        } else {
            block(EDQueueResultCritical);
        }
    }
    @catch (NSException *exception) {
        block(EDQueueResultCritical);
    }
}

@end
