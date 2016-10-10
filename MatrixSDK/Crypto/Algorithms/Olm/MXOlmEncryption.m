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

#import "MXOlmEncryption.h"

#import "MXCryptoAlgorithms.h"
#import "MXSession.h"

@implementation MXOlmEncryption

+ (void)initialize
{
    // Register this class as the encryptor for olm
    [[MXCryptoAlgorithms sharedAlgorithms] registerEncryptorClass:MXOlmEncryption.class forAlgorithm:kMXCryptoOlmAlgorithm];
}

- (MXHTTPOperation *)encryptEventContent:(NSDictionary *)eventContent eventType:(MXEventTypeString)eventType inRoom:(MXRoom *)room
                                 success:(void (^)(NSDictionary *, NSString *))success
                                 failure:(void (^)(NSError *))failure
{
    // pick the list of recipients based on the membership list.
    //
    // TODO: there is a race condition here! What if a new user turns up
    // just as you are sending a secret message?

    NSMutableArray <NSString*> *users = [NSMutableArray array];
    for (MXRoomMember *member in room.state.joinedMembers)
    {
        [users addObject:member.userId];
    }

    return [self ensureSession:users success:^{

        NSMutableArray *participantKeys = [NSMutableArray array];

        for (NSString *userId in users)
        {
            NSArray<MXDeviceInfo *> *devices = [self.mxSession.crypto storedDevicesForUser:userId];
            for (MXDeviceInfo *device in devices)
            {
                NSString *key = device.identityKey;

                if ([key isEqualToString:self.mxSession.crypto.olmDevice.deviceCurve25519Key])
                {
                    // Don't bother setting up session to ourself
                    continue;
                }

                if (device.verified == MXDeviceBlocked)
                {
                    // Don't bother setting up sessions with blocked users
                    continue;
                }

                [participantKeys addObject:key];
            }
        }

        [self.mxSession.crypto encryptMessage:@{
                                                @"room_id": room.roomId,
                                                @"type": eventType,
                                                @"content": eventContent
                                                }
                                   forDevices:participantKeys];
        
    } failure:failure];
}

- (MXHTTPOperation*)ensureSession:(NSArray<NSString*>*)users
                          success:(void (^)())success
                          failure:(void (^)(NSError *))failure
{
    // @TODO: Avoid to do this request for every message. Instead, manage a queue of messages waiting for encryption
    MXHTTPOperation *operation =   [self.mxSession.crypto downloadKeys:users forceDownload:YES success:^(MXUsersDevicesMap<MXDeviceInfo *> *usersDevicesInfoMap) {

        MXHTTPOperation *operation2 = [self.mxSession.crypto ensureOlmSessionsForUsers:users success:^(MXUsersDevicesMap<MXOlmSessionResult *> *results) {
            success();
        } failure:failure];

        [operation mutateToAnotherOperation:operation2];

    } failure:failure];

    return operation;
}

@end
