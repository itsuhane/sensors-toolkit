#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkOutputServer : NSObject

-(nullable instancetype)init:(NSString*)address port:(int)port;
-(void)dealloc;
-(void)send:(const void*)data maxLength:(long)length;
@end

NS_ASSUME_NONNULL_END
