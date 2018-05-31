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
    //获得key
    NSMutableString *key = [[NSMutableString alloc] init];
    begin = 0;
    end = (int) [dict count] - 1;
    beginChar = dict[begin];
    endChar = dict[end];
    while (begin < end) {
        if ([beginChar isEqualToString: @"{"] && [endChar isEqualToString:@"}"]) {
            //指针移动
            [self updateBeginChar];
            [self updateEndChar];
            if ([beginChar isEqualToString: @"\""]) {
                //花括号后面跟引号
                [self updateBeginChar];
                //从开始的指针找
                NSInteger quoteIndex = [dict indexOfObject: @"\"" inRange: NSMakeRange(begin, end - begin)];
//                int quoteIndex = [dict reverseIndexOfObject: @"\"" fromBegin: begin andEnd: end];
                NSLog(@"index is: %d", quoteIndex);
                
                if (quoteIndex == -1) {
                    //没找到引号
                    return NO;
                }
                for (int i = begin; i < quoteIndex; i++) {
                    [key appendString: dict[i]];
                }
                NSLog(@"here is key: %@", key);
                
                [_jsonDictionary setObject: [NSNull null] forKey:key];
                //再次右移
                begin = (int) quoteIndex + 1;
                beginChar = [NSString stringWithString: dict[begin]];
                //判断后面是否跟冒号
                if ([beginChar isEqualToString: @":"]) {
                    [self updateBeginChar];
                    NSArray *subArray = [[NSArray alloc] init];
                    subArray = [dict subarrayWithRange: NSMakeRange(begin, end - begin)];
                    //字典方法
//                    if (![self parseWithJsonStringDictionary: subArray forKey: key])
//                        return NO;
                }
                else {
                    return NO;
                }
            }
        }
        else {
            return NO;
        }
        
        if ([beginChar isEqualToString: @"["]) {
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            int arrayIndex;
            int count = 0;
            int beginOfArray = begin;
            int endOfArray = begin;
            while ([beginChar isEqualToString: @"["]) {
                //连续嵌套
                count++;
                [self updateBeginChar];
                beginOfArray = begin;
            }
            NSLog(@"count: %d", count);
            NSLog(@"begin: %d", begin);
            while (count > 0 && beginOfArray < end) {
                while (![dict[beginOfArray] isEqualToString: @"]"]) {
                    if (beginOfArray >= end) {
                        return NO;
                    }
                    //直到找到]为止
                    beginOfArray++;
                }
                NSLog(@"beginOfArray: %d", beginOfArray);
                NSLog(@"begin: %d", begin);
                if ([dict[beginOfArray] isEqualToString: @"]"]) {
                    //找到了一个
                    count--;
                    NSArray *subSubArray = [[NSArray alloc] init];
                    subSubArray = [dict subarrayWithRange: NSMakeRange(begin, beginOfArray - begin)];
                    if ([self parseWithJsonStringArray: subSubArray]) {
                        NSLog(@"here is another_key: %@", key);
                        //嵌套，加一层
                        NSArray *result = [NSArray arrayWithArray: subResultArray];
                        [subArray addObject: result];
                        //记得清空
                        [subResultArray removeAllObjects];
                    }
                }
            }
            NSLog(@"Begin: %@, End: %@", beginChar, endChar);
            [self updateBeginChar];
            _jsonDictionary[key] = subArray;
            NSLog(@"Complete! dict: %@", _jsonDictionary);
        }
        else
            //没找到框
            return NO;
    }
    return YES;
}

- (BOOL) parseWithJsonStringDictionary:(NSArray *)array forKey: (NSMutableString *)key
{
    //定义两个指针，一个从头遍历，一个从尾部遍历
    int begin = 0;
    int end = (int) [array count] - 1;
    NSArray *numberArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    //当两个指针相遇的时候，遍历完成
    while (begin <= end) {
        beginChar = [NSString stringWithString: array[begin]];
        endChar = [NSString stringWithString: array[end]];
        if ([beginChar isEqualToString: @"\""]) {
            //处理key
            
            
        }
        else if ([beginChar isEqualToString: @"n"]) {
            //处理null
        }
        else if ([beginChar isEqualToString: @"t"]) {
            //处理true
        }
        else if ([numberArray containsObject: beginChar]) {
            //处理数字
            if ([array containsObject: @"."]) {
                
            }
        }
        else {
            return NO;
        }
    }
    return YES;
}

