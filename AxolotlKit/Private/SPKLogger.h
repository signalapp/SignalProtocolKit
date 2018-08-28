//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

@import CocoaLumberjack;

#ifdef DEBUG
static const NSUInteger ddLogLevel = DDLogLevelAll;
#else
static const NSUInteger ddLogLevel = DDLogLevelInfo;
#endif

NS_ASSUME_NONNULL_BEGIN

#define OWSLogPrefix()                                                                                                 \
    ([NSString stringWithFormat:@"[%@:%d %s]: ",                                                                       \
               [[NSString stringWithUTF8String:__FILE__] lastPathComponent],                                           \
               __LINE__,                                                                                               \
               __PRETTY_FUNCTION__])

#define OWSLogVerbose(_messageFormat, ...)                                                                             \
    do {                                                                                                               \
        DDLogVerbose(@"%@%@", OWSLogPrefix(), [NSString stringWithFormat:_messageFormat, ##__VA_ARGS__]);              \
    } while (0)

#define OWSLogDebug(_messageFormat, ...)                                                                               \
    do {                                                                                                               \
        DDLogDebug(@"%@%@", OWSLogPrefix(), [NSString stringWithFormat:_messageFormat, ##__VA_ARGS__]);                \
    } while (0)

#define OWSLogInfo(_messageFormat, ...)                                                                                \
    do {                                                                                                               \
        DDLogInfo(@"%@%@", OWSLogPrefix(), [NSString stringWithFormat:_messageFormat, ##__VA_ARGS__]);                 \
    } while (0)

#define OWSLogWarn(_messageFormat, ...)                                                                                \
    do {                                                                                                               \
        DDLogWarn(@"%@%@", OWSLogPrefix(), [NSString stringWithFormat:_messageFormat, ##__VA_ARGS__]);                 \
    } while (0)

#define OWSLogError(_messageFormat, ...)                                                                               \
    do {                                                                                                               \
        DDLogError(@"%@%@", OWSLogPrefix(), [NSString stringWithFormat:_messageFormat, ##__VA_ARGS__]);                \
    } while (0)

NS_ASSUME_NONNULL_END
