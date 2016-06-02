//
//  MsgReturn.h
//  PublicLibUI
//
//  Created by apple on 15/5/15.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#ifndef PublicLibUI_MsgReturn_h
#define PublicLibUI_MsgReturn_h
// 本设计提及到的方法KEY值约定：
// ServiceInvoker.callWebservice：KEY_CALL

@interface MsgReturn :NSObject
{
     NSString *errorCode ;
     NSString *errorType ;
     NSString *errorDesc ;
      bool errorPic;//勾  打叉 图片
     NSString *formName ;
     NSMutableDictionary *map;
}

@property (retain, nonatomic)  NSString *errorCode ;
@property (retain, nonatomic)  NSString *errorType ;
@property (retain, nonatomic)  NSString *errorDesc ;
@property (retain, nonatomic)  NSString *formName ;
@property ( nonatomic)  bool errorPic ;
@property (retain, nonatomic)  NSMutableDictionary *map ;

@end

#endif
