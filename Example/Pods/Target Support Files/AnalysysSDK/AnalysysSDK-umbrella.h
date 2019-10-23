#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AnalysysAgent.h"
#import "AnalysysAgentConfig.h"
#import "ANSConst.h"

FOUNDATION_EXPORT double AnalysysSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char AnalysysSDKVersionString[];

