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
    subResultArray = [[NSMutableArray alloc] init];
    //读入
    FILE *jsonFile = fopen(path, "r");
    char word[200];
    //初始化
    _jsonString = [NSMutableString stringWithCapacity: 50];
    _jsonDictionary = [NSMutableDictionary dictionaryWithCapacity: 50];
    _jsonArray = [NSMutableArray arrayWithCapacity: 50];
    //统计括号数量
    braceCount = 0;
    bracketCountForArray = 0;
    bracketCountForDictionary = 0;
    
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
    
    int begin = 0;
    int end = (int) [dict count] - 1;
    NSString *beginChar = dict[begin];
    NSString *endChar = dict[end];
    if ([beginChar isEqualToString: @"{"] && [endChar isEqualToString:@"}"]) {
        NSArray *subArray = [[NSArray alloc] init];
        subArray = [dict subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
        NSLog(@"subArray is: %@", subArray);
        _jsonArray = [self parseWithJsonStringDictionary: subArray];
        NSLog(@"here!");
        if (_jsonArray == nil)
            return NO;
        NSLog(@"result is: %@", [self jsonArray]);
    }
    else {
        return NO;
    }
    return YES;
}

- (int) findRightBracketIndex: (NSArray* ) array
{
    NSLog(@"%@ is a valid1!", array);
    int count = 0;
    for (int i = 0; i < [array count]; i++) {
        if ([array[i] isEqualToString: @"["])
            count++;
        if ([array[i] isEqualToString: @"]"]) {
            count--;
            //找到了最外层的数组
            if (count == 0)
                return i;
        }
    }
    NSLog(@"%@ is not a valid!", array);
    return -1;
}

