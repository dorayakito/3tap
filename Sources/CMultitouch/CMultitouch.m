#import "include/CMultitouch.h"
#import <dlfcn.h>
#import <math.h>

typedef struct {
    float x;
    float y;
} MTPoint;

typedef struct {
    MTPoint position;
    MTPoint velocity;
} MTVector;

typedef struct {
    int frame;
    double timestamp;
    int identifier;
    int state;
    int foo3;
    int foo4;
    MTVector normalized;
    float size;
    int foo5;
    float angle;
    float majorAxis;
    float minorAxis;
    MTVector absolute;
    int foo6;
    int foo7;
    float density;
} MTTouch;

typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(MTDeviceRef device, MTTouch *touches, int numTouches, double timestamp, int frame);

typedef CFArrayRef (*MTDeviceCreateListFunc)(void);
typedef void (*MTRegisterContactFrameCallbackFunc)(MTDeviceRef device, MTContactCallbackFunction callback);
typedef void (*MTDeviceStartFunc)(MTDeviceRef device, int mode);
typedef void (*MTDeviceStopFunc)(MTDeviceRef device);

static MTTapCallback g_tapCallback = NULL;
static BOOL g_isListening = NO;
static BOOL g_isTracking = NO;
static double g_tapStartTime = 0.0;
static MTPoint g_startPos[3];
static BOOL g_dragDetected = NO;
static int g_maxTouchesSeen = 0;

static double g_maxDuration = 0.35; // Default 350ms
static float g_maxMovement = 0.06f;  // Default 6% of trackpad dimension

static int mtContactCallback(MTDeviceRef device, MTTouch *touches, int numTouches, double timestamp, int frame) {
    if (!g_isListening) return 0;
    
    if (numTouches == 3) {
        if (!g_isTracking) {
            g_isTracking = YES;
            g_tapStartTime = timestamp;
            g_dragDetected = NO;
            g_maxTouchesSeen = 3;
            for (int i = 0; i < 3; i++) {
                g_startPos[i] = touches[i].normalized.position;
            }
        } else {
            // Check for movement drift
            for (int i = 0; i < 3; i++) {
                float dx = touches[i].normalized.position.x - g_startPos[i].x;
                float dy = touches[i].normalized.position.y - g_startPos[i].y;
                float dist = sqrtf(dx * dx + dy * dy);
                if (dist > g_maxMovement) {
                    g_dragDetected = YES;
                }
            }
        }
    } else if (numTouches > 3) {
        g_maxTouchesSeen = numTouches;
        g_dragDetected = YES;
    } else if (numTouches == 0) {
        if (g_isTracking) {
            double duration = timestamp - g_tapStartTime;
            if (!g_dragDetected && g_maxTouchesSeen == 3 && duration >= 0.02 && duration <= g_maxDuration) {
                if (g_tapCallback) {
                    // Dispatch to main thread or callback thread safely
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (g_tapCallback) {
                            g_tapCallback();
                        }
                    });
                }
            }
            g_isTracking = NO;
            g_dragDetected = NO;
            g_maxTouchesSeen = 0;
        }
    }
    
    return 0;
}

void MTBridgeStartListening(MTTapCallback callback) {
    g_tapCallback = callback;
    g_isListening = YES;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void *handle = dlopen("/System/Library/PrivateFrameworks/MultitouchSupport.framework/MultitouchSupport", RTLD_LAZY);
        if (!handle) {
            NSLog(@"[3Tap] Error: Failed to open MultitouchSupport framework");
            return;
        }
        
        MTDeviceCreateListFunc createList = (MTDeviceCreateListFunc)dlsym(handle, "MTDeviceCreateList");
        MTRegisterContactFrameCallbackFunc registerCb = (MTRegisterContactFrameCallbackFunc)dlsym(handle, "MTRegisterContactFrameCallback");
        MTDeviceStartFunc deviceStart = (MTDeviceStartFunc)dlsym(handle, "MTDeviceStart");
        
        if (!createList || !registerCb || !deviceStart) {
            NSLog(@"[3Tap] Error: Could not locate symbols in MultitouchSupport");
            return;
        }
        
        CFArrayRef devices = createList();
        if (!devices) {
            NSLog(@"[3Tap] Warning: No multitouch devices returned");
            return;
        }
        
        CFIndex count = CFArrayGetCount(devices);
        NSLog(@"[3Tap] MultitouchListener initialized on %ld device(s)", count);
        
        for (CFIndex i = 0; i < count; i++) {
            MTDeviceRef dev = (MTDeviceRef)CFArrayGetValueAtIndex(devices, i);
            registerCb(dev, mtContactCallback);
            deviceStart(dev, 0);
        }
    });
}

void MTBridgeStopListening(void) {
    g_isListening = NO;
}

void MTBridgeSetMaxDuration(double durationSeconds) {
    g_maxDuration = durationSeconds;
}

void MTBridgeSetMaxMovement(float movementThreshold) {
    g_maxMovement = movementThreshold;
}

BOOL MTBridgeIsListening(void) {
    return g_isListening;
}
