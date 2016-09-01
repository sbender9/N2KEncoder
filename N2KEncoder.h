//
//  N2KEncoder.h
//  Wilhelm
//
//  Created by Scott Bender on 9/1/16.
//  Copyright © 2016 Scott Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface N2KEncoder : NSObject

- (NSString *)encodeN2KMessage:(NSDictionary *)message;

@end
