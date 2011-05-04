//
//  IBADebug.h
//  IttyBittyBits
//
//  Created by Oliver Jones on 27/04/11.
//  Copyright 2011 Itty Bitty Apps Pty. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IBALogger.h"

/*!
 \brief     Raises an assertion when the argument is nil.
 \param     x   The argument to test.
 */
#define IBAAssertNotNil(x) \
    NSAssert1((x) != nil, @"%@ can not be nil", @#x)

/*!
 \brief     Raises an assertion when the argument is a nil or empty string.
 \param     x   The argument to test.
 */
#define IBAAssertNotNilOrEmptyString(x) \
    NSAssert1((((x) != nil) && (![(x) isEqualToString: @""])), @"%@ can not be nil or empty", @#x)

void ALogImpl(BOOL assert, const char* functionName, const char* filename, int line, NSString* format, ...);

#ifndef NDEBUG
    void DLogImpl(const char* functionName, NSString* format, ...);
    #define DLog(format, ...) \
        DLogImpl(__PRETTY_FUNCTION__, format, ##__VA_ARGS__)

    #define ALog(format, ...) \
        ALogImpl(YES, __PRETTY_FUNCTION__, __FILE__, __LINE__, format, ##__VA_ARGS__)

#else
    #define DLog(...) do { } while (0)

    #define ALog(format, ...) \
        ALogImpl(NO, __PRETTY_FUNCTION__, __FILE__, __LINE__, format, ##__VA_ARGS__)

#endif
