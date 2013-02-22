//
//  CBService+Description.m
//  BTLETools
//
//  Created by Tijn Kooijmans on 14-11-12.
//
//

#import "CBService+Description.h"

@implementation CBService (Description)

- (NSString*)serviceName {
    
    NSString *title = [NSString stringWithFormat:@"%@", self.UUID];
    
    NSRange index = [title rangeOfString:@"(<"];
    if (index.location != NSNotFound) {
        
        if ([title length] > 20) {
            // 128 bit uuid
            return [NSString stringWithFormat:@"0x%@", [title substringWithRange:NSMakeRange(index.location+2, 35)]];
        } else {
            // 16 bit uuid
            NSString *key = [NSString stringWithFormat:@"0x%@", [[title substringWithRange:NSMakeRange(index.location+2, 4)] uppercaseString]];
            NSString *value = NSLocalizedStringFromTable(key, @"services", @"");
            if ([key isEqualToString:value]) value = @"Unknown UUID";
            return [NSString stringWithFormat:@"%@: %@", key, value];
        }
        
    }
    
    return [title stringByReplacingOccurrencesOfString:@"Unknown" withString:@"Unknown UUID:"];
}

@end
