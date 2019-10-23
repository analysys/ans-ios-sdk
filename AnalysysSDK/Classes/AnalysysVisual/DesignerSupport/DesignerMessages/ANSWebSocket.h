//
//  Copyright (c) 2014 Mixpanel. All rights reserved.
//

//   Portions Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef NS_ENUM(unsigned int, ANSWebSocketReadyState) {
    ANSWebSocketStateConnecting = 0,
    ANSWebSocketStateOpen = 1,
    ANSWebSocketStateClosing = 2,
    ANSWebSocketStateClosed = 3,
};

@class ANSWebSocket;

extern NSString *const ANSWebSocketErrorDomain;

#pragma mark - ANSWebSocketDelegate

@protocol ANSWebSocketDelegate;

#pragma mark - ANSWebSocket

@interface ANSWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, assign) id <ANSWebSocketDelegate> delegate;

@property (nonatomic, readonly) ANSWebSocketReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (instancetype)initWithURLRequest:(NSURLRequest *)request protocols:(NSArray *)protocols;
- (instancetype)initWithURLRequest:(NSURLRequest *)request;

// Some helper constructors.
- (instancetype)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;
- (instancetype)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop ans_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// EGWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

@end

#pragma mark - ANSWebSocketDelegate

@protocol ANSWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(ANSWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(ANSWebSocket *)webSocket;
- (void)webSocket:(ANSWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(ANSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;

@end

#pragma mark - NSURLRequest (ANSCertificateAdditions)

@interface NSURLRequest (ANSCertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *ans_SSLPinnedCertificates;

@end

#pragma mark - NSMutableURLRequest (ANSCertificateAdditions)

@interface NSMutableURLRequest (ANSCertificateAdditions)

@property (nonatomic, retain) NSArray *ans_SSLPinnedCertificates;

@end

#pragma mark - NSRunLoop (SRWebSocket)

@interface NSRunLoop (ANSWebSocket)

+ (NSRunLoop *)ans_networkRunLoop;

@end
