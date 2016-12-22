//
//  PipesImage.swift
//  Pipes
//
//  Created by David Poirier on 21/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import Foundation
import UIKit

class PipesImageFactory {
    
    private var bundle: Bundle?
    private var UITC: UITraitCollection?
    
    private var GreyRGBA: Array<RGBA> = Array<RGBA>()
    
    //MARK: Init
    
    init(in bun: Bundle, compatibleWith: UITraitCollection)
    {
        bundle = bun
        UITC = compatibleWith
        
        // pre-load list of RGBA's containing grey images
        for i in 0...15 {
            GreyRGBA.append(RGBA(image: UIImage(named: "Y" + String(i), in: bundle, compatibleWith: UITC)!)!)
        }
    }
    
    // MARK: API Functions
    
    func PipeImage(colour: String, connections: Int, greyPC: Int = 0, greyStart: Int = 0) -> UIImage?
    {
        let name: String = colour + String(connections)
        let ColourImage = UIImage(named: name, in: bundle, compatibleWith: UITC)

        
        if greyPC == 0 {
            return ColourImage
        }

        if (greyPC >= 100)
        {
            // full grey - just blat that out
            return UIImage(named: "Y" + String(connections), in: bundle, compatibleWith: UITC)
        }
        
        let NewImg = RGBA(image: ColourImage!)!
        let OverImage = GreyRGBA[connections]

        var x1, y1, x2, y2 : Int
        
        for h in 0...greyPC {
            if h < 50 {
                for w in 0...(49-h) {
                    switch greyStart {
                    case 2:
                        x1 = 49 - w
                        x2 = 49 + w
                        y1 = 99 - h
                        y2 = 99 - h
                    case 1:
                        x1 = 99 - h
                        x2 = 99 - h
                        y1 = 49 - w
                        y2 = 49 + w
                    case 0:
                        x1 = 49 - w
                        x2 = 49 + w
                        y1 = h
                        y2 = h
                    case 3:
                        x1 = h
                        x2 = h
                        y1 = 49 - w
                        y2 = 49 + w
                    default: // Only used for very first cell
                        x1 = 49
                        x2 = 49
                        y1 = 49
                        y2 = 49
                    }
                    
//                    if x1 > 99 || x1 < 0 || y1 > 99 || y1 < 0 || x2 > 99 || x2 < 0 || y2 > 99 || y2 < 0 {
//                        break
//                    }
                    
                    NewImg.pixels[y1 * NewImg.width + x1].value = OverImage.pixels[y1 * OverImage.width + x1].value
                    NewImg.pixels[y2 * NewImg.width + x2].value = OverImage.pixels[y2 * OverImage.width + x2].value
                }
            } else {
                for w in 0...h-50 {
                    NewImg.pixels[(99 - h) * NewImg.width + (49 - w)].value = OverImage.pixels[(99 - h) * OverImage.width + (49 - w)].value
                    NewImg.pixels[(99 - h) * NewImg.width + (50 + w)].value = OverImage.pixels[(99 - h) * OverImage.width + (50 + w)].value
                    NewImg.pixels[(49 - w) * NewImg.width + (99 - h)].value = OverImage.pixels[(49 - w) * OverImage.width + (99 - h)].value
                    NewImg.pixels[(50 + w) * NewImg.width + (99 - h)].value = OverImage.pixels[(50 + w) * OverImage.width + (99 - h)].value
                    NewImg.pixels[h * NewImg.width + (49 - w)].value = OverImage.pixels[h * OverImage.width + (49 - w)].value
                    NewImg.pixels[h * NewImg.width + (50 + w)].value = OverImage.pixels[h * OverImage.width + (50 + w)].value
                    NewImg.pixels[(49 - w) * NewImg.width + h].value = OverImage.pixels[(49 - w) * OverImage.width + h].value
                    NewImg.pixels[(50 + w) * NewImg.width + h].value = OverImage.pixels[(50 + w) * OverImage.width + h].value
                }
            }
        }
        
            /*
            for (int h=0; h < 100; h++)
            {
                // loop thru all steps of greyness and see if this step is grey yet
                if (h < GreyPC)
                bGrey = true ;
                else
                bGrey = false ;
                
                if (h < 50)
                {
                    // greyness coming in - one direction only
                    for (int w = 0; w<(50-h); w++)
                    {
                        // combine grey and colour image
                        xx = 49-w ;
                        yy = h ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                        xx = 50+w ;
                        yy = h ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                    }
                } else {
                    for (int w = 0; w<=(h-50); w++)
                    {
                        // greyness coming in - three directions
                        xx = 50-w ;
                        yy = h ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                        xx = 50+w ;
                        yy = h ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                        xx = h ;
                        yy = 50-w ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                        xx = h ;
                        yy = 50+w ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                        xx = 99-h ;
                        yy = 50-w ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                        xx = 99-h ;
                        yy = 50+w ;
                        SetImagePixel(Img, ImageToUse, Pattern, xx, yy, bGrey, GreyStart) ;
                    }
                }
            }
            G.drawImage(Img, x, y, Width, Height, null);
 */
    

        
        return NewImg.toUIImage()
    }
    
    //MARK: Image Manipulation Class

    // Thanks to:
    // http://mhorga.org/2015/10/05/image-processing-in-ios.html
    // http://mhorga.org/2015/10/12/image-processing-in-ios-part-2.html
    // http://mhorga.org/2015/10/19/image-processing-in-ios-part-3.html
    
    struct Pixel {
        var value: UInt32
        var red: UInt8 {
            get { return UInt8(value & 0xFF) }
            set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
        }
        var green: UInt8 {
            get { return UInt8((value >> 8) & 0xFF) }
            set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
        }
        var blue: UInt8 {
            get { return UInt8((value >> 16) & 0xFF) }
            set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
        }
        var alpha: UInt8 {
            get { return UInt8((value >> 24) & 0xFF) }
            set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
        }
    }
    
    struct RGBA {
        var pixels: UnsafeMutableBufferPointer<Pixel>
        var width: Int
        var height: Int
        
        init?(image: UIImage) {
            guard let cgImage = image.cgImage else { return nil }
            
            width = Int(image.size.width)
            height = Int(image.size.height)
            let bitsPerComponent = 8
            
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
            
            imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: image.size))
            pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        }
        
        func toUIImage() -> UIImage? {
            let bitsPerComponent = 8
            
            let bytesPerPixel = 4
            let bytesPerRow = width * bytesPerPixel
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
            bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
            let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
            guard let cgImage = imageContext!.makeImage() else {return nil}
            
            let image = UIImage(cgImage: cgImage)
            return image
        }
    }
}
