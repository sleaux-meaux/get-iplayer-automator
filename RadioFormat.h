//
//  RadioFormat.h
//  Get_iPlayer GUI
//
//  Created by Thomas Willson on 9/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadioFormat : NSObject <NSCoding>
@property (nonnull, copy) NSString *format;
-(instancetype)initWithFormat:(NSString *)format;
@end

NS_ASSUME_NONNULL_END
