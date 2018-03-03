//
//  SpheresView.m
//  Spheres
//  Created by Will Sumner on 2/1/18.
//  Copyright © 2018
//

#import "SpheresView.h"

@implementation SpheresView


double radius;
const int numSpheres = 75;
float previewFactor = 1.0;
float moveFact = 1.0;
float moveFactDelta = 0.001;
float changeInCol = 0.0;
int gradFactAnim = 0.001;
float gradFact = 0.2;
float gradTemp = 3.0;
float direcX = 0.0;
float direcY = 0.0;
float factors[numSpheres];
double radii[numSpheres];
double vx[numSpheres];
double vy[numSpheres];
CGRect spheres[numSpheres];
float hue;
CGRect clearRect;
NSColor *clearCol;

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)startAnimation
{
    CGRect rect;
    clearRect = [self bounds];
    clearCol = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    if (!([super isPreview]))
    {
        previewFactor = 5;
    }
    else
    {
        previewFactor = 1.0;
    }
    for (int i = 0; i < numSpheres; i++)
    {
        radii[i] = 0.0; // set everything to zero at first
        radius = SSRandomFloatBetween(5.0, 20.0);
        radii[i] = radius*previewFactor;
        rect = NSMakeRect(0.0,0.0,0.0,0.0); // make a new object
        rect.origin = SSRandomPointForSizeWithinRect(rect.size, [self bounds]);
        spheres[i] = rect;
        vx[i] = SSRandomFloatBetween(-0.5, 0.5)*previewFactor/3;
        vy[i] = SSRandomFloatBetween(-0.5,0.5)*previewFactor/3;
        factors[i] = SSRandomFloatBetween(0.05, .2)*previewFactor;
    }
    hue = SSRandomFloatBetween( 0.0, 25 ) / 25; // random hue
    
    //[self setNeedsDisplay:true];
    [super startAnimation];
}
- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    
    NSColor *color;
    CGRect currentRect;
    NSBezierPath *path;

    [clearCol set];
    path = [NSBezierPath bezierPathWithRect:(clearRect)];
    [path fill]; // clear the screen
    
    moveFact += moveFactDelta;
    if(moveFact < 0.0001 || moveFact > 1) // if the circles stopped moving / started slowing down
    {
        if (moveFactDelta < 0)
            moveFactDelta = SSRandomFloatBetween(0.001,0.005);
        else
            moveFactDelta = SSRandomFloatBetween(.001, .005)*-1;
        changeInCol = SSRandomFloatBetween(0.000001, 0.00001); // new changing color
        gradTemp = SSRandomIntBetween(0, 1000)/1000.0;
        direcX = SSRandomFloatBetween(-0.167, .167);
        direcY = SSRandomFloatBetween(-0.167, .167);
        
    }
    //gradFactAnim = (gradTemp-gradFact); // animate to new value
    if (fabsf(gradFact-gradTemp) > 0.01 && changeInCol < 0.000005 )
    {
        if (gradFact < gradTemp)
            gradFact += 0.005;
        else
            gradFact -= 0.005;
    }
    
    for (int i = 0; i < numSpheres; i++)
    {
        currentRect = spheres[i];
        float fact = currentRect.size.height/radii[i];
        currentRect.origin = CGPointMake(currentRect.origin.x+vx[i]*moveFact+direcX, currentRect.origin.y+vy[i]*moveFact+direcY);
        
        if (!NSIntersectsRect([self bounds],currentRect))
        {
            currentRect.origin = SSRandomPointForSizeWithinRect(currentRect.size,self.bounds);
            currentRect.size = NSMakeSize(0.0, 0.0); // shrink it to zero
            factors[i] = SSRandomFloatBetween(0.05, 0.2)*previewFactor; // new factor
            vx[i] = SSRandomFloatBetween(-0.5, 0.5)*previewFactor/3; // new velocity
            vy[i] = SSRandomFloatBetween(-0.5, 0.5)*previewFactor/3;
        }
        NSSize oldsize = currentRect.size;
        currentRect.size = NSMakeSize(oldsize.width+factors[i]*(1.1-fact),oldsize.height+factors[i]*(1.1-fact));
        
        if (currentRect.size.height < 0.01) // just need to check one since their synced
            factors[i] = fabs(factors[i]); // make the factor positive
        else if (currentRect.size.height > radii[i])
            factors[i] *= -1; // make it negative
        
        spheres[i] = currentRect; //update the sphere
        float grad = fabs(currentRect.origin.x/[self bounds].size.width)*gradFact;
        
        hue = fmodf(hue+changeInCol,1.0); // new hue value
        color = [NSColor colorWithCalibratedHue:fmodf(hue+grad,1.0) saturation: 0.9 brightness:fact alpha:1.0 ];
        [color set];
        [NSGraphicsContext saveGraphicsState];
        NSShadow* theShadow = [[NSShadow alloc] init];
        [theShadow setShadowOffset:NSMakeSize(10.0, -10.0)];
        [theShadow setShadowBlurRadius:3.0];
        [theShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
        [theShadow set];
        path = [NSBezierPath bezierPathWithOvalInRect:(currentRect)];
        [path fill];
        [NSGraphicsContext restoreGraphicsState];
    }
    [super animateOneFrame];
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