- (int) findRightBraceIndex: (NSArray* ) array
{
    NSLog(@"%@ is a valid2!", array);
    int count = 0;
    for (int i = 0; i < [array count]; i++) {
        if ([array[i] isEqualToString: @"{"])
            count++;
        if ([array[i] isEqualToString: @"}"]) {
            count--;
            //找到了最外层的数组
            if (count == 0) {
                NSLog(@"count = 0 is %@", array[i]);
                return i;
            }
            
        }
    }
    NSLog(@"%@ is not a valid!", array);
    return -1;
}
- (NSMutableArray* ) parseWithJsonStringDictionary:(NSArray *)array
{
    
    //定义两个指针，一个从头遍历，一个从尾部遍历
    int begin = 0;
    int end = (int) [array count] - 1;
    NSString *beginChar = array[begin];
    NSString *endChar = array[end];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (![beginChar isEqualToString: @"{"] || ![endChar isEqualToString: @"}"])
        return nil;
    begin++;
    end--;
    
    //当两个指针相遇的时候，遍历完成
    while (begin <= end) {
        beginChar = array[begin];
        endChar = array[end];
        NSArray* subString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
        NSArray *subDictionary = [[NSArray alloc] init];
        NSInteger quoteIndex = [subString indexOfObject: @","];
        NSInteger leftBracketsIndex = [subString indexOfObject: @"["];
        NSInteger leftBraceIndex = [subString indexOfObject: @"{"];
        if (quoteIndex == NSNotFound) {
            //直到没找到逗号，则把最后的括号视为逗号
            subDictionary = subString;
            begin = end + 1;
            NSLog(@"Here is subArray4: %@", subString);
        }
        else {
            if (leftBracketsIndex == NSNotFound && leftBraceIndex == NSNotFound) {
                //获得逗号之前的数组
                subDictionary = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                begin += ((int) quoteIndex + 1);
                NSLog(@"Here is subDictionary5: %@", subDictionary);
                
            }
            else {
                int rightBraceIndex = [self findRightBraceIndex: subString];
                int rightBracketsIndex = [self findRightBracketIndex: subString];
                NSLog(@"end: %d", (int) [subString count]);
                NSLog(@"rightBraceIndex: %d", (int) rightBraceIndex);
                NSLog(@"leftBraceIndex: %d", (int) leftBraceIndex);
                NSLog(@"rightBracketsIndex: %d", (int) rightBracketsIndex);
                NSLog(@"leftBracketsIndex: %d", (int) leftBracketsIndex);
                NSLog(@"quoteIndex: %d", (int) quoteIndex);
                if (leftBraceIndex == NSNotFound) {
                    //有子数组没有子字典
                    if (leftBracketsIndex > quoteIndex) {
                        //逗号不属于子数组，则照常工作
                        subDictionary = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                        begin += ((int) quoteIndex + 1);
                        NSLog(@"Here is subDictionaryD: %@", subDictionary);
                    }
                    else {
                        NSArray* subBracketString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                        NSLog(@"Here is subDictionarysubBracketStringD: %@", subBracketString);
                        rightBracketsIndex = [self findRightBracketIndex: subBracketString];
                        if (rightBracketsIndex == -1)
                            return nil;
                        subDictionary = [subBracketString subarrayWithRange: NSMakeRange(0, (int) rightBracketsIndex + 1)];
                        NSLog(@"Here is subDictionary1: %@", subDictionary);
                        begin += ([subDictionary count]);
                        //看看下一位是不是逗号或者结束
                        if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                            begin++;
                        }
                        else
                            return nil;
                    }
                }
                else if (leftBracketsIndex == NSNotFound) {
                    //有子字典没有子数组
                    if (leftBraceIndex > quoteIndex) {
                        //逗号不属于子字典，则照常工作
                        subDictionary = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                        begin += ((int) quoteIndex + 1);
                        NSLog(@"Here is subDictionaryA: %@", subDictionary);
                    }
                    else {
                        //获得括号前的数组
                        NSArray* subBraceString = [array subarrayWithRange: NSMakeRange(begin, leftBraceIndex)];
                        NSLog(@"Here is subBraceStringArray: %@", subBraceString);
                        rightBraceIndex = [self findRightBraceIndex: subBraceString];
                        
                        if (rightBraceIndex == -1)
                            return nil;
                        subDictionary = [subBraceString subarrayWithRange: NSMakeRange(0, (int) rightBraceIndex + 1)];
                        NSLog(@"Here is subDictionary: %@", subDictionary);
                        
                        begin += ([subDictionary count]);
                        //                    NSLog(@"DICtionary begin2: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                        //看看下一位是不是逗号或者结束
                        if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                            begin++;
                        }
                        else
                            return nil;
                    }
                }
                else {
                    //有子字典没有子数组
                    if ((leftBracketsIndex > quoteIndex && leftBraceIndex > quoteIndex) ||
                        ((quoteIndex > rightBracketsIndex) && (quoteIndex < leftBraceIndex)) ||
                        ((quoteIndex > rightBracketsIndex) && (quoteIndex > rightBraceIndex)) ||
                        ((quoteIndex > rightBraceIndex) && (quoteIndex < leftBracketsIndex))) {
                        //]}, }],
                        //逗号不属于子数组或子字典，则照常工作
                        subDictionary = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                        begin += ((int) quoteIndex + 1);
                        NSLog(@"Here is subDictionaryB: %@", subDictionary);
                    }

                    else if ((leftBracketsIndex < leftBraceIndex && rightBracketsIndex > rightBraceIndex)) {
                        //,]} },]
                        //逗号属于数组
                        NSArray* subBracketString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                        NSLog(@"Here is subBracketArryB: %@", subBracketString);
                        rightBracketsIndex = [self findRightBracketIndex: subBracketString];
                        if (rightBracketsIndex == -1)
                            return nil;
                        subDictionary = [subBracketString subarrayWithRange: NSMakeRange(0, (int) rightBracketsIndex + 1)];
                        NSLog(@"Here is subDictionary1: %@", subDictionary);
                        begin += ([subDictionary count]);
                        //                    NSLog(@"DICtionary begin1: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                        //看看下一位是不是逗号或者结束
                        if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                            begin++;
                        }
                        else
                            return nil;
                    }
                    else if ((leftBraceIndex < leftBracketsIndex && rightBraceIndex > rightBracketsIndex)) {
                        //],} ,}]
                        //逗号属于字典
                        NSArray* subBraceString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                        NSLog(@"Here is subBraceArray: %@", subBraceString);
                        rightBraceIndex = [self findRightBraceIndex: subBraceString];
                        
                        if (rightBraceIndex == -1)
                            return nil;
                        subDictionary = [subBraceString subarrayWithRange: NSMakeRange(0, (int) rightBraceIndex + 1)];
                        NSLog(@"Here is subDictionary2: %@", subDictionary);
                        
                        begin += ([subDictionary count]);
                        //                    NSLog(@"DICtionary begin2: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                        //看看下一位是不是逗号或者结束
                        if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"] || [array[begin] isEqualToString: @"]"]) {
                            begin++;
                        }
                        else
                            return nil;
                    }
                    else if (rightBracketsIndex < rightBraceIndex) {
                        //逗号属于数组
                        NSArray* subBracketString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                        NSLog(@"Here is subBracketArryB: %@", subBracketString);
                        rightBracketsIndex = [self findRightBracketIndex: subBracketString];
                        if (rightBracketsIndex == -1)
                            return nil;
                        subDictionary = [subBracketString subarrayWithRange: NSMakeRange(0, (int) rightBracketsIndex + 1)];
                        NSLog(@"Here is subDictionary1: %@", subDictionary);
                        begin += ([subDictionary count]);
                        //                    NSLog(@"DICtionary begin1: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                        //看看下一位是不是逗号或者结束
                        if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                            begin++;
                        }
                        else
                            return nil;
                    }
                    else if (rightBraceIndex < rightBracketsIndex) {
                        //逗号属于字典
                        NSArray* subBraceString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                        NSLog(@"Here is subBraceArray: %@", subBraceString);
                        rightBraceIndex = [self findRightBraceIndex: subBraceString];
                        
                        if (rightBraceIndex == -1)
                            return nil;
                        subDictionary = [subBraceString subarrayWithRange: NSMakeRange(0, (int) rightBraceIndex + 1)];
                        NSLog(@"Here is subDictionary2: %@", subDictionary);
                        
                        begin += ([subDictionary count]);
                        //                    NSLog(@"DICtionary begin2: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                        //看看下一位是不是逗号或者结束
                        if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"] || [array[begin] isEqualToString: @"]"]) {
                            begin++;
                        }
                        else
                            return nil;
                    }
                    else
                        return nil;
                }
            }
            
        }
        NSLog(@"subDictionary: %@", subDictionary);
        id jsonResult = nil;
        jsonResult = [self parseDictionary: subDictionary];
        if (jsonResult == nil)
            return nil;
         NSLog(@"jsonResult: %@", jsonResult);
        [result addObject: jsonResult];
    }
    NSLog(@"Result dictionary is: %@", result);
    return result;
}

