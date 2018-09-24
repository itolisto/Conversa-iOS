//
//  AppDelegate.m
//  Conversa
//
//  Created by Edgar Gomez on 12/10/15.
//  Copyright © 2015 Conversa. All rights reserved.
//

#import "AppDelegate.h"

#import "Log.h"
#import "Flurry.h"
#import "Branch.h"
#import "Account.h"
#import "Business.h"
#import "Constants.h"
#import "Appirater.h"
#import "YapContact.h"
#import "YapMessage.h"
#import "SettingsKeys.h"
#import "Conversa-Swift.h"
#import "ParseValidation.h"
#import "DatabaseManager.h"
#import "CustomAblyRealtime.h"
#import "NSFileManager+Conversa.h"
#import "NotificationPermissions.h"
#import "ConversationViewController.h"

#import <Fabric/Fabric.h>
#import <HockeySDK/HockeySDK.h>
#import <Taplytics/Taplytics.h>
#import <Crashlytics/Crashlytics.h>

@import Firebase;
@import GoogleMaps;

@interface AppDelegate ()
    
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDate *startDate = [NSDate date];

    //[Appirater setAppId:@"464200063"];

    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [UITabBar appearance].layer.borderWidth = 0.0f;
    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    [[UITabBar appearance] setShadowImage:[UIImage new]];

    // Set Google Maps
    [GMSServices provideAPIKey:@"AIzaSyDTnyTCdEcU1Tr1VA-_SqXgDsCPR3dWYTI"];

    FlurrySessionBuilder* builder = [[[[[FlurrySessionBuilder new]
                                        withLogLevel:FlurryLogLevelNone]
                                       withCrashReporting:YES]
                                      withSessionContinueSeconds:10]
                                     withAppVersion:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];

    [Flurry startSession:@"YZZTYPJ7FPZWXT2CJZVQ" withSessionBuilder:builder];

    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"6c4c622531124498b180d7faab50093f"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    [Taplytics startTaplyticsAPIKey:@"1a214e395c9db615a2cf2819a576bd9f17372ca5"];

    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs

    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];

    // Initialize Firebase
    [FIRApp configure];

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
    [[CustomAblyRealtime sharedInstance] initAbly];

    Branch *branch = [Branch getInstance];
    [branch disableCookieBasedMatching];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            Account *account = [Account currentUser];

            if (account == nil) {
                return;
            }

            if ([params objectForKey:BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] && [[params objectForKey:BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] boolValue] == true)
            {
                if ([[params objectForKey:BRANCH_INIT_KEY_CLICKED_BRANCH_LINK] boolValue] == YES)
                {
                    if ([params objectForKey:@"goConversa"])
                    {
                        NSMutableDictionary *branchInfo = [NSMutableDictionary dictionaryWithCapacity:4];
                        [branchInfo setObject:[params objectForKey:@"objectId"] forKey:@"objectId"];
                        [branchInfo setObject:[params objectForKey:@"name"] forKey:@"name"];
                        [branchInfo setObject:[params objectForKey:@"conversaId"] forKey:@"conversaId"];

                        if ([params objectForKey:@"avatar"]) {
                            [branchInfo setObject:[params objectForKey:@"avatar"] forKey:@"avatar"];
                        }
                        // Define controller to take action
                        __block YapContact *bs = nil;

                        [[DatabaseManager sharedInstance].newConnection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
                            bs = [transaction objectForKey:[branchInfo objectForKey:@"objectId"] inCollection:[YapContact collection]];
                        }];

                        // Get reference to the destination view controller
                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        ConversationViewController *destinationViewController = [storyboard instantiateViewControllerWithIdentifier:@"conversationViewController"];

                        // Pass any objects to the view controller here, like...
                        if (bs) {
                            [destinationViewController initWithBuddy:bs];
                        } else {
                            YapContact *business = [[YapContact alloc] initWithUniqueId:[branchInfo objectForKey:@"objectId"]];
                            business.displayName = [branchInfo objectForKey:@"name"];
                            business.conversaId = [branchInfo objectForKey:@"conversaid"];
                            [destinationViewController initWithBusiness:business
                                                          withAvatarUrl:[branchInfo objectForKey:@"avatar"]];
                        }

                        UIViewController *controller = [self topViewController];

                        if (controller) {
                            if ([controller isKindOfClass:[ConversationViewController class]]) {
                                // DO NOTHING
                            } else if ([controller isKindOfClass:[UITabBarController class]]) {
                                UITabBarController *tbcontroller = (UITabBarController*)controller;
                                UIViewController *scontroller = [tbcontroller selectedViewController];

                                if ([scontroller isKindOfClass:[UINavigationController class]]) {
                                    UINavigationController *navcontroller = (UINavigationController*)scontroller;

                                    if (navcontroller.isNavigationBarHidden) {
                                        navcontroller.navigationBarHidden = NO;
                                    }

                                    [navcontroller pushViewController:destinationViewController
                                                             animated:YES];
                                } else {
                                    // scontroller is a uiviewcontroller
                                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scontroller];

                                    [navController pushViewController:destinationViewController
                                                             animated:YES];
                                }
                            } else if ([controller isKindOfClass:[UINavigationController class]]) {
                                UINavigationController *navcontroller = (UINavigationController*)controller;
                                [navcontroller pushViewController:destinationViewController
                                                         animated:YES];
                            } else {
                                if (controller.navigationController) {
                                    [controller.navigationController pushViewController:destinationViewController
                                                                               animated:YES];
                                } else {
                                    // Create UINavigationController if not exists
                                    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

                                    [navController pushViewController:destinationViewController
                                                             animated:YES];
                                }
                            }
                        }
                    }
                }
            }
        }
    }];

    // Define controller to take action
    UIViewController *rootViewController = nil;
    rootViewController = [self defaultNavigationController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = rootViewController;
    // Make the receiver the main window and displays it in front of other windows
    [self.window makeKeyAndVisible];
    // The number to display as the app’s icon badge.
    application.applicationIconBadgeNumber = 0;

//    [NotificationPermissions canSendNotifications];

    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);

        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }

    // Set Appirater settings
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    // Make sure you set to NO to ensure the request is not shown every time the app is launched
    [Appirater setDebug:YES];
    [Appirater appLaunched:YES];

    NSLog(@"[AppDelegate] didFinishLaunchingWithOptions: Done in %.0fms", [[NSDate date] timeIntervalSinceDate:startDate] * 1000);

    return YES;
}

