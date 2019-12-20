/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>

#import <CoreFoundation/CoreFoundation.h>

#import "ANSReachability.h"

#pragma mark IPv6 Support
//Reachability fully support IPv6.  For full details, see ReadMe.md.

NSString *const ANSNetworkChangedNotification = @"ANSNetworkChangedNotification";


#pragma mark - Supporting functions

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [ANSReachability class]], @"info was wrong class in ReachabilityCallback");

    ANSReachability* noteObject = (__bridge ANSReachability *)info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSNetworkChangedNotification object: noteObject];
}


#pragma mark - Reachability implementation

@implementation ANSReachability {
	SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName {
	ANSReachability* returnValue = NULL;
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
	if (reachability != NULL) {
		returnValue= [[self alloc] init];
		if (returnValue != NULL) {
			returnValue->_reachabilityRef = reachability;
		} else {
            CFRelease(reachability);
        }
	}
	return returnValue;
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress {
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, hostAddress);

	ANSReachability* returnValue = NULL;

	if (reachability != NULL) {
		returnValue = [[self alloc] init];
		if (returnValue != NULL) {
			returnValue->_reachabilityRef = reachability;
		} else {
            CFRelease(reachability);
        }
	}
	return returnValue;
}


+ (instancetype)reachabilityForInternetConnection {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress: (const struct sockaddr *) &zeroAddress];
}

#pragma mark reachabilityForLocalWiFi
//reachabilityForLocalWiFi has been removed from the sample.  See ReadMe.md for more information.
//+ (instancetype)reachabilityForLocalWiFi

#pragma mark - Start and stop notifier

- (BOOL)startNotifier {
	BOOL returnValue = NO;
    @try {
        SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        
        if (SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)) {
            if (SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
                returnValue = YES;
            }
        }
    } @catch (NSException *exception) {

    }
    
	return returnValue;
}


- (void)stopNotifier {
	if (_reachabilityRef != NULL) {
		SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	}
}


- (void)dealloc {
	[self stopNotifier];
	if (_reachabilityRef != NULL) {
		CFRelease(_reachabilityRef);
	}
}


#pragma mark - Network Flag Handling

- (ANSNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
//    PrintReachabilityFlags(flags, "networkStatusForFlags");
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
		// The target host is not reachable.
		return ANSNotReachable;
	}

    ANSNetworkStatus returnValue = ANSNotReachable;

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		returnValue = ANSReachableViaWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            /*
             ... and no [user] intervention is needed...
             */
            returnValue = ANSReachableViaWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
		/*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
		returnValue = ANSReachableViaWWAN;
	}
    
	return returnValue;
}


- (BOOL)connectionRequired {
	NSAssert(_reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
	SCNetworkReachabilityFlags flags;

	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}

    return NO;
}


- (ANSNetworkStatus)networkStatus {
	NSAssert(_reachabilityRef != NULL, @"currentNetworkStatus called with NULL SCNetworkReachabilityRef");
	ANSNetworkStatus returnValue = ANSNotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(_reachabilityRef, &flags)) {
        returnValue = [self networkStatusForFlags:flags];
	}
    
	return returnValue;
}


@end