-(BOOL) parseWithJsonStringArray:(NSMutableArray *)array
{
    //定义两个指针，一个从头遍历，一个从尾部遍历
    int begin = 0;
    int end = (int) [array count] - 1;
    NSArray *numberArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0"];
    NSLog(@"array: %@", array);
    NSLog(@"begin: %d, end: %d", begin, end);
    //当两个指针相遇的时候，遍历完成
    while (begin <= end) {
        NSLog(@"BBBBegin, begin: %d, end: %d", begin, end);
        beginChar = [NSString stringWithString: array[begin]];
        endChar = [NSString stringWithString: array[end]];
        NSLog(@"begin: %@, end: %@", beginChar, endChar);
        if ([beginChar isEqualToString: @"\""]) {
            //处理key
            //从开始的指针找
            begin++;
            beginChar = array[begin];
            NSLog(@"Array, begin: %d, end: %d", begin, end);
            NSInteger quoteIndex = [array indexOfObject: @"\"" inRange: NSMakeRange(begin, end - begin)];
//            NSInteger quoteIndex = [array reverseIndexOfObject: @"\"" fromBegin: begin andEnd: end];
//            NSLog(@"index is: %d", quoteIndex);
            if (quoteIndex == NSNotFound) {
                //没找到引号
                return NO;
            }
            //获得key
            NSMutableString *key = [[NSMutableString alloc] init];
            NSLog(@"array, begin: %@", beginChar);
            NSLog(@"array, begin: %@", beginChar);
            for (int i = begin; i < quoteIndex; i++) {
                NSLog(@"array[i]: %@", array[i]);
                [key appendString: array[i]];
            }
            [subResultArray addObject: key];
            begin = (int) quoteIndex + 1;
            NSLog(@"array, key: %@", key);
        }
        else if ([beginChar isEqualToString: @"n"]) {
            
            //处理null
            if (begin + 3 <= end) {
                if ([array[begin + 1] isEqualToString: @"u"] &&
                    [array[begin + 2] isEqualToString: @"l"] &&
                    [array[begin + 3] isEqualToString: @"l"]) {
                    [subResultArray addObject: [NSNull null]];
                    NSLog(@"null");
                    begin += 4;
                }
                else
                    return NO;
            }
            else
                return NO;
        }
        else if ([beginChar isEqualToString: @"t"]) {
            //处理true
            if (begin + 3 <= end) {
                if ([array[begin + 1] isEqualToString: @"r"] &&
                    [array[begin + 2] isEqualToString: @"u"] &&
                    [array[begin + 3] isEqualToString: @"e"]) {
                    [subResultArray addObject: [NSNumber numberWithBool: YES]];
                    NSLog(@"true");
                    begin += 4;
                }
                
                else
                    return NO;
            }
            else
                return NO;
        }
        else if ([beginChar isEqualToString: @"f"]) {
            //处理true
            if (begin + 4 <= end) {
                if ([array[begin + 1] isEqualToString: @"a"] &&
                    [array[begin + 2] isEqualToString: @"l"] &&
                    [array[begin + 3] isEqualToString: @"s"] &&
                    [array[begin + 4] isEqualToString: @"e"]) {
                    [subResultArray addObject: [NSNumber numberWithBool: NO]];
                    NSLog(@"false");
                    begin += 5;
                }
                
                else
                    return NO;
            }
            else
                return NO;
        }
        else if ([numberArray containsObject: beginChar]) {
            NSLog(@"number: %@", beginChar);
            NSMutableString *key = [[NSMutableString alloc] init];
            while ([numberArray containsObject: beginChar]) {
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
                [subResultArray addObject: ([NSNumber numberWithInt: value])];
            }
            else if ([self isPureFloat: key]){
                float value = [key floatValue];
                [subResultArray addObject: ([NSNumber numberWithFloat: value])];
            }
            else {
                return NO;
            }
        }
        else {
            return NO;
        }
        if (begin >= end) {
            //结束该数组
            return YES;
        }
        beginChar = array[begin];
        NSLog(@"beginChar: %@", beginChar);
        if ([beginChar isEqualToString: @","]) {
            NSLog(@"begin: %d, end: %d", begin, end);
            //接逗号
            begin++;
        }
        else
            return NO;
    }
    return YES;
}
@end

