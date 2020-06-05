//
//  ANSUncaughtExceptionHandler.m
//  bengkui
//
//  Created by xiao xu on 2019/10/17.
//  Copyright © 2019 rainbird. All rights reserved.
//

#import "ANSUncaughtExceptionHandler.h"
#import "AnalysysSDK.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import <mach-o/dyld.h>
#import "ANSConst+private.h"
#import "ANSDataProcessing.h"
#import "ANSJsonUtil.h"

static NSUncaughtExceptionHandler *ans_other_vaildUncaughtExceptionHandler;
static struct sigaction *ans_prev_signal_handlers;

NSString * const ANSUncaughtExceptionHandlerSignalExceptionName = @"ANSUncaughtExceptionHandlerSignalExceptionName";
NSString * const ANSUncaughtExceptionHandlerSignalKey = @"ANSUncaughtExceptionHandlerSignalKey";
NSString * const ANSUncaughtExceptionHandlerCallStack = @"ANSUncaughtExceptionHandlerCallStack";

volatile int32_t ANSUncaughtExceptionCount = 0;
const int32_t ANSUncaughtExceptionMaximum = 10;

const NSInteger ANSUncaughtExceptionHandlerSkipAddressCount = 0;
const NSInteger ANSUncaughtExceptionHandlerReportAddressCount = 10;

@interface ANSUncaughtExceptionHandler()
@property (nonatomic, strong) NSMutableArray *binaryImageNames;
+ (instancetype)exceptionManager;
@end

@implementation ANSUncaughtExceptionHandler
+ (instancetype)exceptionManager {
    static ANSUncaughtExceptionHandler *ans_uncaught_exception = nil;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        if (!ans_uncaught_exception) {
            ans_uncaught_exception = [[self alloc] init];
        }
    });
    return ans_uncaught_exception;
}

+ (NSMutableArray *)ans_binary_images {
    NSMutableArray *array = [NSMutableArray array];
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
          uint64_t vmbase = 0;
          uint64_t vmslide = 0;
          uint64_t vmsize = 0;

          uint64_t loadAddress = 0;
          uint64_t loadEndAddress = 0;
          NSString *imageName = @"";
          NSString *uuid = @"";
          const struct mach_header *header = _dyld_get_image_header(i);
          const char *name = _dyld_get_image_name(i);
          vmslide = (i);
          imageName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        if ([[[self exceptionManager] binaryImageNames] containsObject:[[imageName componentsSeparatedByString:@"/"] lastObject]]) {
            BOOL is64bit = header->magic == MH_MAGIC_64 || header->magic == MH_CIGAM_64;
                      uintptr_t cursor = (uintptr_t)header + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
                      struct load_command *loadCommand = NULL;
                      for (uint32_t i = 0; i < header->ncmds; i++, cursor += loadCommand->cmdsize) {
                          loadCommand = (struct load_command *)cursor;
                          if(loadCommand->cmd == LC_SEGMENT) {
                              const struct segment_command* segmentCommand = (struct segment_command*)loadCommand;
                              if (strcmp(segmentCommand->segname, SEG_TEXT) == 0) {
                                  vmsize = segmentCommand->vmsize;
                                  vmbase = segmentCommand->vmaddr;
                              }
                          } else if(loadCommand->cmd == LC_SEGMENT_64) {
                              const struct segment_command_64* segmentCommand = (struct segment_command_64*)loadCommand;
                               if (strcmp(segmentCommand->segname, SEG_TEXT) == 0) {
                                  vmsize = segmentCommand->vmsize;
                                  vmbase = (uintptr_t)(segmentCommand->vmaddr);
                              }
                          }
                          else if (loadCommand->cmd == LC_UUID) {
                              const struct uuid_command *uuidCommand = (const struct uuid_command *)loadCommand;
                              uuid = [[[NSUUID alloc] initWithUUIDBytes:uuidCommand->uuid] UUIDString];
            //                  uuid = [[uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
                          }
                      }

                      loadAddress = vmbase + vmslide;
                      loadEndAddress = loadAddress + vmsize - 1;

                      NSMutableDictionary *params = [NSMutableDictionary dictionary];
                    [params setValue:@(loadAddress) forKey:@"loadAddress"];
                    [params setValue:@(loadEndAddress) forKey:@"loadEndAddress"];
                    [params setValue:imageName forKey:@"imageName"];
                    [params setValue:uuid forKey:@"uuid"];

                    [array addObject:params];
        } else {
            continue;
        }
          
    }

    return array;
}

//+ (NSArray *)backtrace
//{
//     void* callstack[128];
//     int frames = backtrace(callstack, 128);
//     char **strs = backtrace_symbols(callstack, frames);
//     NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
//     for (int i = 0; i < frames; i++) {
//         [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
//     }
//     free(strs);
//     return backtrace;
//}

- (void)handleException:(NSException *)exception {
    NSMutableDictionary *crash_data = [NSMutableDictionary dictionary];
    [crash_data setObject:[exception name]?:@"" forKey:@"crash_name"];
    [crash_data setObject:[exception reason]?:@"" forKey:@"crash_reason"];
    [crash_data setObject:[[exception userInfo] objectForKey:ANSUncaughtExceptionHandlerCallStack]?:@"" forKey:@"crash_stack"];
    [crash_data setObject:[ANSUncaughtExceptionHandler ans_binary_images] forKey:@"crash_binary"];
    NSString *crashDataString = [ANSJsonUtil convertToStringWithObject:crash_data];
    
    NSDictionary *crashEvent = [ANSDataProcessing processAppCrashProperties:@{@"$crash_data":crashDataString ?: @""}];
    
    [[[AnalysysSDK sharedManager] getDBHelper] insertRecordObject:crashEvent event:ANSEventCrash maxCacheSize:MAXFLOAT result:^(BOOL success) {
        if (success) {
            //
        }
    }];
    
    if ([[exception name] isEqual:ANSUncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:ANSUncaughtExceptionHandlerSignalKey] intValue]);
    }
    else
    {
        [exception raise];
    }
    
