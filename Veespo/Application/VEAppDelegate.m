//
//  VEAppDelegate.m
//  Veespo
//
//  Created by Alessio Roberto on 20/09/13.
//  Copyright (c) 2013 Veespo Ltd. All rights reserved.
//

#import "VEAppDelegate.h"

#import "JASidePanelController.h"

#import "VELeftMenuViewController.h"
#import "VEMenuCell.h"
#import "VEViewController.h"
#import "VEFSViewController.h"
#import "VERSSViewController.h"
#import "VEEspnViewController.h"
#import "Foursquare2.h"

#import <AdSupport/AdSupport.h>

static NSString * const kVEFoursquareKey = @"Foursquare key";
static NSString * const kVEFoursquareSecret = @"Foursquare secret";
static NSString * const kVETestFlightKey = @"TestFlight Key";
static NSString * const kVEKeysFileName = @"Veespo-Keys";
static NSString * const kVEVeespoApiKey = @"Veespo Api Key";

#pragma mark - Private Interface
@implementation VEAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setUpApi];
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        [NSUserDefaults resetStandardUserDefaults];
        NSString *dateKey = @"Data Key";
        NSDate *lastRead = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
        if (!lastRead) {
            NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
            // sync the defaults to disk
            [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSUserDefaults standardUserDefaults] setObject:[VEAppDelegate uuid] forKey:@"uuid"];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];
    }
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
        self.window.tintColor = UIColorFromRGB(0x1D7800);
    
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    
    NSArray *headers = @[
                         @"Veespo",
                         NSLocalizedString(@"Around me", nil),
                         NSLocalizedString(@"News", nil)
                         ];
	NSArray *controllers = @[
                             @[
                                 [[UINavigationController alloc] initWithRootViewController:[[VEViewController alloc] init]]
                                 ],
                             @[
                                 [[UINavigationController alloc] initWithRootViewController:[[VEFSViewController alloc] init]]
                                 ],
                             @[
                                 [[UINavigationController alloc] initWithRootViewController:[[VERSSViewController alloc] init]],
                                 [[UINavigationController alloc] initWithRootViewController:[[VEEspnViewController alloc] init]]
                                 ]
                             ];
    NSArray *cellInfos = @[
                           @[
                               @{kSidebarCellImageKey:[UIImage imageNamed:@"home.png"], kSidebarCellTextKey:@"Home"},
                               ],
                           @[
                               @{kSidebarCellImageKey:[UIImage imageNamed:@"shop.png"], kSidebarCellTextKey:NSLocalizedString(@"Venues", nil)},
                               ],
                           @[
                               @{kSidebarCellImageKey:[UIImage imageNamed:@"electronics.png"], kSidebarCellTextKey:NSLocalizedString(@"Tech News", nil)},
                               @{kSidebarCellImageKey:[UIImage imageNamed:@"football.png"], kSidebarCellTextKey:NSLocalizedString(@"Sport News", nil)},
                               ]
                           ];
    
    VELeftMenuViewController *menuController = [[VELeftMenuViewController alloc] init];
    [menuController setViewControllers:controllers cellInfos:cellInfos headers:headers];
    
    self.viewController.leftPanel = menuController;
    self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[VEViewController alloc] init]];
    self.viewController.rightPanel = nil;
    self.window.rootViewController = self.viewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)configSidebarController
{
    
    
}

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)uuidStringRef;
}

#pragma mark - API

- (void)setUpApi
{
    NSString *keysPath = [[NSBundle mainBundle] pathForResource:kVEKeysFileName ofType:@"plist"];
    if (!keysPath) {
        NSLog(@"To use API make sure you have a Veespo-Keys.plist with the Identifier in your project");
        return;
    }
    
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:keysPath];
    [self setUpFoursquare:keys];
    [self setUpVeespo:keys];
#ifdef TESTFLIGHT
    [TestFlight takeOff:keys[kVETestFlightKey]];
#endif
}

- (void)setUpFoursquare:(NSDictionary *)keys
{
    [Foursquare2 setupFoursquareWithClientId:keys[kVEFoursquareKey]
                                      secret:keys[kVEFoursquareSecret]
                                 callbackURL:@"testapp123://foursquare"];
}

- (void)setUpVeespo:(NSDictionary *)keys
{
#ifdef VEESPO
    NSDictionary *categories = @{
                                 @"categories":@[
                                         @{@"cat": @"cibi"},
                                         @{@"cat": @"localinotturni"},
                                         @{@"cat": @"news"}
                                         ]
                                 };
    NSString *userId = nil;
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        userId = [NSString stringWithFormat:@"VeespoApp-%@", [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"]];
    } else {
        userId = [NSString stringWithFormat:@"VeespoApp-%@", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]];
    }
    
    [Veespo initVeespo:keys[kVEVeespoApiKey]
                userId:userId
             partnerId:@"alessio"
              language:[[NSLocale preferredLanguages] objectAtIndex:0]
            categories:categories
               testUrl:NO
                tokens:^(id responseData, BOOL error) {
                    if (error == NO) {
                        self.tokens = [[NSDictionary alloc] initWithDictionary:responseData];
                        NSLog(@"%@ /n %@", userId, self.tokens);
                    } else {
                        self.tokens = nil;
                        NSLog(@"%@", responseData);
                    }
                }
     ];
#endif
}

@end
