
#import "GSNetService.h"
#import "JSONKit.h"
#import "NSString+ThreeDES.h"
#import "ErrorMsg.h"
#import "WebConfig.h"
#import "MsgReturn.h"

@implementation GSNetService
{
   
    
    NSString *actionIDkey;
}


//DEF_SINGLETON(GSNetService)

-(void)sendMsg:(NSMutableDictionary*)businessParam toServerOnFormName:(NSString*)formName withDelegate:(id)delegate{
    
    self.delegate=delegate;

    NSString *fullUrl = server_url ;
    NSURL *url = [NSURL URLWithString:[fullUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:TIMEOUT/1000];
    request.HTTPMethod=@"POST";
    //把拼接后的字符串转换为data，设置请求体
    NSString *sendstr = [businessParam JSONString];
    NSData* tmdata =[sendstr dataUsingEncoding:NSUTF8StringEncoding];
    
    
    request.HTTPBody=tmdata;
  
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   
                                   //NSURLErrorTimedOut
                                   
                                   //交易失败  回调
                                   MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                                   msgReturn.errorCode=ERROR_FAILED;
                                   msgReturn.errorDesc=@"交易失败";
                                   msgReturn.formName=@"fileUp";
                                   
                                   [self.delegate netServiceError:msgReturn];
                                   
                               }else{
                                   
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                
                                   NSDictionary *returnDataDic=[self jsonString2Dic:[responseString dataUsingEncoding:NSUTF8StringEncoding] ];
                                   
                                   
                                   NSString *code = [returnDataDic objectForKey:@"returnCode"];
                                   
                                   if ([code isEqualToString:@"0000"]) {
                                       
                                       NSString *desc = [returnDataDic objectForKey:@"returnDesc"];
                                       NSMutableDictionary *date = [returnDataDic objectForKey:@"returnDate"];
                                       
                                       NSString *imageId = [date objectForKey:@"imageId"];
                                       
                                       
                                       
                                       
                                       //交易成功  回调
                                       MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                                       msgReturn.errorCode=ERROR_SUCCESS;
                                       msgReturn.errorDesc=@"交易成功";
                                       msgReturn.formName=@"fileUp";
                                       msgReturn.map=date;
                                       [self.delegate netServiceReturnData:msgReturn];
                                   }else
                                   {
                                       //交易失败  回调
                                       MsgReturn *msgReturn=[[MsgReturn alloc ] init ];
                                       msgReturn.errorCode=ERROR_FAILED;
                                       msgReturn.errorDesc=@"交易失败";
                                       msgReturn.formName=@"fileUp";
                                       
                                       [self.delegate netServiceError:msgReturn];
                                   }
                                   
                               }
                           }];
    
    
}


// 将JSON串转化为字典或者数组
- (id)jsonString2Dic:(NSDate *)jsonData{
    
    //  NSData *jsonData=[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error== nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

static GSNetService *objName = nil;

+ (GSNetService *) sharedInstance{
    static dispatch_once_t oneToken = 0;
    dispatch_once(&oneToken, ^{
        objName = [[super allocWithZone: NULL] init];
    });
    return objName;
}
@end
