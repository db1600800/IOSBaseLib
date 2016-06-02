//
//  Sql.h
//  Philately
//
//  Created by gdpost on 15/6/25.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface Sql : NSObject
{

 sqlite3 *db;
}

-(BOOL) openDB;

-(NSString*) selectPM_SIGNSERVICE_CONFIGVERSION;

@end

