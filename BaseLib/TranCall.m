//
//  TranCall.m
//  Philately
//
//  Created by gdpost on 15/6/17.
//  Copyright (c) 2015年 gdpost. All rights reserved.
//

#import "TranCall.h"
#import "SVProgressHUD.h"
#import "PromptError.h"
#import "JSONKit.h"

#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#import "SVProgressHUD.h"


@implementation TranCall



NSTimer *timmer;

bool isContinueOpenLoading;


-(void)jyTranCall:(SysBaseInfo *) sysBaseInfo  cstmMsg:(CstmMsg*)cstmMsg formName:(NSString*)formName business:(NSDictionary*)business delegate:(id<TranCallDelegate>)delegate viewController:(UIViewController*)viewController
{
    TIMEOUT=3000;
    
    isContinueOpenLoading=sysBaseInfo.isOpenLoading;
    sysBaseInfo.isOpenLoading=false;
    self.viewController=viewController;
    self.delegate=delegate;
    

     dispatch_async(dispatch_get_main_queue(), ^{
       
         if ([SVProgressHUD isVisible]==true) {
             
         }else
         {
             if (sysBaseInfo.isNoHasLoading==true) {
                 
             }else
             {
             [SVProgressHUD showWithStatus:@"努力加载中..." maskType:SVProgressHUDMaskTypeClear];
             }
         }
     });


    
    NSMutableDictionary *tranBodyDic=[[NSMutableDictionary alloc] init];
    tranBodyDic=business;

   

    [tranBodyDic setValue:tranheadDic forKey:@"SNDMSG_HEAD"];

  
    serviceInvoker=[[ServiceInvoker alloc]init];

  
    [serviceInvoker  setDelegate:self];

   
    [serviceInvoker callWebservice:tranBodyDic formName:formName delegate:self];

    
    timmer  = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeFire) userInfo:nil repeats:NO];

}

-(void)timeFire
{
       [SVProgressHUD dismiss];

}


//业务请求返回错误
-(void)serviceInvokerError:(MsgReturn*)msgReturn
{
    if (msgReturn==nil ) {
        return;
    }
    
    [timmer invalidate];
     timmer=nil;
      dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
      });
  
  
    
   if(msgReturn.formName!=nil && [msgReturn.errorCode isEqualToString:ERROR_FAILED])
    {//交易失败
        
        
    }
    
    else
    {
        //网络错误 服务器错误  传输格式错误
        if([msgReturn.errorCode isEqualToString:ERROR_DATA_FORMAT_ERROR] || [msgReturn.errorCode isEqualToString:ERROR_SERVICE_IN_ERROR] || [msgReturn.errorCode isEqualToString:ERROR_NOT_NET])
            
        {
           
            
          
            [PromptError changeShowErrorMsg:msgReturn title:@""  viewController:self block:^(BOOL OKCancel)
             {
                 if (OKCancel) {
                     
                 }else
                 {
                     
                 }
                 return ;
             }
             ];

        }
    }
       [self.delegate ReturnError:msgReturn];
    
    NSLog(@"%@ %@",msgReturn.formName,msgReturn.errorDesc);
    
}

//业务请求返回数据
-(void)serviceInvokerReturnData:(MsgReturn*)msgReturn
{
    [timmer invalidate];
    timmer=nil;
    
    if([msgReturn.errorCode isEqualToString:ERROR_SUCCESS])
    {//callWebservice成功
        
        if ([msgReturn.formName isEqual:@"JY0052"]||[msgReturn.formName isEqual:@"JY0049"]) {
            
        }
        else
        {
              dispatch_async(dispatch_get_main_queue(), ^{
                  if (isContinueOpenLoading) {//true开着
                      
                  }else
                  {//false 关闭
                  [SVProgressHUD dismiss];
                  }
               
              });
      
        }
        
        
        
        NSMutableDictionary* map=msgReturn.map;
        NSString *businessParamString=[map objectForKey:@"businessParam"];
        NSDictionary *businessParamDic=[businessParamString objectFromJSONString];
        NSString *tempdata=[businessParamDic objectForKey:@"data"];
        NSDictionary *kk=[tempdata objectFromJSONString];
        NSDictionary  *data=[kk objectForKey:@"kk"];
        
       
      
        
       
        NSMutableDictionary *returnDataDic=[data  objectForKey:@"returnData"];
        
         NSMutableDictionary *tempData=[NSMutableDictionary dictionaryWithDictionary:returnDataDic];
        
        [tempData setObject:returnDataDic forKey:@"returnBody"];
        
         NSMutableDictionary *tempData2=[[NSMutableDictionary alloc] init];
        
        [tempData2 setObject:tempData forKey:@"returnData"];
         msgReturn.map=tempData2 ;
        
        NSMutableDictionary *returnHeadDic=[returnDataDic objectForKey:@"RCVMSG_HEAD"];
        NSString *respCode=[returnHeadDic objectForKey:@"HOST_RET_ERR"];
        NSString *respDesc=[returnHeadDic objectForKey:@"HOST_RET_MSG"];
        
        NSMutableDictionary *returnBodyDic=[returnDataDic objectForKey:@"returnBody"];
    
        
        if (respCode!=nil && ![respCode isEqualToString:@""] &&![respCode isEqualToString:@"000000"]) {
            
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
        });
        
            
            MsgReturn *msgReturn=[[MsgReturn alloc] init];
            msgReturn.errorCode=respCode;
            msgReturn.errorDesc=respDesc;
            msgReturn.errorType=@"02";
        //NSLog(@"%@ %@",msgReturn.errorCode,msgReturn.errorDesc);
        
        
        
        [PromptError changeShowErrorMsg:msgReturn title:nil viewController:self.viewController block:^(BOOL OKCancel){
            if (OKCancel) {
                //[self.delegate ReturnError:msgReturn];
            }
            
        } ];
            
            [SVProgressHUD dismiss];
            
            
            return;
        }
     
        [self.delegate ReturnData:msgReturn];
        
        
    }else{//错误码 非0000
    
           dispatch_async(dispatch_get_main_queue(), ^{
                              [SVProgressHUD dismiss];
               
           });
        
        NSLog(@"%@ %@",msgReturn.errorCode,msgReturn.errorDesc);
        
  
  
        [PromptError changeShowErrorMsg:msgReturn title:nil viewController:self.viewController block:^(BOOL OKCancel){
            if (OKCancel) {
                      [self.delegate ReturnError:msgReturn];
            }
        
        } ];
    }
    
}



//实现一个创建单例对象的类方法


//这是单例对象遵循<NSCopying>协议时需要实现的方法
-(id) copyWithZone: (struct _NSZone *)zone{
    return self;
}



@end
