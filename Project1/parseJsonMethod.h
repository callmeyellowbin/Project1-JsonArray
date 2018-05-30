//
//  parseJsonMethod.h
//  Project1
//
//  Created by 黄洪彬 on 2018/5/30.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseJsonMethod : NSObject

@property (nonatomic, assign) NSDictionary *jsonDictionary;
@property (nonatomic, copy) NSMutableString *jsonString;
- (void) initWithJsonFile: (char *) path;
- (void) parseWithJsonString;
- (void) parseWithJsonStringByMySelf;
@end
