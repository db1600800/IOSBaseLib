//
//  Sql.m
//  Philately
//
//  Created by gdpost on 15/6/25.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import "SqlApp.h"
#import "ErrorObject.h"
#import "DropDownViewController.h"

@implementation SqlApp




-(BOOL) openDB{
   
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
  path = [path stringByAppendingPathComponent:@"securedDirectory/postservice_IOS.db"];
    
  //  path =[[NSBundle mainBundle] pathForResource:@"POST_JY" ofType:@"db"];
    
    
     // NSString *database_path =[[NSBundle mainBundle] pathForResource:path ofType:@"db"];
    //获取数据库路径
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documents = [paths objectAtIndex:0];
//    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    //如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
    //打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
    //Objective-C)编写的，它不知道什么是NSString.
    if (sqlite3_open([path UTF8String], &db) == SQLITE_OK) {
        return YES;
    }else{
        return NO;
        NSLog(@"数据库打开失败");
        sqlite3_close(db);
    }
}



//城市代号查城市名
-(NSString*) selectPM_CITYCODE_ByCode:(NSString*) code{
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where CITYCODE like'%@'",@"PM_CITYCODE",code];
    sqlite3_stmt * statement;
    
    
    NSString *cityName=@"";
    
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            char *SERVICEIDchar = (char*)sqlite3_column_text(statement, 1);
            NSString *SERVICEIDstring = [[NSString alloc]initWithUTF8String:SERVICEIDchar];
            cityName=SERVICEIDstring;
            
            
            
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return cityName;
}


//城市名查城市代号
-(NSString*) selectPM_CITYCODE:(NSString*) name{
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where CITYNAME like'%@%%'",@"PM_CITYCODE",name];
    sqlite3_stmt * statement;
    
   
    NSString *cityCode=@"";
 
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
                       
            
            char *SERVICEIDchar = (char*)sqlite3_column_text(statement, 0);
            NSString *SERVICEIDstring = [[NSString alloc]initWithUTF8String:SERVICEIDchar];
            cityCode=SERVICEIDstring;
            
            
            
          
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return cityCode;
}



//城市代号查业务开办局
-(NSString*) selectPM_BRCHNO:(NSString*) cityCode{
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where CITYCODE like'%@%%'",@"PM_CITYCODE",cityCode];
    sqlite3_stmt * statement;
    
    
    NSString *ywkbj=@"";
    
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            
            char *SERVICEIDchar = (char*)sqlite3_column_text(statement, 4);
            NSString *SERVICEIDstring = [[NSString alloc]initWithUTF8String:SERVICEIDchar];
            ywkbj=SERVICEIDstring;
            
            
            
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return ywkbj;
}





