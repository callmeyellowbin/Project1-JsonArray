//
//  parseJsonMethod.h
//  Project1
//
//  Created by 黄洪彬 on 2018/5/30.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray.h"
@interface ParseJsonMethod : NSObject
{
    NSMutableArray *dict;
    NSMutableArray *subResultArray;
    int braceCount, bracketCountForDictionary, bracketCountForArray;
}

- (void) setDict: (NSMutableArray* ) dict;
@property (nonatomic, copy) NSMutableDictionary *jsonDictionary;
@property (nonatomic, copy) NSMutableDictionary *jsonDictionaryRsult;
@property (nonatomic, copy) NSMutableString *jsonString;
@property (nonatomic, copy) NSMutableArray *jsonArray;
@property (nonatomic, assign) int resultType;
- (NSString *) getStringWithJsonFile: (char *) path;
- (void) parseWithJsonString;

+ (id) JsonObjectWithString: (NSString *) jsonStr;

- (BOOL) parseWithJsonStringByMySelf;
@end
