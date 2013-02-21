//
//  UIImage+Morphology.m
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

#import "UIImage+Morphology.h"

#define SWAP(x, y, T) do { T temp##x##y = x; x = y; y = temp##x##y; } while (0)

typedef uint8_t ColorComponent;

@implementation UIImage (Morphology)

+ (ColorComponent *)newStructuringElementWithType:(AHMorphologyStructuringElement)type size:(NSInteger)kernelSize
{
	ColorComponent *kernel = malloc((2 * kernelSize + 1) * (2 * kernelSize + 1));

	size_t i = 0;
	for(int y = -kernelSize; y <= kernelSize; ++y)
	{
		for(int x = -kernelSize; x <= kernelSize; ++x, ++i)
		{
			switch (type)
			{
				case AHMorphologyStructuringElementRect:
					kernel[i] = UINT8_MAX;
					break;
				case AHMorphologyStructuringElementCross:
					kernel[i] = (x == 0 || y == 0) ? UINT8_MAX : 0;
					break;
				case AHMorphologyStructuringElementDiamond:
					kernel[i] = (abs(x) + abs(y) <= kernelSize) ? UINT8_MAX : 0;
					break;
				case AHMorphologyStructuringElementDisk:
					kernel[i] = (x * x + y * y <= kernelSize * kernelSize) ? UINT8_MAX : 0;
					break;
			}
		}
	}

	return kernel;
}

+ (UIImage *)imageWithGrayscaleData:(ColorComponent *)pixels size:(CGSize)size scale:(CGFloat)scale
{
	const size_t numberOfComponents = 1;
	const size_t bitsPerComponent = 8;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef targetContext = CGBitmapContextCreate(pixels,
													   size.width  * scale,
													   size.height * scale,
													   bitsPerComponent,
													   numberOfComponents * size.width * scale,
													   colorSpace,
													   kCGImageAlphaNone);

	CGImageRef cgImage = CGBitmapContextCreateImage(targetContext);

	UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp];

	CGImageRelease(cgImage);
	CGColorSpaceRelease(colorSpace);
	CFRelease(targetContext);

	return image;
}

// This method assumes that the source image has an RGBA colorspace
- (ColorComponent *)copyAlphaMaskPixels
{
	CGImageRef cgImage = self.CGImage;
	size_t pixelCount = CGImageGetWidth(cgImage) * CGImageGetHeight(cgImage);
	CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));

	size_t dataLength = CFDataGetLength(data);
	uint8_t *bytes = malloc(dataLength);
	CFDataGetBytes(data, CFRangeMake(0, dataLength), bytes);

	ColorComponent *pixels = malloc(sizeof(ColorComponent) * pixelCount);

	for(size_t i = 0, j = 0; i < dataLength; i += 4, ++j)
	{
		pixels[j] = bytes[i + 3];
	}

	CFRelease(data);
	free(bytes);

	return pixels;
}

- (UIImage *)maskImageMorphedWithStructuringElement:(AHMorphologyStructuringElement)type
											   size:(CGFloat)size
										 iterations:(NSInteger)iterations
											 dilate:(BOOL)shouldDilate
{
	CGImageRef cgImage = self.CGImage;

	NSInteger kernelSize = floorf(size * self.scale);

	// Extract alpha channel as mask
	NSInteger sourceWidth = CGImageGetWidth(cgImage);
	NSInteger sourceHeight = CGImageGetHeight(cgImage);
	ColorComponent *sourceAlpha = [self copyAlphaMaskPixels];
	ColorComponent *destAlpha = malloc(sourceWidth * sourceHeight);

	// Create structuring element
	ColorComponent *kernel =  [UIImage newStructuringElementWithType:type size:kernelSize];

	for(int c = 1; c <= iterations; ++c)
	{
		// Iterate mask image and perform erosion/dilation simultaneously
		size_t i = 0;
		for(int y = 0; y < sourceHeight; ++y)
		{
			for(int x = 0; x < sourceWidth; ++x, ++i)
			{
				size_t j = 0;
				ColorComponent min = UINT8_MAX, max = 0;
				for(int ny = -kernelSize; ny <= kernelSize; ++ny)
				{
					for(int nx = -kernelSize; nx <= kernelSize; ++nx, ++j)
					{
						if(kernel[j] == 0)
							continue;

						if(x + nx >= 0 && y + ny >= 0 && x + nx < sourceWidth && y + ny < sourceHeight)
						{
							size_t ni = (y + ny) * sourceWidth + (x + nx);
							if(sourceAlpha[ni] < min)
								min = sourceAlpha[ni];
							if(sourceAlpha[ni] > max)
								max = sourceAlpha[ni];
						}
					}
				}

				destAlpha[i] = shouldDilate ? max : min;
			}
		}

		if(c < iterations)
			SWAP(sourceAlpha, destAlpha, ColorComponent *);
	}

	if(iterations == 0)
		SWAP(sourceAlpha, destAlpha, ColorComponent *);

	// Create alpha mask image with eroded alpha channel
	UIImage *maskImage = [UIImage imageWithGrayscaleData:destAlpha size:self.size scale:self.scale];

	free(kernel);
	free(destAlpha);
	free(sourceAlpha);

	return maskImage;
}

- (UIImage *)maskImageDilatedWithStructuringElement:(AHMorphologyStructuringElement)type
											   size:(CGFloat)size
										 iterations:(NSInteger)iterations
{
	return [self maskImageMorphedWithStructuringElement:type size:size iterations:iterations dilate:YES];
}

- (UIImage *)maskImageErodedWithStructuringElement:(AHMorphologyStructuringElement)type
											  size:(CGFloat)size
										iterations:(NSInteger)iterations
{
	return [self maskImageMorphedWithStructuringElement:type size:size iterations:iterations dilate:NO];
}

@end
