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
    
    //MARK: Init
    init(in bun: Bundle, compatibleWith: UITraitCollection)
    {
        bundle = bun
        UITC = compatibleWith
    }
    
    // MARK: API Functions
    func PipeImage(colour: String, connections: Int, greyPC: Int = 0, greyStart: Int = 0) -> UIImage?
    {
        let name: String = colour + String(connections)
        let ColourImage = UIImage(named: name, in: bundle, compatibleWith: UITC)

        
        if greyPC == 0 {
            return ColourImage
        }

        let GreyImage = UIImage(named: "Y" + String(connections), in: bundle, compatibleWith: UITC)
        if (greyPC >= 100)
        {
            // full grey - just blat that out
            return GreyImage
        }
  
        // Create a Graphics context based on Image
        UIGraphicsBeginImageContextWithOptions(ColourImage!.size, true, ColourImage!.scale);
        let ctx = UIGraphicsGetCurrentContext()!
        
        // Flip the context to deal with upside-down coordinates
        ctx.translateBy(x: 0.0, y: ColourImage!.size.height);
        ctx.scaleBy(x: 1.0, y: -1.0);
       
        // First, draw colour image into GC
        ctx.draw(ColourImage!.cgImage!, in: CGRect(origin: CGPoint(x: 0, y: 0), size: ColourImage!.size))
        
        // next, define a path bounding the region we want to overwrite...
        let path : UIBezierPath = UIBezierPath()
        if greyPC < 50 {
            // Less than 50% - progress from start direction towards centre:
            //
            //       +-------+
            //       |       |
            //       |       |
            //       |  ---  |
            //       | /   \ |
            //       +/-----\+
            //
            switch greyStart {
            case 2:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                path.addLine(to: CGPoint(x:100, y: 0))
            case 1:
                path.move(to: CGPoint(x: 100, y: 0))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: 100 - greyPC))
                path.addLine(to: CGPoint(x:100, y: 100))
            case 0:
                path.move(to: CGPoint(x: 0, y: 100))
                path.addLine(to: CGPoint(x: greyPC, y: 100 - greyPC))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: 100 - greyPC))
                path.addLine(to: CGPoint(x: 100, y: 100))
            case 3:
                path.move(to: CGPoint(x: 0, y: 100))
                path.addLine(to: CGPoint(x: greyPC, y: 100-greyPC))
                path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                path.addLine(to: CGPoint(x: 0, y: 0))
            default:
                path.move(to: CGPoint(x: greyPC, y: greyPC))
                path.addLine(to: CGPoint(x: greyPC, y: 100-greyPC))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: 100 - greyPC))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
            }
        } else {
            // Greater than 50% - progress from centre in all directions and full from start:
            //
            //       +-------+
            //       |       |
            //       |  +-+  |
            //       |  | |  |
            //       | /   \ |
            //       +/-----\+
            //
            let invPC = 100 - greyPC
            switch greyStart {
            case 2:
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: invPC, y: invPC))
                path.addLine(to: CGPoint(x: invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: invPC))
                path.addLine(to: CGPoint(x: 100, y: 0))
            case 1:
                path.move(to: CGPoint(x: 100, y: 0))
                path.addLine(to: CGPoint(x: 100 - invPC, y: invPC))
                path.addLine(to: CGPoint(x: invPC, y: invPC))
                path.addLine(to: CGPoint(x: invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100, y: 100))
            case 0:
                path.move(to: CGPoint(x: 0, y: 100))
                path.addLine(to: CGPoint(x: invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: invPC, y: invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100, y: 100))
            case 3:
                path.move(to: CGPoint(x: 0, y: 100))
                path.addLine(to: CGPoint(x: invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: invPC))
                path.addLine(to: CGPoint(x: invPC, y: invPC))
                path.addLine(to: CGPoint(x: 0, y:0))
            default:
                path.move(to: CGPoint(x: invPC, y: invPC))
                path.addLine(to: CGPoint(x: invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: 100 - invPC))
                path.addLine(to: CGPoint(x: 100 - invPC, y: invPC))
            }
        }
        
        path.close()
        
        // 	Now, clip graphics context to path
        ctx.addPath(path.cgPath);
        ctx.clip();

        // Now draw in grey image - only clipping region inside path will be affected
        ctx.draw(GreyImage!.cgImage!, in: CGRect(origin: CGPoint(x: 0, y: 0), size: GreyImage!.size))
        
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext(); // clean up and finish context
        
        return NewImage // return image
        
    }
}
