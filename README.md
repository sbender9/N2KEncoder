# N2KEncoder
Cocoa NMEA 2k Encoder

```
  NSDictionary *trackControl=
  @{
	@"pgn": @"127237",
	@"priority": @2,
	@"destination": @172,
	@"source": @0,
	@"rudderLimitExceeded": [NSNumber numberWithDouble:2],
	@"offHeadingLimitExceeded": [NSNumber numberWithDouble:1],
	@"offTrackLimitExceeded": [NSNumber numberWithDouble:2],
	@"override": [NSNumber numberWithDouble:0],
	@"steeringMode": [NSNumber numberWithDouble:1.0],
	@"turnMode": [NSNumber numberWithDouble:12.0],
	@"commandedRudderDirection": [NSNumber numberWithDouble:1.0],
	@"commandedRudderAngle": [NSNumber numberWithDouble:3.0],
	@"headingReference": [NSNumber numberWithDouble:1.0],
	};

  N2KEncoder *encoder = [[N2KEncoder alloc] init];
  
  NSString *n2kMessages = [encoder encodeN2KMessage:trackControl];

```

Output:
```
2016-00-01T03:22:48.578Z,2,127237,0,172,21,26,c1,79,0b,02,ff,ff,ff,ff,ff,ff,ff,ff,ff,7f,ff,7f,ff,7f,ff,ff
```
