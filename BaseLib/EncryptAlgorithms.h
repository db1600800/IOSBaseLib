//
//  EncryptAlgorithms.h
//  PublicFramework
//
//  Created by admin on 16/1/11.
//  Copyright (c) 2016年 gdpost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EncryptAlgorithms : NSObject

-(void) init:(NSString*) key;
- (NSString*) Decrypt:(NSString *)S;
@end