- (UIViewController*)defaultNavigationController
{
    Account *account = [Account currentUser];
    BOOL hasAccount = NO;
    
    if (account) {
        hasAccount = YES;
    }

    /**
     * Proceso para nombrar controladores en Storyboard
     * 1. Seleccionar Storyboard
     * 2. Seleccionar Scene deseada
     * 3. Abrir Identity inspector
     * 4. Propiedad Storyboard ID se escribe nombre
     */
    UIStoryboard *storyboard;

    if (hasAccount) {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        return [storyboard instantiateViewControllerWithIdentifier:@"HomeView"];
    } else {
        if ([SettingsKeys getTutorialShownSetting]) {
            storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
            return [storyboard instantiateViewControllerWithIdentifier:@"LoginView"];
        } else {
            storyboard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
            return [storyboard instantiateViewControllerWithIdentifier:@"TutorialView"];
        }
    }
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

#pragma mark - Server Configuration Methods -

- (Service*)getServerConfiguration {
    return [Service create];
}

#pragma mark - Push Notification Methods -
//
//- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
//{
//    ARTRealtime *ably = [[CustomAblyRealtime sharedInstance] getAblyRealtime];
//    if (ably) {
//        DDLogError(@"didRegisterForRemoteNotificationsWithDeviceToken succeded");
//        [ARTPush didRegisterForRemoteNotificationsWithDeviceToken:deviceToken realtime:ably];
//    }
//}
//
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
//    ARTRealtime *ably = [[CustomAblyRealtime sharedInstance] getAblyRealtime];
//    if (ably) {
//        DDLogError(@"didFailToRegisterForRemoteNotificationsWithError");
//        [ARTPush didFailToRegisterForRemoteNotificationsWithError:error realtime:ably];
//    }
//}
//
//#pragma mark - ARTPushRegistererDelegate Methods -
//
//-(void)didActivateAblyPush:(nullable ARTErrorInfo *)error {
//    if (error) {
//        DDLogError(@"didActivateAblyPush fail: --> %@", error);
//    } else {
//        DDLogError(@"didActivateAblyPush succeded");
//        [[CustomAblyRealtime sharedInstance] subscribeToPushNotifications];
//    }
//}
//
//-(void)didDeactivateAblyPush:(nullable ARTErrorInfo *)error {
//    if (error) {
//        DDLogError(@"didDeactivateAblyPush fail: --> %@", error);
//    } else {
//        DDLogError(@"didDeactivateAblyPush succeded");
//    }
//}
//
//-(void)didAblyPushRegistrationFail:(nullable ARTErrorInfo *)error {
//    if (error) {
//        DDLogError(@"didAblyPushRegistrationFail fail: --> %@", error);
//    } else {
//        DDLogError(@"didAblyPushRegistrationFail succeded");
//    }
//}

#pragma mark - Taplytics Methods -

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return NO;
}

