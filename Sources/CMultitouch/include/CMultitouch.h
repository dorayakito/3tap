#ifndef CMultitouch_h
#define CMultitouch_h

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void (*MTTapCallback)(void);

void MTBridgeStartListening(MTTapCallback callback);
void MTBridgeStopListening(void);
void MTBridgeSetMaxDuration(double durationSeconds);
void MTBridgeSetMaxMovement(float movementThreshold);
BOOL MTBridgeIsListening(void);

#ifdef __cplusplus
}
#endif

#endif /* CMultitouch_h */