//错误码转译
-(ErrorObject*) selectPM_CODEERRORMSG:(NSString*) code{
    

    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where ERRORCODE='%@'",@"PM_CODEERRORMSG",code];
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSString *servicename=@"";
   ErrorObject *errorObject=nil;
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
       
        while (sqlite3_step(statement) == SQLITE_ROW) {
             rowApp *r=[[rowApp alloc] init ];
           
            
            char *SERVICEIDchar = (char*)sqlite3_column_text(statement, 0);
            NSString *SERVICEIDstring = [[NSString alloc]initWithUTF8String:SERVICEIDchar];
            r.ERRORCODE=SERVICEIDstring;
            
            char *SERVICEKEYchar = (char*)sqlite3_column_text(statement, 1);
            NSString *SERVICEKEYstring = [[NSString alloc]initWithUTF8String:SERVICEKEYchar];
           r.ERRORDESC=SERVICEKEYstring;
            servicename= SERVICEKEYstring;
            
            char *SERVICECODEchar = (char*)sqlite3_column_text(statement, 2);
            NSString *SERVICECODEstring = [[NSString alloc]initWithUTF8String:SERVICECODEchar];
            r.ERRORTYPE=SERVICECODEstring;
            
            
          
            errorObject=[[ErrorObject alloc ]init ];
            
            errorObject.errorCode=  r.ERRORCODE;
            errorObject.errorDesc=r.ERRORDESC;
            errorObject.errorType=r.ERRORTYPE;
            
            
            [rows addObject:r];
            //NSLog(@"name:%@  age:%d  address:%@",nsNameStr,age, nsAddressStr);
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return errorObject;
}


-(ErrorObject*) selectPM_DESCERRORMSG:(ErrorObject*) error1{
    
  
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where ERRORDESC='%@'",@"PM_DESCERRORMSG",error1.errorDesc];
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSString *servicename=@"";
    ErrorObject *errorObject=error1;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            rowApp *r=[[rowApp alloc] init ];
            
            
            char *SERVICEIDchar = (char*)sqlite3_column_text(statement, 0);
            NSString *SERVICEIDstring = [[NSString alloc]initWithUTF8String:SERVICEIDchar];
            r.ERRORDESC=SERVICEIDstring;
            
            char *SERVICEKEYchar = (char*)sqlite3_column_text(statement, 1);
            NSString *SERVICEKEYstring = [[NSString alloc]initWithUTF8String:SERVICEKEYchar];
            r.CHANGEDESC=SERVICEKEYstring;
            servicename=SERVICEKEYstring;
            
            
            
            errorObject.errorDesc=  r.CHANGEDESC;
 
            
            [rows addObject:r];
            //NSLog(@"name:%@  age:%d  address:%@",nsNameStr,age, nsAddressStr);
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return errorObject;
}


//查询业务类型中文
-(NSString*) selectPM_SHOPPINGCHECK:(NSString*) code{
    
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where BUSINO='%@'",@"PM_SHOPPINGCHECK",code];
    sqlite3_stmt * statement;
    
   
    NSString *businCn=@"";
  
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            rowApp *r=[[rowApp alloc] init ];
            
            
          
            
            char *SERVICEKEYchar = (char*)sqlite3_column_text(statement, 1);
            NSString *SERVICEKEYstring = [[NSString alloc]initWithUTF8String:SERVICEKEYchar];
            businCn=SERVICEKEYstring;
            
            //NSLog(@"name:%@  age:%d  address:%@",nsNameStr,age, nsAddressStr);
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return businCn;
}






-(NSMutableArray*) selectPM_ARRAYSERVICE:(NSString*)type {
    [self openDB];
    NSString *sqlQuery=@"";

        sqlQuery = [NSString stringWithFormat:
                    @"SELECT * FROM %@ where SERVICEKEY='%@' ",@"PM_ARRAYSERVICE",type];
    
    
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSMutableArray *names=[[NSMutableArray alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
            //SERVICECODE 1
            
            
            //SERVICENAME 2
            char *SERVICENAMEchar = (char*)sqlite3_column_text(statement, 1);
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:SERVICENAMEchar];
            r.rowId=SERVICENAMEstring;
            
            //SERVICENAMEBackup 3
            char *SERVICENAMEchar2 = (char*)sqlite3_column_text(statement, 2);
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:SERVICENAMEchar2];
            r.rowMsg=SERVICENAMEstring2;
            
            
            
            [names addObject:r.rowMsg];
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}




-(NSString*) selectPM_ARRAYSERVICEByCode:(NSString*)type code:(NSString*)code{
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where SERVICEKEY='%@' and SERVICECODE='%@'",@"PM_ARRAYSERVICE",type,code];
    sqlite3_stmt * statement;
    

    NSString *cn=@"";
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
        
            
            //SERVICENAMEBackup 3
            char *SERVICENAMEchar2 = (char*)sqlite3_column_text(statement, 2);
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:SERVICENAMEchar2];
                       cn=SERVICENAMEstring2;
            
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return cn;
}



