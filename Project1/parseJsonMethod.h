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
    int begin, end;
    NSString *beginChar;
    NSString *endChar;
    NSMutableArray *dict;
    NSMutableArray *subResultArray;
}
@property (nonatomic, assign) NSMutableDictionary *jsonDictionary;
@property (nonatomic, copy) NSMutableString *jsonString;
- (void) initWithJsonFile: (char *) path;
- (void) parseWithJsonString;
//- (void) parseWithJsonStringByMySelf;
- (BOOL) parseWithJsonStringArray: (NSArray*) array;
- (BOOL) parseWithJsonStringByMySelf;
@end
