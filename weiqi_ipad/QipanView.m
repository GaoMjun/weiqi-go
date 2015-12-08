//
//  QipanView.m
//  testweiqi
//
//  Created by ll on 11/28/15.
//  Copyright © 2015 ll. All rights reserved.
//

#import "QipanView.h"
#import "Toast.h"

#define LINE_NUM 19

static CGFloat offset = 10.0;
static CGFloat gridlen = 38.0;
static CGFloat touchX = 0.0;
static CGFloat touchY = 0.0;

static int movecount = 1;

static const char blank = '0';
static const char black = '1';
static const char white = '2';
static const char mark = '3';

static int lastX = -1;
static int lastY = -1;

static int deadX = -2;
static int deadY = -2;

typedef struct {
    char chess[LINE_NUM*LINE_NUM+1];
    char label[LINE_NUM*LINE_NUM+1];
    
    int deadBlackChess;
    int deadWhiteChess;
} CHESSTYPE;

typedef struct STACKNODE {
    CHESSTYPE data;
    struct STACKNODE *next;
} StackNode;

static StackNode *stack;

static void push(CHESSTYPE *data) {
    StackNode *newNode = NULL;
    newNode = (StackNode *)malloc(sizeof(StackNode));
    
    newNode->data = *data;
    newNode->next = stack;
    
    stack = newNode;
}

static void pop(void) {
    if (stack != NULL) {
        StackNode *topNode;
        topNode = stack;
        stack = topNode->next;
        
        free(topNode);
    }
}

static int isEmpty(void) {
    return stack == NULL;
}

CHESSTYPE *top()
{
    if (!isEmpty()) {
        return &stack->data;
    }
    
    return NULL;
}

@implementation QipanView

- (void) reset
{
    gridlen = self.frame.size.width / 19;
    offset = gridlen/2;
    //初始化堆栈
    stack = NULL;
    stack = (StackNode *)malloc(sizeof(StackNode));
    memset(stack->data.chess, '0', sizeof(char)*(LINE_NUM*LINE_NUM));
    memset(stack->data.label, '0', sizeof(char)*(LINE_NUM*LINE_NUM));
    memset(&stack->data.chess[LINE_NUM*LINE_NUM], '\0', sizeof(char));
    memset(&stack->data.label[LINE_NUM*LINE_NUM], '\0', sizeof(char));
    stack->data.deadBlackChess = 0;
    stack->data.deadWhiteChess = 0;
    stack->next = NULL;
    
    lastX = -1;
    lastY = -1;
   
    deadX = -2;
    deadY = -2;
    
    NSMutableArray *deadChessCountArray = [[NSMutableArray alloc] init];
    [deadChessCountArray addObject:@(stack->data.deadWhiteChess)];
    [deadChessCountArray addObject:@(stack->data.deadBlackChess)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeadChessCount" object:deadChessCountArray];
    
    movecount = 1;
    
    [self removeAllCountLabel];
    [self setNeedsDisplay];
}

- (void) back
{
    if (stack->next != NULL) {
        pop();
        movecount--;
        
        NSMutableArray *deadChessCountArray = [[NSMutableArray alloc] init];
        [deadChessCountArray addObject:@(stack->data.deadWhiteChess)];
        [deadChessCountArray addObject:@(stack->data.deadBlackChess)];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeadChessCount" object:deadChessCountArray];
        
        [self removeAllCountLabel];
        [self setNeedsDisplay];
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self reset];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self grid:context]; //画棋盘
    [self ninePoints:context];
    [self showPoints:context]; //显示棋子
    
}

