//
//  Sql.h
//  Philately
//
//  Created by gdpost on 15/6/25.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ErrorObject.h"
@interface SqlApp : NSObject
{

 sqlite3 *db;
}

-(BOOL) openDB;

-(NSString*) selectPM_CITYCODE:(NSString*) name;
-(NSString*) selectPM_CITYCODE_ByCode:(NSString*) code;

-(ErrorObject*) selectPM_CODEERRORMSG:(NSString*) code;
-(ErrorObject*) selectPM_DESCERRORMSG:(NSString*) code;



-(NSMutableArray*) selectPM_ARRAYSERVICE:(NSString*)type;
-(NSString*) selectPM_ARRAYSERVICEByCode:(NSString*)type code:(NSString*)code;
-(NSMutableArray*) selectPM_SHOPPINGCHECK_FUNCINFO:(NSString*)businNo;

//省2
-(NSMutableArray*) selectPM_REGION3 ;
-(NSMutableArray*) selectPM_REGION4:(NSString*) sinceProvComps ;

-(NSMutableArray*) selectPM_REGION2:(NSString*) code;
-(NSMutableArray*) selectPM_REGION:(NSString*) code withLevel:(NSString*)level;
-(NSMutableArray*) selectPM_REGION5:(NSString*) code withLevel:(NSString*)level since:(NSString*)since;

-(NSString*) selectPM_SHOPPINGCHECK:(NSString*) code;
-(NSString*) selectPM_REGION:(NSString*) code ;
-(NSString*) selectPM_SIGNSERVICE:(NSString*) code;
-(NSString*) selectPM_BRCHNO:(NSString*) cityCode;
@end

@interface rowApp : NSObject


@property (strong, nonatomic) NSString  * SERVICEID;
@property (strong, nonatomic) NSString  *SERVICEKEY;
@property (strong, nonatomic) NSString  *SERVICECODE;
@property (strong, nonatomic) NSString  *SERVICENAME;
@property (strong, nonatomic) NSString  *SERVICENAME_BACKUP1;
@property (strong, nonatomic) NSString  *SERVICENAME_BACKUP2;
@property (strong, nonatomic) NSString  *SERVICENAME_BACKUP3;

@property (strong, nonatomic) NSString  *ERRORCODE;
@property (strong, nonatomic) NSString *ERRORDESC;
@property (strong, nonatomic) NSString *ERRORTYPE;



@property (strong, nonatomic) NSString * CHANGEDESC;


@property (strong, nonatomic) NSString *CLASSNAME;
@property (strong, nonatomic) NSString *FUNCNAME;
@property (strong, nonatomic) NSString *CALLSEQ;



@end

