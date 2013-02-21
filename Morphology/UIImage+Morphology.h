//
//  UIImage+Morphology.h
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

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AHMorphologyStructuringElement)
{
	AHMorphologyStructuringElementRect,
	AHMorphologyStructuringElementCross,
	AHMorphologyStructuringElementDiamond,
	AHMorphologyStructuringElementDisk
};

@interface UIImage (AHMorphology)

// `size` specifies the "radius" of the structuring element in device points.
// The actual size of the kernel used will be (2 * size * scale + 1).
// This ensures that the kernel is always of odd size, and that therefore
// the kernel is always symmetrical about the anchor (center) point.

// Extract the alpha channel of this image, then dilate it by the specified amount and return as a grayscale image
- (UIImage *)maskImageDilatedWithStructuringElement:(AHMorphologyStructuringElement)type size:(CGFloat)size iterations:(NSInteger)iterations;

// Extract the alpha channel of this image, then dilate it by the specified amount and return as a grayscale image
- (UIImage *)maskImageErodedWithStructuringElement:(AHMorphologyStructuringElement)type size:(CGFloat)size iterations:(NSInteger)iterations;

@end