// Method will be called if the app is open when it recieves the push notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // "userInfo" will give you the notification information
}

// Method will be called when the app recieves a push notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // "userInfo" will give you the notification information
    completionHandler(UIBackgroundFetchResultNoData);
}

// Method will be called if the app is open when it recieves the push notification
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    // "notification.request.content.userInfo" will give you the notification information
    completionHandler(UNNotificationPresentationOptionBadge);
}

// Method will be called if the user opens the push notification
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    // "response.notification.request.content.userInfo" will give you the notification information
    completionHandler();
}

#pragma mark - Branch Methods -

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // pass the url to the handle deep link call
    [[Branch getInstance] handleDeepLink:url];
    // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
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
        if ([[job objectForKey:@"task"] isEqualToString:@"customerDataJob"]) {
            NSError *error;
            // TODO: Replace with networking layer
            NSString *jsonData = @"";//[PFCloud callFunction:@"getCustomerId" withParameters:@{} error:&error];

            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([ParseValidation validateError:error]) {
                        [ParseValidation _handleInvalidSessionTokenError:[self topViewController]];
                    }
                });
                block(EDQueueResultCritical);
            } else {
                id object = [NSJSONSerialization JSONObjectWithData:[jsonData dataUsingEncoding:NSUTF8StringEncoding]
                                                            options:0
                                                              error:&error];
                if (error) {
                    block(EDQueueResultCritical);
                } else {
                    if ([object isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *results = object;

                        if ([results objectForKey:@"ob"] && [results objectForKey:@"ob"] != [NSNull null]) {
                            [SettingsKeys setCustomerId:[results objectForKey:@"ob"]];
                        }

                        if ([results objectForKey:@"dn"] && [results objectForKey:@"dn"] != [NSNull null]) {
                            [SettingsKeys setDisplayName:[results objectForKey:@"dn"]];
                        }

                        if ([results objectForKey:@"gn"] && [results objectForKey:@"gn"] != [NSNull null]) {
                            [SettingsKeys setGender:[[results objectForKey:@"gn"] unsignedIntegerValue]];
                        }

                        if ([results objectForKey:@"bd"] && [results objectForKey:@"bd"] != [NSNull null]) {
                            [SettingsKeys setBirthday:[[results objectForKey:@"bd"] unsignedIntegerValue]];
                        }

                        block(EDQueueResultSuccess);
                    } else {
                        block(EDQueueResultCritical);
                    }
                }
            }
        } else if ([[job objectForKey:@"task"] isEqualToString:@"favoriteJob"]) {
            NSDictionary *data = [job objectForKey:@"data"];

            NSError *error;
            NSNumber *result;
            // TODO: Replace with networking layer
//            if ([data objectForKey:@"favorite"]) {
//                result = [PFCloud callFunction:@"setCustomerFavorite"
//                                withParameters:@{@"businessId": [data objectForKey:@"business"],
//                                                 @"customerId": [SettingsKeys getCustomerId],
//                                                 @"favorite": @YES}
//                                         error:&error];
//            } else {
//                result = [PFCloud callFunction:@"setCustomerFavorite"
//                                withParameters:@{@"businessId": [data objectForKey:@"business"],
//                                                 @"customerId": [SettingsKeys getCustomerId]}
//                                         error:&error];
//            }

            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([ParseValidation validateError:error]) {
                        [ParseValidation _handleInvalidSessionTokenError:[self topViewController]];
                    }
                });
                block(EDQueueResultCritical);
            } else {
                block(EDQueueResultSuccess);
            }
        } else if ([[job objectForKey:@"task"] isEqualToString:@"downloadAvatarJob"]) {
            NSDictionary *data = [job objectForKey:@"data"];

            NSString *businessId = [data objectForKey:@"businessId"];
            NSString *url = [data objectForKey:@"url"];
            // TODO: Replace with networking layer
//            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//            NSURL *URL = [NSURL URLWithString:url];
//            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//
//            NSURLSessionDownloadTask *downloadTask =
//            [manager downloadTaskWithRequest:request
//                                    progress:nil
//                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
//             {
//                 NSMutableString *savePath = [[NSMutableString alloc] initWithFormat:@"%@", [[NSFileManager defaultManager] applicationLibraryDirectory].path];
//                 [savePath appendString:kMessageMediaAvatarLocation];
//                 // Create if not already created
//                 [[NSFileManager defaultManager] createDirectory:[savePath copy]];
//                 // Continue with filename
//                 [savePath appendString:@"/"];
//                 // Add requested save path
//                 [savePath appendString:businessId];
//                 [savePath appendString:@"_avatar.jpg"];
//
//                 return [[NSURL alloc] initFileURLWithPath:savePath];
//             }
//                           completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
//             {
//                 DDLogInfo(@"downloadAvatarJob downloaded to: %@", filePath);
//                 if (error) {
//                     DDLogError(@"downloadAvatarJob error: %@", error);
//                     block(EDQueueResultCritical);
//                 } else {
//                     YapDatabaseConnection *connection = [DatabaseManager sharedInstance].newConnection;
//                     __block YapContact *contact = nil;
//
//                     [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
//                         contact = [YapContact fetchObjectWithUniqueID:businessId transaction:transaction];
//                     }];
//
//                     if (contact == nil) {
//                         // Delete file if contact not exists
//                         [[NSFileManager defaultManager] deleteDataInDirectory:[filePath absoluteString]
//                                                                         error:nil];
//                     }
//
//                     block(EDQueueResultSuccess);
//                 }
//             }];
//
//            [downloadTask resume];
        } else if ([[job objectForKey:@"task"] isEqualToString:@"downloadFileJob"]) {
            NSDictionary *data = [job objectForKey:@"data"];

            NSString *messageId = [data objectForKey:@"messageId"];
            NSString *url = [data objectForKey:@"url"];
            NSInteger messageType = [[data objectForKey:@"type"] integerValue];
            // TODO: Replace with networking layer
//            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//            NSURL *URL = [NSURL URLWithString:url];
//            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//
//            NSURLSessionDownloadTask *downloadTask =
//            [manager downloadTaskWithRequest:request
//                                    progress:nil
//                                 destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
//             {
//                 NSMutableString *savePath = [[NSMutableString alloc] initWithFormat:@"%@", [[NSFileManager defaultManager] applicationLibraryDirectory].path];
//
//                 switch (messageType) {
//                     case kMessageTypeImage: {
//                         [savePath appendString:kMessageMediaImageLocation];
//                         // Create if not already created
//                         [[NSFileManager defaultManager] createDirectory:[savePath copy]];
//                         // Continue with filename
//                         [savePath appendString:@"/"];
//                         // Add requested save path
//                         [savePath appendString:messageId];
//                         [savePath appendString:@".jpg"];
//                         break;
//                     }
//                     case kMessageTypeAudio: {
//                         [savePath appendString:kMessageMediaAudioLocation];
//                         // Create if not already created
//                         [[NSFileManager defaultManager] createDirectory:[savePath copy]];
//                         // Continue with filename
//                         [savePath appendString:@"/"];
//                         // Add requested save path
//                         [savePath appendString:messageId];
//                         [savePath appendString:@".mp3"];
//                         break;
//                     }
//                     default: {
//                         [savePath appendString:kMessageMediaVideoLocation];
//                         // Create if not already created
//                         [[NSFileManager defaultManager] createDirectory:[savePath copy]];
//                         // Continue with filename
//                         [savePath appendString:@"/"];
//                         // Add requested save path
//                         [savePath appendString:messageId];
//                         [savePath appendString:@".mp4"];
//                         break;
//                     }
//                 }
//
//                 return [[NSURL alloc] initFileURLWithPath:savePath];
//             }
//                           completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
//             {
//                 DDLogInfo(@"downloadFileJob downloaded to: %@", filePath);
//                 YapDatabaseConnection *connection = [DatabaseManager sharedInstance].newConnection;
//                 __block YapMessage *message = nil;
//
//                 [connection readWithBlock:^(YapDatabaseReadTransaction * _Nonnull transaction) {
//                     message = [YapMessage fetchObjectWithUniqueID:messageId transaction:transaction];
//                 }];
//
//                 if (message == nil) {
//                     // Delete file if message not exists
//                     [[NSFileManager defaultManager] deleteDataInDirectory:[filePath absoluteString]
//                                                                     error:nil];
//                 } else {
//                     if (error) {
//                         DDLogError(@"downloadFileJob error: %@", error);
//                         message.delivered = statusParseError;
//                         [[NSFileManager defaultManager] deleteDataInDirectory:[filePath absoluteString]
//                                                                         error:nil];
//                     } else {
//                         message.delivered = statusReceived;
//                         switch (messageType) {
//                             case kMessageTypeImage: {
//                                 message.filename = [messageId stringByAppendingString:@".jpg"];
//                                 break;
//                             }
//                             case kMessageTypeAudio: {
//                                 message.filename = [messageId stringByAppendingString:@".mp3"];
//                                 break;
//                             }
//                             default: {
//                                 message.filename = [messageId stringByAppendingString:@".mp4"];
//                                 break;
//                             }
//                         }
//                     }
//
//                     [connection readWriteWithBlock:^(YapDatabaseReadWriteTransaction * _Nonnull transaction)
//                      {
//                          [message saveWithTransaction:transaction];
//                          // Make a YapDatabaseModifiedNotification to update
//                          NSDictionary *transactionExtendedInfo = @{YapDatabaseModifiedNotificationUpdate: @TRUE};
//                          transaction.yapDatabaseModifiedNotificationCustomObject = transactionExtendedInfo;
//                      }];
//                 }
//
//                 block(EDQueueResultSuccess);
//             }];
//
//            [downloadTask resume];
        } else if ([[job objectForKey:@"task"] isEqualToString:@"removeConversationJob"]) {
            NSDictionary *data = [job objectForKey:@"data"];

            NSError *error;
            // TODO: Replace with networking layer
//            [PFCloud callFunction:@"deleteConversations"
//                   withParameters:@{@"businessId": [data objectForKey:@"businessId"],
//                                    @"customerId": [data objectForKey:@"customerId"],
//                                    @"fromCustomer": @YES}
//                            error:&error];

            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([ParseValidation validateError:error]) {
                        [ParseValidation _handleInvalidSessionTokenError:[self topViewController]];
                    }
                });
                block(EDQueueResultFail);
            } else {
                block(EDQueueResultSuccess);
            }
        } else {
            block(EDQueueResultCritical);
        }
    } @catch (NSException *exception) {
        block(EDQueueResultCritical);
    } @catch (id exception) {
        block(EDQueueResultCritical);
    }
}

@end