//    NSSetUncaughtExceptionHandler(NULL);
//    signal(SIGABRT, SIG_DFL);
//    signal(SIGILL, SIG_DFL);
//    signal(SIGSEGV, SIG_DFL);
//    signal(SIGFPE, SIG_DFL);
//    signal(SIGBUS, SIG_DFL);
//    signal(SIGPIPE, SIG_DFL);
    
}

+ (void)reportException:(NSException *)exception {
    NSMutableDictionary *crash_data = [NSMutableDictionary dictionary];
    [crash_data setObject:[exception name]?:@"" forKey:@"crash_name"];
    [crash_data setObject:[exception reason]?:@"" forKey:@"crash_reason"];
    [crash_data setObject:[exception callStackSymbols]?:@"" forKey:@"crash_stack"];
    [crash_data setObject:[ANSUncaughtExceptionHandler ans_binary_images] forKey:@"crash_binary"];
    NSString *crashDataString = [ANSJsonUtil convertToStringWithObject:crash_data];
    NSDictionary *crashEvent = [ANSDataProcessing processAppCrashProperties:@{@"$crash_data":crashDataString ?: @""}];
    
    [[[AnalysysSDK sharedManager] getDBHelper] insertRecordObject:crashEvent event:ANSEventCrash maxCacheSize:MAXFLOAT result:^(BOOL success) {
        if (success) {
            //
        }
    }];
}

void ANSHandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&ANSUncaughtExceptionCount);
    if (exceptionCount > ANSUncaughtExceptionMaximum)
    {
        return;
    }
    
    //调用之前注册的HandleException
    if (ans_other_vaildUncaughtExceptionHandler) {
        ans_other_vaildUncaughtExceptionHandler(exception);
    }
    
    NSArray *callStack = exception.callStackSymbols;
    NSMutableDictionary *userInfo =
        [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:ANSUncaughtExceptionHandlerCallStack];
    [[[ANSUncaughtExceptionHandler alloc] init]
        performSelectorOnMainThread:@selector(handleException:)
        withObject:
            [NSException
                exceptionWithName:[exception name]
                reason:[exception reason]
                userInfo:userInfo]
        waitUntilDone:YES];
}

//void ANSSignalHandler(int signal, struct __siginfo *info, void *contex)
//{
//    int32_t exceptionCount = OSAtomicIncrement32(&ANSUncaughtExceptionCount);
//    if (exceptionCount > ANSUncaughtExceptionMaximum)
//    {
//        return;
//    }
//
//    //执行在在此之前注册的Signal
//    struct sigaction prev_action = ans_prev_signal_handlers[signal];
//    if (prev_action.sa_flags & SA_SIGINFO) {
//        if (prev_action.sa_sigaction) {
//            prev_action.sa_sigaction(signal, info, contex);
//        }
//    } else if (prev_action.sa_handler) {
//        prev_action.sa_handler(signal);
//    }
//
//    NSMutableDictionary *userInfo =
//        [NSMutableDictionary
//            dictionaryWithObject:[NSNumber numberWithInt:signal]
//            forKey:ANSUncaughtExceptionHandlerSignalKey];
//
//    NSArray *callStack = [ANSUncaughtExceptionHandler backtrace];
//    [userInfo setObject:callStack forKey:ANSUncaughtExceptionHandlerAddressesKey];
//
//    [[[ANSUncaughtExceptionHandler alloc] init]
//        performSelectorOnMainThread:@selector(handleException:)
//        withObject:
//            [NSException
//                exceptionWithName:ANSUncaughtExceptionHandlerSignalExceptionName
//                reason:
//                    [NSString stringWithFormat:
//                        NSLocalizedString(@"Signal %d was raised.", nil),
//                        signal]
//                userInfo:userInfo]
//        waitUntilDone:YES];
//}

void ANSInstallUncaughtExceptionHandler(void)
{
    ans_other_vaildUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&ANSHandleException);
    
//    ans_prev_signal_handlers = calloc(NSIG, sizeof(struct sigaction));
//
//    struct sigaction action;
//    sigemptyset(&action.sa_mask);
//    action.sa_flags = SA_SIGINFO;
//    action.sa_sigaction = &ANSSignalHandler;
//    int signals[] = {SIGABRT, SIGILL, SIGSEGV, SIGFPE, SIGBUS, SIGPIPE};
//    for (int i = 0; i < sizeof(signals) / sizeof(int); i++) {
//        struct sigaction prev_action;
//        int err = sigaction(signals[i], &action, &prev_action);
//        if (err == 0) {
//            memcpy(ans_prev_signal_handlers + signals[i], &prev_action, sizeof(prev_action));
//        } else {
//            NSLog(@"Errored while trying to set up sigaction for signal %d", signals[i]);
//        }
//    }
}

- (NSMutableArray *)binaryImageNames {
    if (!_binaryImageNames) {
        _binaryImageNames = [NSMutableArray arrayWithObjects:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"], @"UIKitCore", nil];
    }
    return _binaryImageNames;
}

@end
