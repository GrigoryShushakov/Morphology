//
//  StrokedImageView.m
//  Morphology
//
//  Created by Warren Moore on 2/21/13.
//  Copyright (C) 2013 Auerhaus Development, LLC
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "AHStrokedImageView.h"
#import "UIImage+Morphology.h"

@interface AHStrokedImageView ()
@property(nonatomic, strong) UIImage *maskImage;
@end

@implementation AHStrokedImageView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		_strokeWidth = 0;
		_strokeColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
	_image = image;

	self.maskImage = [_image maskImageDilatedWithStructuringElement:AHMorphologyStructuringElementDiamond
															   size:1
														 iterations:_strokeWidth];

	[self setNeedsDisplay];
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
	_strokeColor = strokeColor;

	[self setNeedsDisplay];
}

- (void)setStrokeWidth:(CGFloat)strokeWidth
{
	_strokeWidth = strokeWidth;
	self.image = _image;

	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextScaleCTM(context, 1, -1);
	CGContextTranslateCTM(context, 0, -rect.size.height);

	if(_maskImage != nil)
	{
		CGContextSaveGState(context);
		CGContextSetFillColorWithColor(context, _strokeColor.CGColor);
		CGContextClipToMask(context, rect, _maskImage.CGImage);
		CGContextFillRect(context, rect);
		CGContextRestoreGState(context);
	}

	if(_image != nil)
	{
		CGContextDrawImage(context, rect, _image.CGImage);
	}
}

@end
