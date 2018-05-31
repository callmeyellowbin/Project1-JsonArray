//
//  NSMutableArray.m
//  Project1
//
//  Created by 黄洪彬 on 2018/5/31.
//  Copyright © 2018年 黄洪彬. All rights reserved.
//

#import "NSMutableArray.h"

@implementation NSMutableArray(Reverse)

-(int) reverseIndexOfObject:(NSString *)string fromBegin:(int)begin andEnd:(int)end
{
    for (int i = end; i >= begin; i--) {
        NSString *str = [self objectAtIndex: i];
        NSLog(@"string is : %@", str);
        NSString *cmpstr = [string substringWithRange:NSMakeRange(0, 1)];
        if ([str isEqualToString: cmpstr])
            return i;
    }
    return -1;
}
@end
