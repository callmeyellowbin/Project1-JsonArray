//
//  parseJsonMethod.m
//  Project1
//
//  Created by 黄洪彬 on 2018/5/30.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import "parseJsonMethod.h"
#import "NSDictionary.h"
@implementation ParseJsonMethod

@synthesize jsonString = _jsonString;
@synthesize jsonDictionary = _jsonDictionary;

//定义两个指针，一个从头遍历，一个从尾部遍历


-(void) initWithJsonFile:(char *)path
{
    //忘了初始化就会null
    dict = [[NSMutableArray alloc] init];
    beginChar = [[NSString alloc] init];
    endChar = [[NSString alloc] init];
    subResultArray = [[NSMutableArray alloc] init];
    //读入
    FILE *jsonFile = fopen(path, "r");
    char word[200];
    //初始化NSString
    _jsonString = [NSMutableString stringWithCapacity: 50];
    _jsonDictionary = [NSMutableDictionary dictionaryWithCapacity: 50];
    while (fgets(word, 200, jsonFile)) {
        //获取文本内容
        NSString *tmp = [NSString stringWithUTF8String: word];
        [_jsonString appendString: tmp];
        //去掉所有空格和换行
        tmp = [tmp stringByReplacingOccurrencesOfString:@" " withString:@""];
        tmp = [tmp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        tmp = [tmp stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        tmp = [tmp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        for (int i = 0; i < [tmp length]; i++) {
            //转成一个个字符读取
            NSString *subChar = [tmp substringWithRange:NSMakeRange(i, 1)];
            [dict addObject: subChar];
        }
    }
//    NSLog(@"dict: %@", dict);
}


- (void) parseWithJsonString
{
    //将json数据解码
    NSData* jsonData;
    jsonData = [_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        _jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData
                                                  options:NSJSONReadingMutableContainers
                                                               error: nil];
    }
}

- (void) updateBeginChar
{
    begin++;
    beginChar = [NSString stringWithString: dict[begin]];
}

- (void) updateEndChar
{
    end--;
    endChar = [NSString stringWithString: dict[end]];
}

//判断是否为整形：

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：

- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

- (BOOL) parseWithJsonStringByMySelf
{
//    NSMutableArray *array = [[NSMutableArray alloc] init];
    //定义两个指针，一个从头遍历，一个从尾部遍历
    
    begin = 0;
    end = (int) [dict count] - 1;
    beginChar = dict[begin];
    endChar = dict[end];
    count = 0;
    if ([beginChar isEqualToString: @"{"] && [endChar isEqualToString:@"}"]) {
        NSArray *subArray = [[NSArray alloc] init];
        subArray = [dict subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
        NSLog(@"subArray is: %@", subArray);
        _jsonDictionary = [self parseWithJsonStringDictionary: subArray];
        NSLog(@"here!");
        if (_jsonDictionary == nil)
            return NO;
//        NSLog(@"result is: %@", [self jsonDictionary]);
    }
    else {
        return NO;
    }
    return YES;
}


- (NSMutableDictionary* ) parseWithJsonStringDictionary:(NSArray *)array
{
    //定义两个指针，一个从头遍历，一个从尾部遍历
    int begin = 0;
    int end = (int) [array count] - 1;
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSMutableString *key = [[NSMutableString alloc] init];
    //当两个指针相遇的时候，遍历完成
//    while (begin < end) {
        beginChar = array[begin];
        endChar = array[end];
        if (![beginChar isEqualToString: @"{"] || ![endChar isEqualToString: @"}"])
            return nil;
        begin++;
        end--;
        beginChar = array[begin];
        endChar = array[end];
        if ([beginChar isEqualToString: @"\""]) {
            //花括号后面跟引号
            begin++;
            //从开始的指针找
            NSInteger quoteIndex = [array indexOfObject: @"\"" inRange: NSMakeRange(begin, end - begin)];
            if (quoteIndex == NSNotFound) {
                //没找到引号
                return nil;
            }
            for (int i = begin; i < quoteIndex; i++) {
                [key appendString: array[i]];
            }
            NSLog(@"here is key: %@", key);
            
            [_jsonDictionary setObject: [NSNull null] forKey:key];
            //再次右移
            begin = (int) quoteIndex + 1;
            beginChar = array[begin];
            //判断后面是否跟冒号
            if ([beginChar isEqualToString: @":"]) {
                begin++;
                beginChar = array[begin];
                NSArray *subArray = [[NSArray alloc] init];
                NSLog(@"end: %d", end);
                NSLog(@"begin: %d", begin);
                subArray = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                
                NSLog(@"subDict: %@", subArray);
                if ([beginChar isEqualToString: @"{"]) {
                    //是一个字典
                    NSMutableDictionary *father = [[NSMutableDictionary alloc] init];
                    father = [self parseWithJsonStringDictionary: subArray];
                    if (father == nil)
                        return nil;
                    [result setObject: father forKey: key];
                }
                else {
                    //是一个数组
                    NSMutableArray *father = [[NSMutableArray alloc] init];
                    father = [self parseWithJsonStringArray: subArray];
                    if (father == nil)
                        return nil;
                    [result setObject: father forKey: key];
                }
            }
            else {
                return nil;
            }
        }
//    }
    NSLog(@"Result dictionary is: %@", result);
    return result;
}

- (id) parseWithJsonStringArray:(NSMutableArray *)array
{
    //定义两个指针，一个从头遍历，一个从尾部遍历
    int begin = 0;
    int end = (int) [array count] - 1;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *numberArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    //当两个指针相遇的时候，遍历完成
//    while (begin < end) {
        beginChar = [NSString stringWithString: array[begin]];
        endChar = [NSString stringWithString: array[end]];
    if ([beginChar isEqualToString: @"\""]) {
        //处理key
        //从开始的指针找
        begin++;
        beginChar = array[begin];
        NSInteger quoteIndex = [array indexOfObject: @"\"" inRange: NSMakeRange(begin, end - begin)];
        if (quoteIndex == NSNotFound) {
            //没找到引号
            return nil;
        }
        //获得key
        NSMutableString *key = [[NSMutableString alloc] init];
        for (int i = begin; i < quoteIndex; i++) {
            [key appendString: array[i]];
        }
//        NSMutableArray *result = [[NSMutableArray alloc] init];
//        [result addObject: key];
        begin = (int) quoteIndex + 1;
        NSLog(@"array, key: %@", key);
        return key;
    }
    else if ([beginChar isEqualToString: @"n"]) {
        //处理null
        if (begin + 3 <= end) {
            if ([array[begin + 1] isEqualToString: @"u"] &&
                [array[begin + 2] isEqualToString: @"l"] &&
                [array[begin + 3] isEqualToString: @"l"]) {
//                NSMutableArray *result = [[NSMutableArray alloc] init];
//                [result addObject: [NSNull null]];
                NSLog(@"null");
                begin += 4;
                return [NSNull null];
            }
            else
                return nil;
        }
        else
            return nil;
    }
    else if ([beginChar isEqualToString: @"t"]) {
        //处理true
        if (begin + 3 <= end) {
            if ([array[begin + 1] isEqualToString: @"r"] &&
                [array[begin + 2] isEqualToString: @"u"] &&
                [array[begin + 3] isEqualToString: @"e"]) {
//                NSMutableArray *result = [[NSMutableArray alloc] init];
//                [result addObject: [NSNumber numberWithBool: YES]];
                NSLog(@"true");
                begin += 4;
                return [NSNumber numberWithBool: YES];
            }
            
            else
                return nil;
        }
        else
            return nil;
    }
    else if ([beginChar isEqualToString: @"f"]) {
        //处理true
        if (begin + 4 <= end) {
            if ([array[begin + 1] isEqualToString: @"a"] &&
                [array[begin + 2] isEqualToString: @"l"] &&
                [array[begin + 3] isEqualToString: @"s"] &&
                [array[begin + 4] isEqualToString: @"e"]) {
//                NSMutableArray *result = [[NSMutableArray alloc] init];
//                [result addObject: [NSNumber numberWithBool: NO]];
                NSLog(@"false");
                begin += 5;
                return [NSNumber numberWithBool: NO];
            }
            
            else
                return nil;
        }
        else
            return nil;
    }
    else if ([numberArray containsObject: beginChar]) {
        NSLog(@"number: %@", beginChar);
        NSMutableString *key = [[NSMutableString alloc] init];
        while ([numberArray containsObject: beginChar]) {
            //获取数字字符串
            NSLog(@"beginChar: %@", beginChar);
            [key appendString: beginChar];
            begin++;
            if (begin < end) {
                beginChar = [NSString stringWithString: array[begin]];
            }
            else
                break;
        }
        NSLog(@"key: %@", key);
        //处理数字
        if ([self isPureInt: key]) {
            NSLog(@"key: int");
            int value = [key intValue];
//            NSMutableArray *result = [[NSMutableArray alloc] init];
//            [result addObject: ([NSNumber numberWithInt: value])];
            return [NSNumber numberWithInt: value];
        }
        else if ([self isPureFloat: key]){
            float value = [key floatValue];
            
//            [result addObject: ([NSNumber numberWithFloat: value])];
            return [NSNumber numberWithFloat: value];
        }
        else {
            return nil;
        }
    }
    else if ([beginChar isEqualToString: @"["]) {
        //传进来的是[]
        if (![array[end] isEqualToString: @"]"])
            return nil;
        begin++;
        end--;
        while (begin <= end) {
            NSArray *subArray = [[NSMutableArray alloc] init];
            NSInteger quoteIndex = [array indexOfObject: @"," inRange: NSMakeRange(begin, end - begin + 1)];
            NSInteger leftBracketsIndex = [array indexOfObject: @"[" inRange: NSMakeRange(begin, end - begin + 1)];
            if (quoteIndex == NSNotFound) {
                //直到没找到引号，则把最后的括号视为逗号
                quoteIndex = end + 1;
            }
            NSLog(@"array: %@", array);
            if (leftBracketsIndex == NSNotFound) {
                //获得逗号之前的数组
                subArray = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex - begin)];
                begin = (int) quoteIndex + 1;
            }
            else {
                if (leftBracketsIndex > quoteIndex) {
                    //逗号不属于子数组，则照常工作
                    subArray = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex - begin)];
                    begin = (int) quoteIndex + 1;
                }
                else {
                    //逗号属于子数组,则跳过该子数组，将其视为一个整体
                    NSInteger rightBracketsIndex = [array indexOfObject: @"]" inRange: NSMakeRange(begin, end - begin + 1)];
                    if (rightBracketsIndex == NSNotFound || rightBracketsIndex >= end + 1)
                        return nil;
                    subArray = [array subarrayWithRange: NSMakeRange(begin, (int) rightBracketsIndex - begin + 1)];
                    begin = (int) rightBracketsIndex + 1;
                    //看看下一位是不是逗号或者结束
                    if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                        begin++;
                    }
                    else
                        return nil;
                }
            }
            NSLog(@"SubArray: %@", subArray);
            id jsonResult = nil;
            jsonResult = [self parseWithJsonStringArray: subArray];
            if (jsonResult == nil)
                return nil;
            [result addObject: jsonResult];
            
        }
        return result;
    }
    else {
        return nil;
    }

}


@end

