//
//  BitWriter.m
//  Wilhelm
//
//  Created by Scott Bender on 8/31/16.
//  Copyright © 2016 Scott Bender. All rights reserved.
//

#import "BitWriter.h"

@implementation BitWriter
{
  Byte buffer;
  int n;
  NSMutableData *output;
}

- (instancetype)initWithData:(NSMutableData *)data
{
  self = [super init];
  output = data;
  return self;
}

- (void)clearBuffer
{
  if (n == 0) return;
  if (n > 0) buffer <<= (8 - n);
  
  char b = (char)buffer;
  [output appendBytes:&b length:1];
  n = 0;
  buffer = 0;
}

- (void)writeByte:(unsigned char)x
{
  [self _writeByte:x];
}

- (void)_writeByte:(unsigned char)x
{
  if (n == 0)
  {
	[output appendBytes:&x length:1];
	return;
  }
  
  @throw ([NSException exceptionWithName:@"BitWriterException" reason:@"NotOnByteBoundry" userInfo:nil]);
  }


- (void)write16Bit:(unsigned short)x
{
  x = NSSwapShort(x);
  [self _writeByte:(x >>  8) & 0xff];
  [self _writeByte:(x >>  0) & 0xff];
}

- (void)write32Bit:(unsigned int)x
{
  x = NSSwapInt(x);
  [self _writeByte:(x >>  24) & 0xff];
  [self _writeByte:(x >>  16) & 0xff];
  [self _writeByte:(x >>  8) & 0xff];
  [self _writeByte:(x >>  0) & 0xff];
}


- (void)writeBits:(Byte)val bits:(Byte)bits
{
  buffer = buffer ^ ( val << n );
  n += bits;
  if ( n == 8 )
	[self clearBuffer];

}

@end