-(void)grid:(CGContextRef)context
{
    CGContextSetLineWidth(context, 2.0);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.0, 0.0, 0.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    CGContextSetStrokeColorWithColor(context, color);
    
    for(int i = 0; i < LINE_NUM; i++) //横线
    {
        CGContextMoveToPoint(context, offset, i * gridlen + offset);
        CGContextAddLineToPoint(context, (LINE_NUM - 1) * gridlen + offset, i * gridlen + offset);
        CGContextStrokePath(context);
    }
    
    for(int i = 0; i < LINE_NUM; i++) //竖线
    {
        CGContextMoveToPoint(context, i * gridlen + offset, offset);
        CGContextAddLineToPoint(context, i *gridlen + offset, (LINE_NUM - 1) * gridlen + offset);
        CGContextStrokePath(context);
    }
    
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

- (void)showPoints:(CGContextRef)context
{
    CGFloat r = gridlen/2;
    CHESSTYPE *chessStack = top();
    if (chessStack != NULL) {
        for (int i = 0; i < LINE_NUM; i++) {
            for (int j = 0; j < LINE_NUM; j++) {
                if (chessStack->chess[i*LINE_NUM+j] == black)   //黑子
                {
                    CGContextSetFillColor(context, CGColorGetComponents( [[UIColor colorWithRed:0
                                                                                          green:0
                                                                                           blue:0
                                                                                          alpha:1 ] CGColor]));
                    CGContextAddArc(context, i*gridlen+offset, j*gridlen+offset, r, 0, M_PI*2, 0);
                    CGContextClosePath(context);
                    CGContextFillPath(context);
                    [self addLabel:i*gridlen+offset y:j*gridlen+offset label:chessStack->label[i*LINE_NUM+j]];
                } else if (chessStack->chess[i*LINE_NUM+j] == white) {
                    
                    CGContextSetFillColor(context, CGColorGetComponents( [[UIColor colorWithRed:255
                                                                                          green:255
                                                                                           blue:255
                                                                                          alpha:1 ] CGColor]));
                    CGContextAddArc(context, i*gridlen+offset, j*gridlen+offset, r, 0, M_PI*2, 0);
                    CGContextClosePath(context);
                    CGContextFillPath(context);
                    [self addLabel:i*gridlen+offset y:j*gridlen+offset label:chessStack->label[i*LINE_NUM+j]];
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *t = [touches anyObject];
    CGPoint touch = [t locationInView:self];
    
    CGFloat x = touch.x;
    CGFloat y = touch.y;
    
    int i;
    int xok=0, yok=0;
    int theX=0, theY=0;
    
    for (i = 0; i < LINE_NUM; i++) {
        if (x > i*gridlen+offset-gridlen/2 &&
            x < i*gridlen+offset+gridlen/2) {
            touchX = i*gridlen+offset;
            xok = 1;
            theX = i;
        }
        if (y > i*gridlen+offset-gridlen/2 && y < i*gridlen+offset+gridlen/2) {
            touchY = i*gridlen+offset;
            yok = 1;
            theY = i;
        }
    }
    if (xok && yok) {
        [self playinX:theX Y:theY];
    }
    
}

- (void)playinX:(int)x Y:(int)y // 落子的算法
{
    static CHESSTYPE *chess = NULL;
    chess = (CHESSTYPE *)malloc(sizeof(CHESSTYPE));
    
    memcpy(chess->chess, top()->chess, sizeof(char)*(LINE_NUM*LINE_NUM+1));
    memcpy(chess->label, top()->label, sizeof(char)*(LINE_NUM*LINE_NUM+1));
    memcpy((void *)&chess->deadBlackChess, (void *)&top()->deadBlackChess, sizeof(int));
    memcpy((void *)&chess->deadWhiteChess, (void *)&top()->deadWhiteChess, sizeof(int));
    
    char color = '0';
    if (movecount % 2 != 0) {
        color = black;
    } else {
        color = white;
    }
    
    if (chess->chess[x*LINE_NUM+y] != blank) {
        [Toast toast:@"此处已有棋子" view:self];
        return;
    } else {
        chess->chess[x*LINE_NUM+y] = color;
        chess->label[x*LINE_NUM+y] = movecount;
        
        char shadowChess[LINE_NUM*LINE_NUM+1];
        memcpy(shadowChess, chess->chess, sizeof(shadowChess));
        
        [self scanDeadChessX:x Y:y chess:shadowChess];
        [self clearDead:chess shadow:shadowChess];
        int deadChessCount = [self recordDeadChess:shadowChess];
        
        if (deadChessCount == 0 &&
            ![self haveAirX:x Y:y chess:shadowChess]) {
            [Toast toast:@"此处为\"禁着点\"" view:self];
        } else {
            if (deadChessCount == 1) {
                if ((deadX == lastX && deadY == lastY)) {
                    deadX = -2;
                    deadY = -2;

                    [Toast toast:@"此处为\"劫\"" view:self];
                    return;
                }
                
                lastX = x;
                lastY = y;
            } else {
                lastX = lastY = -1;
                deadX = deadY = -2;
            }
            
            if (color == black) {
                chess->deadWhiteChess += deadChessCount;
            } else if (color == white) {
                chess->deadBlackChess += deadChessCount;
            }
            
            NSMutableArray *deadChessCountArray = [[NSMutableArray alloc] init];
            [deadChessCountArray addObject:@(chess->deadWhiteChess)];
            [deadChessCountArray addObject:@(chess->deadBlackChess)];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateDeadChessCount" object:deadChessCountArray];
            
            push(chess);
            
//            NSLog(@"%D", movecount);
            
            movecount++;
        }
        
    }

    [self removeAllCountLabel];
    [self setNeedsDisplay];
}

- (int) recordDeadChess:(char *)chess
{
    int count = 0;
    
    int deadx = -1;
    int deady = -1;
    
    for (int x = 0; x < LINE_NUM; x++) {
        for (int y = 0; y < LINE_NUM; y++) {
            if (chess[x*LINE_NUM+y] == mark) {
                count++;
                
                if (count == 1) {
                    deadx = x;
                    deady = y;
                }
            }
        }
    }
    
    if (count == 1) {
        deadX = deadx;
        deadY = deady;
    }
    
    return count;
}

- (void) removeAllCountLabel
{
    for (UIView *labelView in [self subviews])
    {
        if ([labelView isKindOfClass:[UILabel class]])
        {
            [labelView removeFromSuperview];
        }
    }
}

- (void) scanDeadChessX:(int)x Y:(int)y chess:(char *)chess
{
    char color = chess[x*LINE_NUM+y];
    char antiColor = '0';
    if (color == black) {
        antiColor = white;
    } else if (color == white) {
        antiColor = black;
    }
 
    char left,right,up,down;
    left = right = up = down = '0';
    
    if (x-1 < 0) {
        left = color;
    } else {
        left = chess[(x-1)*LINE_NUM+y];
    }
    
    if (x+1 > LINE_NUM-1) {
        right = color;
    } else {
        right = chess[(x+1)*LINE_NUM+y];
    }
    
    if (y-1 < 0) {
        up = color;
    } else {
        up = chess[x*LINE_NUM+(y-1)];
    }
    
    if (y+1 > LINE_NUM-1) {
        down = color;
    } else {
        down = chess[x*LINE_NUM+(y+1)];
    }
    
    if (up == antiColor) {
        [self haveAirX:x Y:y-1 chess:chess];
    }
    
    if (down == antiColor) {
        [self haveAirX:x Y:y+1 chess:chess];
    }
    
    if (left == antiColor) {
        [self haveAirX:x-1 Y:y chess:chess];
    }
    
    if (right == antiColor) {
        [self haveAirX:x+1 Y:y chess:chess];
    }
    
}

- (BOOL) haveAirX:(int)x Y:(int)y chess:(char *)chess
{
    if (chess != NULL) {
        char left,right,up,down;
        left = right = up = down = '0';
        
        char color = chess[x*LINE_NUM+y];
        
        if (color != mark && color != '0') {
            chess[x*LINE_NUM+y] = mark;
            char antiColor = '0';
            if (color == black) {
                antiColor = white;
            } else if (color == white) {
                antiColor = black;
            }
            
            if (x-1 < 0) {
                left = antiColor;
            } else {
                left = chess[(x-1)*LINE_NUM+y];
            }
            
            if (x+1 > LINE_NUM-1) {
                right = antiColor;
            } else {
                right = chess[(x+1)*LINE_NUM+y];
            }
            
            if (y-1 < 0) {
                up = antiColor;
            } else {
                up = chess[x*LINE_NUM+(y-1)];
            }
            
            if (y+1 > LINE_NUM-1) {
                down = antiColor;
            } else {
                down = chess[x*LINE_NUM+(y+1)];
            }
            
            if (up == '0' || down == '0' || left == '0' || right == '0') {
                //该子四周只要有一方为空，则该子至少有一气，该子为活子
                chess[x*LINE_NUM+y] = color;
                return TRUE;
            } else {
                //否则该子四周都有子
                // 1.如果左边;;;;
                if (up == color) {
                    if ([self haveAirX:x Y:y-1 chess:chess]) {
                        [self clearAllMark:chess color:color];
                        return TRUE;
                    }
                }
                
                if (down == color) {
                    if ([self haveAirX:x Y:y+1 chess:chess]) {
//                        chess[x*LINE_NUM+y] = color;
                        [self clearAllMark:chess color:color];
                        return TRUE;
                    }
                }
                
                if (left == color) {
                    if ([self haveAirX:x-1 Y:y chess:chess]) {
//                        chess[x*LINE_NUM+y] = color;
                        [self clearAllMark:chess color:color];
                        return TRUE;
                    }
                }
                
                if (right == color) {
                    if ([self haveAirX:x+1 Y:y chess:chess]) {
//                        chess[x*LINE_NUM+y] = color;
                        [self clearAllMark:chess color:color];
                        return TRUE;
                    }
                }
                
                {
//                    chess[x*LINE_NUM+y] = mark;
                    return FALSE;
                }
            }
        } else if (color == mark) {
            return FALSE;
        }
    }
    
    return TRUE;
}

- (void) clearAllMark:(char *)chess color:(char)color
{
    for (int x = 0; x < LINE_NUM; x++) {
        for (int y = 0; y < LINE_NUM; y++) {
            if (chess[x*LINE_NUM+y] == mark) {
                chess[x*LINE_NUM+y] = color;
            }
        }
    }
}

- (void) clearDead:(CHESSTYPE *)chess shadow:(char *)shadowChess
{
    for (int x = 0; x < LINE_NUM; x++) {
        for (int y = 0; y < LINE_NUM; y++) {
            if (shadowChess[x*LINE_NUM+y] == mark) {
                chess->chess[x*LINE_NUM+y] = '0';
                chess->label[x*LINE_NUM+y] = '0';
            }
        }
    }
}

- (void) addLabel:(int)x y:(int)y label:(int)label
{
    UILabel *countQiziLabel = [[UILabel alloc ] initWithFrame:CGRectMake(x-10, y-7.5, 20, 15)];
    countQiziLabel.backgroundColor = [UIColor clearColor];
    countQiziLabel.font = [UIFont fontWithName:@"PingFang SC" size:13];
    countQiziLabel.text = [NSString stringWithFormat:@"%D", label];
    countQiziLabel.textColor = [UIColor redColor];
    countQiziLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:countQiziLabel];
}

- (void)ninePoints:(CGContextRef)context // TODO, LINE_NUM xxx
{
        CGFloat r = 4;
        CGContextSetFillColor(context, CGColorGetComponents([[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor]));
        CGContextAddArc(context, 3*gridlen+offset, 3*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 9*gridlen+offset, 3*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 15*gridlen+offset, 3*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 3*gridlen+offset, 9*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 9*gridlen+offset, 9*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 15*gridlen+offset, 9*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 3*gridlen+offset, 15*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 9*gridlen+offset, 15*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
    
        CGContextAddArc(context, 15*gridlen+offset, 15*gridlen+offset, r, 0, M_PI*2, 0);
        CGContextClosePath(context);
        CGContextFillPath(context);
}

@end












