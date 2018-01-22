//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

#ifndef SPKAssert

#ifdef DEBUG

#define USE_SPK_ASSERTS

#define SPK_CONVERT_TO_STRING(X) #X
#define SPK_CONVERT_EXPR_TO_STRING(X) SPK_CONVERT_TO_STRING(X)

// SPKAssert() and SPKFail() should be used in Obj-C methods.
// SPKCAssert() and SPKCFail() should be used in free functions.

#define SPKAssert(X)                                                                                                   \
    if (!(X)) {                                                                                                        \
        DDLogError(@"%s Assertion failed: %s", __PRETTY_FUNCTION__, SPK_CONVERT_EXPR_TO_STRING(X));                    \
        [DDLog flushLog];                                                                                              \
        NSAssert(0, @"Assertion failed: %s", SPK_CONVERT_EXPR_TO_STRING(X));                                           \
    }

#define SPKCAssert(X)                                                                                                  \
    if (!(X)) {                                                                                                        \
        DDLogError(@"%s Assertion failed: %s", __PRETTY_FUNCTION__, SPK_CONVERT_EXPR_TO_STRING(X));                    \
        [DDLog flushLog];                                                                                              \
        NSCAssert(0, @"Assertion failed: %s", SPK_CONVERT_EXPR_TO_STRING(X));                                          \
    }

#define SPKFail(message, ...)                                                                                          \
    {                                                                                                                  \
        NSString *formattedMessage = [NSString stringWithFormat:message, ##__VA_ARGS__];                               \
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, formattedMessage);                                                   \
        [DDLog flushLog];                                                                                              \
        NSAssert(0, formattedMessage);                                                                                 \
    }

#define SPKCFail(message, ...)                                                                                         \
    {                                                                                                                  \
        NSString *formattedMessage = [NSString stringWithFormat:message, ##__VA_ARGS__];                               \
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, formattedMessage);                                                   \
        [DDLog flushLog];                                                                                              \
        NSCAssert(0, formattedMessage);                                                                                \
    }

#define SPKFailNoFormat(message)                                                                                       \
    {                                                                                                                  \
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, message);                                                            \
        [DDLog flushLog];                                                                                              \
        NSAssert(0, message);                                                                                          \
    }

#define SPKCFailNoFormat(message)                                                                                      \
    {                                                                                                                  \
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, message);                                                            \
        [DDLog flushLog];                                                                                              \
        NSCAssert(0, message);                                                                                         \
    }

#else

#define SPKAssert(X)
#define SPKCAssert(X)
#define SPKFail(message, ...)
#define SPKCFail(message, ...)
#define SPKFailNoFormat(X)
#define SPKCFailNoFormat(X)

#endif

#endif

NS_ASSUME_NONNULL_END
