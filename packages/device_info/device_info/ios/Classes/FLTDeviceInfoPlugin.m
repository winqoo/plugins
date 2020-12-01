// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTDeviceInfoPlugin.h"
#import <sys/utsname.h>

@implementation FLTDeviceInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/device_info"
                                  binaryMessenger:[registrar messenger]];
  FLTDeviceInfoPlugin* instance = [[FLTDeviceInfoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
    UIDevice* device = [UIDevice currentDevice];
    struct utsname un;
    uname(&un);

    result(@{
      @"name" : [self _safeValueFor:[device name] whenNil:@""],
      @"systemName" : [self _safeValueFor:[device systemName] whenNil:@""],
      @"systemVersion" : [self _safeValueFor:[device systemVersion] whenNil:@""],
      @"model" : [self _safeValueFor:[device model] whenNil:@""],
      @"localizedModel" : [self _safeValueFor:[device localizedModel] whenNil:@""],
      @"identifierForVendor" : [self _safeValueFor:[[device identifierForVendor] UUIDString] whenNil:@""],
      @"isPhysicalDevice" : [self _safeValueFor:[self isDevicePhysical] whenNil:@(NO)],
      @"utsname" : @{
        @"sysname" : [self _safeValueFor:@(un.sysname) whenNil:@""],
        @"nodename" : [self _safeValueFor:@(un.nodename) whenNil:@""],
        @"release" : [self _safeValueFor:@(un.release) whenNil:@""],
        @"version" : [self _safeValueFor:@(un.version) whenNil:@""],
        @"machine" : [self _safeValueFor:@(un.machine) whenNil:@""],
      }
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(id)_safeValueFor:(id)attribute whenNil:(id)defaultValue {
  if (attribute && attribute != nil && attribute != [NSNull null]) {
    return attribute;
  }

  return defaultValue;
}

// return value is false if code is run on a simulator
- (NSString*)isDevicePhysical {
#if TARGET_OS_SIMULATOR
  NSString* isPhysicalDevice = @"false";
#else
  NSString* isPhysicalDevice = @"true";
#endif

  return isPhysicalDevice;
}

@end
