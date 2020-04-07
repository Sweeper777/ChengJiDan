//
//  NSArray+PinYinSearcher.m
//  SWPinYinSeacher_Example
//
//  Created by game-netease on 8/30/15.
//  Copyright (c) 2015 game-netease. All rights reserved.
//

#import "NSArray+PinYinSearcher.h"
#import "NSString+PinYinConverter.h"
#import <objc/runtime.h>

@interface NSString (SWPYS)

@end

@implementation NSString (SWPYS)

- (BOOL)swpys_containsString:(NSString*)str{
    
    BOOL isContains = NO;
    
    if ([self respondsToSelector:@selector(containsString:)]) {
        isContains = [self containsString:str];
    }else{
        NSRange range = [self rangeOfString:str];
        isContains = (range.location == NSNotFound) ? NO : YES;
    }
    
    return isContains;
}

@end

@implementation NSArray (PinYinSearcher)

char SWPinYinSearcherNSArrayQueueKey;

- (void) setAssociatedObject: (id)object forKey: (void*)key {
    objc_setAssociatedObject(self, key, object, OBJC_ASSOCIATION_RETAIN);
}

- (id) associatedObjectForKey: (void*)key {
    return objc_getAssociatedObject(self, key);
}

- (void)searchPinYinAsyncWithKeyPath:(NSString *)keyPath searchString:(NSString *)searchString callback:(void(^)(NSArray *results))callback{
    
    [self searchPinYinAsyncWithKeyPath:keyPath searchString:searchString searchOption:0xffff callback:callback];
    
}

- (void)searchPinYinAsyncWithKeyPath:(NSString *)keyPath searchString:(NSString *)searchString searchOption:(SWPinyinSearchOptions)option callback:(void(^)(NSArray *results))callback{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_queue_create("SWPinYinSearcherNSArrayQueueKey", 0);
        [self setAssociatedObject:queue forKey:&SWPinYinSearcherNSArrayQueueKey];
    });
    
    dispatch_async([self associatedObjectForKey:&SWPinYinSearcherNSArrayQueueKey], ^{
        NSArray *result = [self searchPinYinWithKeyPath:keyPath searchString:searchString searchOption:option];
        if (callback) {
            callback(result);
        }
    });
    
}

- (NSArray *)searchPinYinWithKeyPath:(NSString *)keyPath searchString:(NSString *)searchString {
    return [self searchPinYinWithKeyPath:keyPath searchString:searchString searchOption:0xffff];
}

- (NSArray *)searchPinYinWithKeyPath:(NSString *)keyPath searchString:(NSString *)searchString searchOption:(SWPinyinSearchOptions)option {
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!searchString || [searchString isEqualToString:@""]) {
        return self;
    }
    NSArray *multiSearchStrings;
    if (SWPinyinSearchOptionsMultiSearch & option) {
        multiSearchStrings = [searchString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" /,"]];
    }
    NSPredicate *searchPinYinPredicate = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
        NSString *evaluateString;
        if (keyPath == nil) {
            evaluateString = obj;
        } else {
            evaluateString = [obj valueForKeyPath:keyPath];
        }
        NSArray *pinyinConbinations = [evaluateString toPinyinArray];
        NSArray *pinyinAcronymConbinations = [evaluateString toPinyinAcronymArray];
        __block BOOL containsFlag = NO;
        if ((SWPinyinSearchOptionsHanZi & option) && [self string:evaluateString swpys_containsString:searchString orOneOfStringInArray:multiSearchStrings] ) {
            containsFlag = YES;
        }
        if (!containsFlag && (SWPinyinSearchOptionsQuanPin & option)) {
            [pinyinConbinations enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                if ([self string:obj swpys_containsString:searchString orOneOfStringInArray:multiSearchStrings]) {
                    containsFlag = YES;
                    *stop = YES;
                }
            }];
        }
        if (!containsFlag && (SWPinyinSearchOptionsJianPin & option))  {
            [pinyinAcronymConbinations enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                if ([self string:obj swpys_containsString:searchString orOneOfStringInArray:multiSearchStrings]) {
                    containsFlag = YES;
                    *stop = YES;
                }
            }];
        }
        return containsFlag;
    }];
    return [self filteredArrayUsingPredicate:searchPinYinPredicate];
}

- (BOOL)string:(NSString *)evaluateString swpys_containsString:(NSString *)searchString orOneOfStringInArray:(NSArray *)searchStrings {
    if ([evaluateString swpys_containsString:searchString]) {
        return YES;
    }
    __block BOOL contains = NO;
    [searchStrings enumerateObjectsUsingBlock:^(NSString *oneSearchString, NSUInteger idx, BOOL *stop) {
        if ([evaluateString swpys_containsString:oneSearchString]) {
            contains = YES;
            *stop = YES;
        }
    }];
    return contains;
}

@end
