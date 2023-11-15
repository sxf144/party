//
//  NSString+LSAdd.m
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

#import "NSString+LSAdd.h"

@implementation NSString (LSAdd)


- (NSString*) oc_urlEncoded {
    
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef) self,
                                                                        nil,
                                                                        CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\|~ "),
                                                                        kCFStringEncodingUTF8);
    
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];

    if(!encodedString)
        encodedString = @"";
    
    return encodedString;
}


@end
