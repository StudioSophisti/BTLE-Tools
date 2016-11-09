//
//  CBCharacteristic+Description.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 14-11-12.
//
//

#import "NSData+Description.h"

@implementation NSData (Description)

- (NSString*)hexString {
    NSString *raw = [NSString stringWithFormat:@"0x%@", self];
    raw = [raw stringByReplacingOccurrencesOfString:@"<" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@">" withString:@""];
    return raw;
}

- (NSString*)asciiString {
    NSString *ascii = [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
    return ascii;
}

@end
