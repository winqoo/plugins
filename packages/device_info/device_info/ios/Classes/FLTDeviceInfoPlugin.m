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
      @"name" : [device name] != nil ? [device name] : @"",
      @"systemName" : [device systemName] != nil ? [device systemName] : @"",
      @"systemVersion" : [device systemVersion] != nil ? [device systemVersion] : @"",
      @"model" : [device model] != nil ? [device model] : @"",
      @"localizedModel" : [device localizedModel] != nil ? [device localizedModel] : @"",
      @"identifierForVendor" : [[device identifierForVendor] UUIDString] != nil ? [[device identifierForVendor] UUIDString] : @"",
      @"isPhysicalDevice" : [self isDevicePhysical] != nil ? [self isDevicePhysical] : @"",
      @"utsname" : @{
        @"sysname" : un.sysname != nil ?  @(un.sysname) : @"",
        @"nodename" : un.nodename != nil ? @(un.nodename) : @"",
        @"release" :un.release != nil ?  @(un.release) : @"",
        @"version" : un.version != nil ? @(un.version) : @"",
        @"machine" : un.machine!= nil ? @(un.machine) : @"",
      }
    });
  } else {
    result(FlutterMethodNotImplemented);
  }
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