//查询省
-(NSString*) selectPM_REGION:(NSString*) code {
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where REGIONID ='%@' ",@"PM_REGION",code];
    
    sqlite3_stmt * statement;
    
 
    NSString *name=[[NSString alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
         
        
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            r.rowId=SERVICENAMEstring;
            
       
            name=SERVICENAMEstring;
            
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return name;
}






//查询省3
-(NSMutableArray*) selectPM_REGION3 {
    
    [self openDB];
    
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * from PM_REGION a where (a.REGIONCLASS= '2'  and a.regionid not in ('110000','120000','310000','500000'))or (a.regionid  in ('110100','120100','310100','500100'))"];
                          
       sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSMutableArray *names=[[NSMutableArray alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
            
            
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
            r.rowId=SERVICENAMEstring;
            
            
            
            
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            r.rowMsg=SERVICENAMEstring2;
            
            NSString *SERVICENAMEstring3 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
            r.rowMsg2=SERVICENAMEstring3;
            
            
            [names addObject:r.rowMsg];
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}



//查询省4
-(NSMutableArray*) selectPM_REGION4:(NSString*) sinceProvComps {
    
    [self openDB];
    
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * from PM_REGION a where  a.REGIONID in (%@)",sinceProvComps];
    
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSMutableArray *names=[[NSMutableArray alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
            
            
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 0)];
            r.rowId=SERVICENAMEstring;
            
            
            
            
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            r.rowMsg=SERVICENAMEstring2;
            
            NSString *SERVICENAMEstring3 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
            r.rowMsg2=SERVICENAMEstring3;
            
            
            [names addObject:r.rowMsg];
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}





//查询市区5
-(NSMutableArray*) selectPM_REGION5:(NSString*) code withLevel:(NSString*)level since:(NSString*)since {
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT distinct superiorid,regionid, regionname,regionclass FROM %@ where SUPERIORID ='%@' and REGIONCLASS ='%@' and regionid in(%@) order by regionid asc ",@"PM_REGION",code,level,since];
    
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSMutableArray *names=[[NSMutableArray alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
            
            
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            r.rowId=SERVICENAMEstring;
            
            
            
            
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
            r.rowMsg=SERVICENAMEstring2;
            
            NSString *SERVICENAMEstring3 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
            r.rowMsg2=SERVICENAMEstring3;
            
            
            [names addObject:r.rowMsg];
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}







//查询省
-(NSMutableArray*) selectPM_REGION:(NSString*) code withLevel:(NSString*)level {
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT distinct superiorid,regionid, regionname,regionclass FROM %@ where SUPERIORID ='%@' and REGIONCLASS ='%@'  order by regionid asc ",@"PM_REGION",code,level];
    
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSMutableArray *names=[[NSMutableArray alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
            
            
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            r.rowId=SERVICENAMEstring;
            
            
            
            
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
            r.rowMsg=SERVICENAMEstring2;
            
            NSString *SERVICENAMEstring3 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
            r.rowMsg2=SERVICENAMEstring3;
            
            
            [names addObject:r.rowMsg];
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}






//省2
-(NSMutableArray*) selectPM_REGION2:(NSString*) code  {
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT distinct superiorid,regionid, regionname,regionclass FROM %@ where regionid ='%@'   order by regionid asc ",@"PM_REGION",code];
    
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
    NSMutableArray *names=[[NSMutableArray alloc] init ];
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            DropDownRow *r=[[DropDownRow alloc] init ];
            
            
            
            NSString *SERVICENAMEstring = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 1)];
            r.rowId=SERVICENAMEstring;
            
            
            
            
            NSString *SERVICENAMEstring2 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 2)];
            r.rowMsg=SERVICENAMEstring2;
            
            NSString *SERVICENAMEstring3 = [[NSString alloc]initWithUTF8String:(char*)sqlite3_column_text(statement, 3)];
            r.rowMsg2=SERVICENAMEstring3;
            
            
            [names addObject:r.rowMsg];
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}


//获取配置函数列表
//根据当前业务代号联合查询 PM_SHOPPINGCHECK 、 PM_FUNINFO 表获取购物车检查方法列表，查询结果按调用顺序排序
-(NSMutableArray*) selectPM_SHOPPINGCHECK_FUNCINFO:(NSString*)businNo{
    //NSString *businNo=@"66";
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"select b.CLASSNAME,b.FUNCNAME,a.CALLSEQ from PM_SHOPPINGCHECK a ,PM_FUNCINFO b where a.FUNCID = b.FUNCID and a.BUSINO= '%@' ORDER BY a.CALLSEQ",businNo];
    
    sqlite3_stmt * statement;
    
    NSMutableArray *rows=[[NSMutableArray alloc] init ];
  
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            rowApp *r=[[rowApp alloc] init ];
            

            
            
            //SERVICENAME 2
            char *CLASSNAMEchar = (char*)sqlite3_column_text(statement, 0);
            NSString *CLASSNAMEstring = [[NSString alloc]initWithUTF8String:CLASSNAMEchar];
            r.CLASSNAME=CLASSNAMEstring;
            
        
            char *FUNCNAMEchar= (char*)sqlite3_column_text(statement, 1);
            NSString *FUNCNAMEstring = [[NSString alloc]initWithUTF8String:FUNCNAMEchar];
            r.FUNCNAME=FUNCNAMEstring;
            
            char *CALLSEQchar= (char*)sqlite3_column_text(statement, 2);
            NSString *CALLSEQstring = [[NSString alloc]initWithUTF8String:CALLSEQchar];
            r.CALLSEQ=CALLSEQstring;
            
            
         
            
            [rows addObject:r];
            
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return rows;
}



//
-(NSString*) selectPM_SIGNSERVICE:(NSString*) code{
    
    
    [self openDB];
    NSString *sqlQuery = [NSString stringWithFormat:
                          @"SELECT * FROM %@ where SERVICEKEY='%@'",@"PM_SIGNSERVICE",code];
    sqlite3_stmt * statement;
    
    
    NSString *businCn=@"";
    
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值,注意这里的列值
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            rowApp *r=[[rowApp alloc] init ];
            
            
            
            
            char *SERVICEKEYchar = (char*)sqlite3_column_text(statement, 1);
            NSString *SERVICEKEYstring = [[NSString alloc]initWithUTF8String:SERVICEKEYchar];
            businCn=SERVICEKEYstring;
            
            //NSLog(@"name:%@  age:%d  address:%@",nsNameStr,age, nsAddressStr);
        }
    }else{
        NSLog(@"select error:%@",sqlQuery);
        
    }
    sqlite3_close(db);
    return businCn;
}



@end



@implementation rowApp
@synthesize  SERVICEID;
@synthesize  SERVICEKEY;
@synthesize  SERVICECODE;
@synthesize  SERVICENAME;
@synthesize  SERVICENAME_BACKUP1;
@synthesize  SERVICENAME_BACKUP2;
@synthesize  SERVICENAME_BACKUP3;

@synthesize ERRORCODE;
@synthesize ERRORDESC;
@synthesize ERRORTYPE;



@synthesize CHANGEDESC;


@synthesize CLASSNAME;
@synthesize FUNCNAME;
@synthesize CALLSEQ;
@end

