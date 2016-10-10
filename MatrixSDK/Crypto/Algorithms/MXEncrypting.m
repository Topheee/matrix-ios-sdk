/*
 Copyright 2016 OpenMarket Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXEncrypting.h"

#import "MXSession.h"


#pragma mark - Base class implementation

@implementation MXEncryptionAlgorithm

- (instancetype)initWithMatrixSession:(MXSession *)matrixSession andRoom:(NSString *)roomId
{
    self = [super init];
    if (self)
    {
        _mxSession = matrixSession;
        _roomId = roomId;
    }
    return self;
}

- (MXHTTPOperation *)encryptEventContent:(NSDictionary *)eventContent eventType:(MXEventTypeString)eventType inRoom:(MXRoom *)room
                                 success:(void (^)(NSDictionary *, NSString *))success
                                 failure:(void (^)(NSError *))failure
{
    return nil;
}

- (void)onRoomMembership:(MXEvent *)event member:(MXRoomMember *)member oldMembership:(MXMembership)oldMembership
{

}

- (void)onNewDevice:(NSString *)deviceId forUser:(NSString *)userId
{

}
@end