- (id) parseDictionary: (NSArray *)array
{
    int begin = 0;
    int end = (int) [array count] - 1;
    NSString *beginChar = array[begin];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSMutableString *key = [[NSMutableString alloc] init];
//    if (![beginChar isEqualToString: @"{"] || ![endChar isEqualToString: @"}"])
//        return nil;
    //        begin++;
    //        end--;
    if ([beginChar isEqualToString: @"\""]) {
        //花括号后面跟引号
        begin++;
        //从开始的指针找
        NSInteger quoteIndex = [array indexOfObject: @"\"" inRange: NSMakeRange(begin, end - begin + 1)];
        
        if (quoteIndex == NSNotFound) {
            //没找到引号
            return nil;
        }
        for (int i = begin; i < quoteIndex; i++) {
            [key appendString: array[i]];
        }
        NSLog(@"here is key: %@", key);
        //找到了key
        //            [_jsonDictionary setObject: [NSNull null] forKey:key];
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
                NSMutableArray *father = [[NSMutableArray alloc] init];
                father = [self parseWithJsonStringDictionary: subArray];
                if (father == nil)
                    return nil;
                [result setObject: father forKey: key];
            }
            else {
                //是一个元素
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
    NSString *beginChar = [NSString stringWithString: array[begin]];
    if ([beginChar isEqualToString: @"\""]) {
        //处理key
        //从开始的指针找
        begin++;
        NSInteger quoteIndex = [array indexOfObject: @"\"" inRange: NSMakeRange(begin, end - begin + 1)];
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
            NSArray* subString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
            NSLog(@"3subString: %@", subString);
            NSInteger quoteIndex = [subString indexOfObject: @","];
            NSInteger leftBracketsIndex = [subString indexOfObject: @"["];
            NSInteger leftBraceIndex = [subString indexOfObject: @"{"];
            if (quoteIndex == NSNotFound) {
                //直到没找到逗号，则把最后的括号视为逗号
                subArray = subString;
                begin = end + 1;
                NSLog(@"Here is subArray4: %@", subString);
            }
            else {
                if (leftBracketsIndex == NSNotFound && leftBraceIndex == NSNotFound) {
                    //获得逗号之前的数组
                    subArray = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                    begin += ((int) quoteIndex + 1);
                    NSLog(@"Here is subArray5: %@", subArray);
                    
                }
                else {
                    int rightBraceIndex = [self findRightBraceIndex: subString];
                    int rightBracketsIndex = [self findRightBracketIndex: subString];
                    if (leftBraceIndex == NSNotFound) {
                        //有子数组没有子字典
                        if (leftBracketsIndex > quoteIndex) {
                            //逗号不属于子数组，则照常工作
                            subArray = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                            begin += ((int) quoteIndex + 1);
                            NSLog(@"Here is subArrayD: %@", subArray);
                        }
                        else {
                            NSArray* subBracketString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                            NSLog(@"Here is subArraysubBracketStringD: %@", subBracketString);
                            rightBracketsIndex = [self findRightBracketIndex: subBracketString];
                            if (rightBracketsIndex == -1)
                                return nil;
                            subArray = [subBracketString subarrayWithRange: NSMakeRange(0, (int) rightBracketsIndex + 1)];
                            NSLog(@"Here is subArray1: %@", subArray);
                            begin += ([subArray count]);
                            //看看下一位是不是逗号或者结束
                            if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                                begin++;
                            }
                            else
                                return nil;
                        }
                    }
                    else if (leftBracketsIndex == NSNotFound) {
                        //有子字典没有子数组
                        if (leftBraceIndex > quoteIndex) {
                            //逗号不属于子字典，则照常工作
                            subArray = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                            begin += ((int) quoteIndex + 1);
                            NSLog(@"Here is subArrayA: %@", subArray);
                        }
                        else {
                            //获得括号前的数组
                            NSArray* subBraceString = [array subarrayWithRange: NSMakeRange(begin, leftBraceIndex)];
                            NSLog(@"Here is subBraceStringArray: %@", subBraceString);
                            rightBraceIndex = [self findRightBraceIndex: subBraceString];
                            
                            if (rightBraceIndex == -1)
                                return nil;
                            subArray = [subBraceString subarrayWithRange: NSMakeRange(0, (int) rightBraceIndex + 1)];
                            NSLog(@"Here is subArray: %@", subArray);
                            
                            begin += ([subArray count]);
                            //                    NSLog(@"DICtionary begin2: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                            //看看下一位是不是逗号或者结束
                            if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                                begin++;
                            }
                            else
                                return nil;
                        }
                    }
                    else {
                        //有子字典没有子数组
                        if ((leftBracketsIndex > quoteIndex && leftBraceIndex > quoteIndex) ||
                            ((quoteIndex > rightBracketsIndex) && (quoteIndex < leftBraceIndex)) ||
                            ((quoteIndex > rightBracketsIndex) && (quoteIndex > rightBraceIndex)) ||
                            ((quoteIndex > rightBraceIndex) && (quoteIndex < leftBracketsIndex))) {
                            //]}, }],
                            //逗号不属于子数组或子字典，则照常工作
                            subArray = [array subarrayWithRange: NSMakeRange(begin, (int) quoteIndex)];
                            begin += ((int) quoteIndex + 1);
                            NSLog(@"Here is subArrayB: %@", subArray);
                        }
                        else if ((leftBracketsIndex < leftBraceIndex && rightBracketsIndex > rightBraceIndex)) {
                            //,]} },]
                            //逗号属于数组
                            NSArray* subBracketString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                            NSLog(@"Here is subBracketArryB: %@", subBracketString);
                            rightBracketsIndex = [self findRightBracketIndex: subBracketString];
                            if (rightBracketsIndex == -1)
                                return nil;
                            subArray = [subBracketString subarrayWithRange: NSMakeRange(0, (int) rightBracketsIndex + 1)];
                            NSLog(@"Here is subArray1: %@", subArray);
                            begin += ([subArray count]);
                            //                    NSLog(@"DICtionary begin1: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                            //看看下一位是不是逗号或者结束
                            if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                                begin++;
                            }
                            else
                                return nil;
                        }
                        else if ((leftBraceIndex < leftBracketsIndex && rightBraceIndex > rightBracketsIndex)) {
                            //],} ,}]
                            //逗号属于字典
                            NSArray* subBraceString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                            NSLog(@"Here is subBraceArray: %@", subBraceString);
                            rightBraceIndex = [self findRightBraceIndex: subBraceString];
                            
                            if (rightBraceIndex == -1)
                                return nil;
                            subArray = [subBraceString subarrayWithRange: NSMakeRange(0, (int) rightBraceIndex + 1)];
                            NSLog(@"Here is subArray2: %@", subArray);
                            
                            begin += ([subArray count]);
                            //                    NSLog(@"DICtionary begin2: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                            //看看下一位是不是逗号或者结束
                            if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"] || [array[begin] isEqualToString: @"]"]) {
                                begin++;
                            }
                            else
                                return nil;
                        }
                        else if (rightBracketsIndex < rightBraceIndex) {
                            //逗号属于数组
                            NSArray* subBracketString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                            NSLog(@"Here is subBracketArryB: %@", subBracketString);
                            rightBracketsIndex = [self findRightBracketIndex: subBracketString];
                            if (rightBracketsIndex == -1)
                                return nil;
                            subArray = [subBracketString subarrayWithRange: NSMakeRange(0, (int) rightBracketsIndex + 1)];
                            NSLog(@"Here is subArray1: %@", subArray);
                            begin += ([subArray count]);
                            //                    NSLog(@"DICtionary begin1: %@%@%@", array[begin - 1], array[begin], array[begin + 1]);
                            //看看下一位是不是逗号或者结束
                            if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"]) {
                                begin++;
                            }
                            else
                                return nil;
                        }
                        else if (rightBraceIndex < rightBracketsIndex) {
                            //逗号属于字典
                            NSArray* subBraceString = [array subarrayWithRange: NSMakeRange(begin, end - begin + 1)];
                            rightBraceIndex = [self findRightBraceIndex: subBraceString];
                            
                            if (rightBraceIndex == -1)
                                return nil;
                            subArray = [subBraceString subarrayWithRange: NSMakeRange(0, (int) rightBraceIndex + 1)];
                            
                            begin += ([subArray count]);
                            //看看下一位是不是逗号或者结束
                            if ([array[begin] isEqualToString: @","] || [array[begin] isEqualToString: @"}"] || [array[begin] isEqualToString: @"]"]) {
                                begin++;
                            }
                            else
                                return nil;
                        }
                        else
                            return nil;
                    }
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
    else if ([beginChar isEqualToString: @"{"]) {
        NSLog(@"ARRAY:%@", array);
        id jsonResult = nil;
        jsonResult = [self parseWithJsonStringDictionary: array];
        if (jsonResult == nil)
            return nil;
        [result addObject: jsonResult];
        return result;
    }
    else {
        return nil;
    }

}


@end

