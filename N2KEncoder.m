//
//  N2KEncoder.m
//  Wilhelm
//
//  Created by Scott Bender on 9/1/16.
//  Copyright © 2016 Scott Bender. All rights reserved.
//

#import "N2KEncoder.h"
#import "BitWriter.h"

@interface N2KEncoder ()

@property (nullable,strong,atomic) NSDictionary *n2k_pgns;

@end

@implementation N2KEncoder

- (instancetype)init
{
  self = [super init];
  
  NSString* configFile = [[NSBundle mainBundle] pathForResource:@"pgns" ofType:@"json"];

  NSData *data = [NSData dataWithContentsOfFile:configFile];
  NSError *error;
  self.n2k_pgns = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

  return self;
}


- (float)deg2rad:(float)deg
{
  float conv_factor = (2.0 * M_PI)/360.0;
  
  return(deg * conv_factor);
}


- (double)convertUnits:(double)val units:(NSString *)units
{
  if ( units == nil )
	return val;
  
  units = [units lowercaseString];
  
  if ( [units isEqualToString:@"rad"] )
	val = [self deg2rad:val];
  else if ( [units isEqualToString:@"hpa"] )
	val = val / 100;
  else if ( [units isEqualToString:@"kpa"] )
	val = val / 1000;
  else if ( [units isEqualToString:@"dpa"] )
	val = val * 10;
  else if ( [units isEqualToString:@"k"] )
	val = val + 273.15;
  
  return val;
}

- (NSString *)encodeN2KMessage:(NSDictionary *)message
{
  NSString *pgn = message[@"pgn"];
  NSInteger priority = ((NSNumber *)message[@"priority"]).integerValue;
  NSInteger dest = ((NSNumber *)message[@"destination"]).integerValue;
  NSDictionary *pgn_info = self.n2k_pgns[@"PGNs"][pgn];
  NSInteger source = 0; //Set by NTG
  
  if ( pgn_info == nil )
	return nil; //error
  
  NSInteger length = ((NSNumber *)pgn_info[@"Length"]).integerValue;
  NSMutableString *res = [NSMutableString string];
  
  NSString *date = @"2016-00-01T03:22:48.578Z";
  
  [res appendString:date];
  [res appendString:[NSString stringWithFormat:@",%ld,%@,%ld,%ld,%ld,", (long)priority, pgn, (long)source, (long)dest, (long)length]];
  
  NSMutableData* data = [[NSMutableData alloc] initWithCapacity:length];
  BitWriter *bitWriter = [[BitWriter alloc] initWithData:data];
  
  for ( NSDictionary *field in pgn_info[@"Fields"] )
  {
	NSInteger bit_len = ((NSNumber *)field[@"BitLength"]).integerValue;
	NSNumber *val = (NSNumber *)message[field[@"Id"]];
	double resolution = ((NSString *)field[@"Resolution"]).doubleValue;
	bool isSigned = ((NSNumber *)field[@"Signed"]).boolValue;
	NSString *units = field[@"Units"];
	
	double dval = [self convertUnits:val.doubleValue units:units];
	
	if ( resolution != 0 )
	{
	  int precision = 0;
	  for (double r = resolution; (r > 0.0) && (r < 1.0); r *= 10.0)
	  {
		precision++;
	  }
	  
	  if ( precision > 0 )
	  {
		double mx = pow(10, precision);
		dval = dval * (double)mx;
	  }
	}
	
	if ( bit_len < 8 )
	{
	  //NSArray *maxes = @[ nil, @0, @3, ]
	  Byte maxes[] = { 0, 0, 3, 7, 15, 31, 63, 127 };
	  Byte b = val == nil ? maxes[bit_len] : [val unsignedCharValue];
	  [bitWriter writeBits:b bits:bit_len];
	}
	else if ( bit_len == 8 )
	{
	  uint8_t b = val == nil ? (isSigned ? CHAR_MAX : UCHAR_MAX) : [val unsignedCharValue];
	  [bitWriter writeByte:b];
	}
	else if ( bit_len == 16 )
	{
	  uint16_t s = val == nil ? (isSigned ? SHRT_MAX : USHRT_MAX) : dval;
	  [bitWriter write16Bit:s];
	}
	else if ( bit_len == 32 )
	{
	  uint32_t i = val == nil ? (isSigned ? INT_MAX : UINT_MAX) : dval;
	  [bitWriter write32Bit:i];
	}
  }
  
  [res appendString:[self convertDataToHex:data]];
  
  return res;
}

- (NSString *)convertDataToHex:(NSData *)data
{
  const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
  
  if (!dataBuffer)
  {
	return [NSString string];
  }
  
  NSUInteger dataLength  = [data length];
  NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
  
  for (int i = 0; i < dataLength; ++i)
  {
	[hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
	if ( i != (dataLength-1) )
	  [hexString appendString:@","];
  }
  
  return hexString;
}


@end
