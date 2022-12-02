#import <Foundation/Foundation.h>


@interface Block: NSObject {
    NSInteger _x;
    NSInteger _y;
}
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@end


@implementation Block
@synthesize x = _x, y = _y;

- (id)initWithX:(NSInteger)x y:(NSInteger)y {
    _x = x;
    _y = y;
    return self;
}

- (NSUInteger)hash {
    return (_x + _y) * (_x + _y + 1) / 2 + _y;
}

- (BOOL)isEqual:(Block *)object {
    return _x == object.x && _y == object.y;
}
@end


#pragma mark -


@interface Rock: NSObject {
    NSArray<Block *> *_blocks;
    NSInteger _height;
}
@property (nonatomic, readonly) NSInteger height;
@end


@implementation Rock
@synthesize height = _height;

typedef struct {
    struct {
        NSInteger x;
        NSInteger y;
    } points[5];
    NSInteger size;
    NSInteger height;
} InitialShape;

static InitialShape initialShapes[5] = {
    {{{0, 0}, {1, 0}, {2, 0}, {3, 0}}, 4, 1},
    {{{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}}, 5, 3},
    {{{2, 0}, {2, 1}, {2, 2}, {0, 2}, {1, 2}}, 5, 3},
    {{{0, 0}, {0, 1}, {0, 2}, {0, 3}}, 4, 4},
    {{{0, 0}, {1, 0}, {0, 1}, {1, 1}}, 4, 2}
};

- (id)initWithIdx:(NSInteger)idx andDeltaX:(NSInteger)dx deltaY:(NSInteger)dy {
    InitialShape shape = initialShapes[idx % 5];
    NSMutableArray *points = [[NSMutableArray alloc] init];
    for (int i = 0; i < shape.size; i++) {
        NSInteger x = shape.points[i].x += dx;
        NSInteger y = shape.points[i].y += dy;
        [points addObject:[[Block alloc] initWithX:x y:y]];
    }
    _blocks = [points copy];
    _height = shape.height;
    return self;
}

- (NSArray<Block *> *)blocks {
    return _blocks;
}

- (void)moveDeltaX:(NSInteger)dx deltaY:(NSInteger)dy {
    for (Block *block in _blocks) {
        block.x += dx;
        block.y += dy;
    }
}
@end


#pragma mark -


@interface Jets: NSObject {
    NSArray<NSNumber *> *_jets;
    NSInteger _currentIdx;
}
@end


@implementation Jets

- (id)initWithString:(NSString *)str {
    NSMutableArray *jets = [[NSMutableArray alloc] initWithCapacity:str.length];
    
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i] == '<') {
            [jets addObject:@-1];
        } else {
            [jets addObject:@1];
        }
    }
    _jets = [jets copy];
    _currentIdx = 0;
    
    return self;
}

- (NSInteger)current {
    NSNumber *jet = [_jets objectAtIndex:_currentIdx];
    _currentIdx = (_currentIdx + 1) % _jets.count;
    return [jet intValue];
}

- (void)reset {
    _currentIdx = 0;
}
@end


#pragma mark -


@interface TopPoints: NSObject {
    NSMutableArray<Block *> *_points;
    NSInteger _startIdx;
    NSInteger _endIdx;
    NSInteger _capacity;
    NSInteger _size;
}
@end


@implementation TopPoints

- (id)initWithCapacity:(NSInteger)capacity {
    _capacity = capacity;
    _startIdx = 0;
    _endIdx = 0;
    _points = [[NSMutableArray alloc] initWithCapacity:capacity];
    return self;
}

- (void)append:(Block *)point {
    if (_size != 0) {
        _endIdx = (_endIdx +1) % _capacity;
    }
    if (_endIdx >= _capacity) {
        _endIdx = 0;
    }
    if (_startIdx >= _capacity) {
        _startIdx = 0;
    }
    if (_endIdx == _startIdx && _size > 0) {
        _startIdx = (_startIdx + 1) % _capacity;
    }
    
    if (_endIdx >= _startIdx) {
        [_points insertObject:point atIndex:_endIdx];
    } else {
        [_points replaceObjectAtIndex:_endIdx withObject:point];
    }
    
    if (_size < _capacity) {
        _size += 1;
    }
}

- (NSString *)serialize {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < _size; i++) {
        NSInteger idx = ((_startIdx + i) % _size);
        Block *point = [_points objectAtIndex:idx];
        [result appendFormat:@"(%lu,%lu)", point.x, point.y];
    }
    return result;
}
@end


#pragma mark -


@interface State: NSObject {
    NSInteger _rockIdx;
    NSInteger _topOffset;
}
@property (nonatomic, readonly) NSInteger rockIdx;
@property (nonatomic, readonly) NSInteger topOffset;
@end


