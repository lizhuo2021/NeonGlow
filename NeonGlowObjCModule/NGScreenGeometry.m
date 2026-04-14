//
//  NGScreenGeometry.m
//  NeonGlowObjC
//
//  Created by 李琢 on 2026/04/14.
//

#import "NGScreenGeometry.h"
#import <sys/utsname.h>

@implementation NGScreenGeometry

+ (CGFloat)displayCornerRadiusForCurrentDevice {
    NSString *identifier = [self currentDeviceIdentifier];

    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone10,3", @"iPhone10,6", @"iPhone11,2", @"iPhone11,4", @"iPhone11,6", @"iPhone12,3", @"iPhone12,5"]]) {
        return 39.0;
    }
    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone11,8", @"iPhone12,1"]]) {
        return 41.5;
    }
    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone13,1", @"iPhone14,4"]]) {
        return 44.0;
    }
    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone13,2", @"iPhone13,3", @"iPhone14,5", @"iPhone14,7", @"iPhone17,3"]]) {
        return 47.33;
    }
    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone13,4", @"iPhone14,3", @"iPhone14,8"]]) {
        return 53.33;
    }
    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone15,2", @"iPhone15,3", @"iPhone15,4", @"iPhone15,5", @"iPhone16,1", @"iPhone16,2", @"iPhone17,1", @"iPhone17,2"]]) {
        return 55.0;
    }
    if ([self identifier:identifier hasPrefixInArray:@[@"iPhone17,4", @"iPhone17,5", @"iPhone18,1", @"iPhone18,2", @"iPhone18,3", @"iPhone18,4"]]) {
        return 62.0;
    }
    if ([identifier hasPrefix:@"iPad"]) {
        return 18.0;
    }
    return [self fallbackCornerRadius];
}

+ (NSString *)currentDeviceIdentifier {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *identifier = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([identifier isEqualToString:@"x86_64"] || [identifier isEqualToString:@"arm64"]) {
        NSString *simulatorIdentifier = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
        if (simulatorIdentifier.length > 0) {
            return simulatorIdentifier;
        }
    }
    return identifier ?: @"Unknown";
}

+ (BOOL)identifier:(NSString *)identifier hasPrefixInArray:(NSArray<NSString *> *)prefixes {
    for (NSString *prefix in prefixes) {
        if ([identifier hasPrefix:prefix]) {
            return YES;
        }
    }
    return NO;
}

+ (CGFloat)fallbackCornerRadius {
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat maxSide = MAX(screenSize.width, screenSize.height);
    CGFloat minSide = MIN(screenSize.width, screenSize.height);

    if (maxSide >= 956.0) return 62.0;
    if (maxSide >= 932.0) return minSide >= 430.0 ? 55.0 : 47.33;
    if (maxSide >= 926.0) return minSide >= 428.0 ? 53.33 : 47.33;
    if (maxSide >= 852.0) return 55.0;
    if (maxSide >= 844.0) return 47.33;
    if (maxSide >= 812.0) return 39.0;
    return 34.0;
}

@end
