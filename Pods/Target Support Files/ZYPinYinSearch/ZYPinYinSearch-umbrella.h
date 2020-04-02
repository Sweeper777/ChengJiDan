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

#import "ChineseInclude.h"
#import "ChineseToPinyinResource.h"
#import "HanyuPinyinOutputFormat.h"
#import "NSString+PinYin4Cocoa.h"
#import "PinyinFormatter.h"
#import "PinYinForObjc.h"
#import "PinyinHelper.h"
#import "ZYPinYinSearch.h"
#import "ZYSearchModel.h"

FOUNDATION_EXPORT double ZYPinYinSearchVersionNumber;
FOUNDATION_EXPORT const unsigned char ZYPinYinSearchVersionString[];

