//
//  NSMutableArray.m
//  Project1
//
//  Created by 黄洪彬 on 2018/5/31.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import "NSMutableArray.h"

@implementation NSMutableArray(UniCode)

- (NSString*)my_description {
    NSString *desc = [self description];
    desc = [NSString stringWithCString:[desc cStringUsingEncoding:NSUTF8StringEncoding] encoding:NSNonLossyASCIIStringEncoding];
    return desc;
}

@end
