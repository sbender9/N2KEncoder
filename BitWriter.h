//
//  BitWriter.h
//  Wilhelm
//
//  Created by Scott Bender on 8/31/16.
//  Copyright © 2016 Scott Bender. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitWriter : NSObject

- (instancetype)initWithData:(NSMutableData *)data;

- (void)writeByte:(unsigned char)number;
- (void)write16Bit:(unsigned short)number;
- (void)write32Bit:(unsigned int)number;
- (void)writeBits:(Byte)number bits:(Byte)bits;

@end
