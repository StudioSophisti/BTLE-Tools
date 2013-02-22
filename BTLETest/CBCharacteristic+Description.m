//
//  CBCharacteristic+Description.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 14-11-12.
//
//

#import "CBCharacteristic+Description.h"

@implementation CBCharacteristic (Description)

- (NSString*)characteristicName {
    
    NSString *title = [NSString stringWithFormat:@"%@", self.UUID];
    
    NSRange index = [title rangeOfString:@"(<"];
    if (index.location != NSNotFound) {
        if ([title length] > 20) {
            // 128 bit uuid
            return [NSString stringWithFormat:@"0x%@", [title substringWithRange:NSMakeRange(index.location+2, 35)]];
        } else {
            // 16 bit uuid
            NSString *key = [NSString stringWithFormat:@"0x%@", [[title substringWithRange:NSMakeRange(index.location+2, 4)] uppercaseString]];
            NSString *value = NSLocalizedStringFromTable(key, @"characteristics", @"");
            if ([key isEqualToString:value]) value = @"Unknown UUID";
            return [NSString stringWithFormat:@"%@: %@", key, value];
        }
    }
    
    return [title stringByReplacingOccurrencesOfString:@"Unknown" withString:@"Unknown UUID:"];
}

- (NSString*)hexString {
    if (!self.value) return @"-";
    
    NSString *raw = [NSString stringWithFormat:@"0x%@", self.value];
    raw = [raw stringByReplacingOccurrencesOfString:@"<" withString:@""];
    raw = [raw stringByReplacingOccurrencesOfString:@">" withString:@""];
    return raw;
}

- (NSString*)asciiString {
    if (!self.value) return @"-";
    
    NSString *ascii = [[[NSString alloc] initWithData:self.value encoding:NSASCIIStringEncoding] autorelease];
    return ascii;
}

@end