@implementation State
@synthesize rockIdx = _rockIdx, topOffset = _topOffset;

- (id)initWithRockIdx:(NSInteger)rockIdx topOffset:(NSInteger)topOffset {
    _rockIdx = rockIdx;
    _topOffset = topOffset;
    return self;
}
@end


#pragma mark -


@interface CaveSimulation: NSObject {
    Jets *_jets;
    NSInteger _nIterations;
    NSInteger _rockIdx;
    
    NSMutableSet<Block *> *_placedBlocks;
    NSInteger _topOffset;
    NSInteger _repeatedHeight;
    
    TopPoints *_topPoints;
    NSMutableDictionary<NSString *, State *> *_memoized;
}
@end


@implementation CaveSimulation

- (id)initWithJets:(Jets *)jets iterations:(NSInteger)nIterations {
    _jets = jets;
    _nIterations = nIterations;
    _rockIdx = 0;
    
    _placedBlocks = [[NSMutableSet alloc] init];
    _topOffset = 0;
    _repeatedHeight = 0;
    
    _topPoints = [[TopPoints alloc] initWithCapacity:100];
    _memoized = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (NSInteger)height {
    return -_topOffset + _repeatedHeight;
}

- (Rock *)createRock {
    Rock *rock = [[Rock alloc] initWithIdx:_rockIdx andDeltaX:2 deltaY:_topOffset - 3];
    [rock moveDeltaX:0 deltaY:-[rock height]];
    _rockIdx += 1;
    return rock;
}

- (BOOL)isRockInBounds:(Rock *)rock {
    for (Block *p in [rock blocks]) {
        if (p.x < 0 || p.x >= 7 || p.y >= 0) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isCollidingWithRock:(Rock *)rock {
    for (Block *p in [rock blocks]) {
        if ([_placedBlocks containsObject:p]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)pushRockWithJet:(Rock *)rock {
    assert(_jets != nil);
    NSInteger dx = [_jets current];
    return [self pushRock:rock deltaX:dx deltaY:0];
}

- (BOOL)dropRock:(Rock *)rock {
    return [self pushRock:rock deltaX:0 deltaY:1];
}

- (BOOL)pushRock:(Rock *)rock deltaX:(NSInteger)dx deltaY:(NSInteger)dy {
    [rock moveDeltaX:dx deltaY:dy];
    if (![self isRockInBounds:rock] || [self isCollidingWithRock:rock]) {
        [rock moveDeltaX:-dx deltaY:-dy];
        return NO;
    }
    return YES;
}

- (void)placeRock:(Rock *)rock {
    for (Block *point in [rock blocks]) {
        [_placedBlocks addObject:point];
        _topOffset = MIN(_topOffset, point.y);
        
        NSInteger normalizedY = point.y - _topOffset;
        Block *normalized = [[Block alloc] initWithX:point.x y:normalizedY];
        [_topPoints append:normalized];
    }
    [self handleCycles];
}

- (void)handleCycles {
    NSString *mkey = [_topPoints serialize];
    State *state = [_memoized objectForKey:mkey];
    if (state == nil) {
        state = [[State alloc] initWithRockIdx:_rockIdx topOffset:_topOffset];
        [_memoized setValue:state forKey:mkey];
    } else {
        NSInteger offset = -(_topOffset - state.topOffset);
        NSInteger nRocks = _rockIdx - state.rockIdx;
        NSInteger nRepetitions = (_nIterations - _rockIdx) / nRocks;
        _rockIdx += nRepetitions * nRocks;
        _repeatedHeight += nRepetitions * offset;
    }
}

- (BOOL)shouldStop {
    return _rockIdx >= _nIterations;
}

- (void)run {
    while (![self shouldStop]) {
        Rock *rock = [self createRock];

        while (true) {
            [self pushRockWithJet:rock];
            BOOL didDrop = [self dropRock:rock];
            if (!didDrop) {
                [self placeRock:rock];
                break;
            }
        }
    }
}
@end


#pragma mark -


int main() {
    @autoreleasepool {
        NSError *error;
        NSString *path = @"input.txt";
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        assert(error == nil);
        input = [input stringByReplacingOccurrencesOfString:@"\n" withString:@""];

        Jets *jets = [[Jets alloc] initWithString:input];
        
        CaveSimulation *simA = [[CaveSimulation alloc] initWithJets:jets iterations:2022];
        [simA run];
        NSLog(@"A: %ld", [simA height]);
        
        [jets reset];
        
        CaveSimulation *simB = [[CaveSimulation alloc] initWithJets:jets iterations:1000000000000];
        [simB run];
        NSLog(@"B: %ld", [simB height]);
    }
   return 0;
}
