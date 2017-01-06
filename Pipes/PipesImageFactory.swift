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
    
    private enum Curve {
        case left
        case right
        case both
    }
    
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
        var path : UIBezierPath = UIBezierPath()
        switch greyPC {
        case 0...22:
            // Less than 33% - progress from start direction towards centre:
            path.move(to: CGPoint(x: 33, y: 0))
            path.addLine(to: CGPoint(x: 33, y: greyPC))
            path.addLine(to: CGPoint(x: 67, y: greyPC))
            path.addLine(to: CGPoint(x: 67, y:0))
        case 23...33:
            switch connections {
            case 3, 6, 9, 12:
                // elbow
                // Widen out to take in curve
                let dy = 53 * (greyPC - 23) / 27
                if calculateCurve(connections: connections, start: greyStart) == Curve.left {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 23))
                    path.addLine(to: CGPoint(x: 77, y: 23 + dy))
                    path.addLine(to: CGPoint(x: 77, y:0))
                } else {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 23 + dy))
                    path.addLine(to: CGPoint(x: 77, y: 23))
                    path.addLine(to: CGPoint(x: 77, y:0))
                }
            default:
                // just carry on straight through
                path.move(to: CGPoint(x: 33, y: 0))
                path.addLine(to: CGPoint(x: 33, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y:0))
            }
        case 34...50:
            // 33% - 50% fill to the centre:
            switch connections {
            case 1, 2, 4, 5, 8, 10:
                // ending or straight pipe
                // just carry on straight through
                path.move(to: CGPoint(x: 33, y: 0))
                path.addLine(to: CGPoint(x: 33, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y:0))
            case 3, 6, 9, 12:
                // elbow
                let dy = 53 * (greyPC - 23) / 27
                if calculateCurve(connections: connections, start: greyStart) == Curve.left  {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 23))
                    path.addLine(to: CGPoint(x: 77, y: 23 + dy))
                    path.addLine(to: CGPoint(x: 77, y:0))
                } else {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 23 + dy))
                    path.addLine(to: CGPoint(x: 77, y: 23))
                    path.addLine(to: CGPoint(x: 77, y:0))
                }
            default:
                // Junction
                switch calculateCurve(connections: connections, start: greyStart) {
                case Curve.left:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: 100, y: greyPC))
                    path.addLine(to: CGPoint(x: 100, y: 0))
                case Curve.right:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: greyPC))
                    path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: 100, y: 0))
                case Curve.both:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: 100, y: 0))
                }
            }
        case 51...66:
            // 51% - 66% fill the centre:
            switch connections {
            case 1, 2, 4, 8:
                // ending
                path.move(to: CGPoint(x: 33, y: 0))
                path.addLine(to: CGPoint(x: 33, y: 50))
                path.addCurve(to: CGPoint(x: 67, y: 50), controlPoint1: CGPoint(x: 33, y: greyPC), controlPoint2: CGPoint(x: 67, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y:0))
            case 5, 10:
                // Straight through
                path.move(to: CGPoint(x: 33, y: 0))
                path.addLine(to: CGPoint(x: 33, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y:0))
            case 3, 6, 9, 12:
                // elbow
                let dx = 53 * (greyPC - 50) / 27
                if calculateCurve(connections: connections, start: greyStart) == Curve.left {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 23))
                    path.addLine(to: CGPoint(x: 77 - dx, y: 77))
                    path.addLine(to: CGPoint(x: 77, y: 77))
                    path.addLine(to: CGPoint(x: 77, y:0))
                } else {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 77))
                    path.addLine(to: CGPoint(x: 23 + dx, y: 77))
                    path.addLine(to: CGPoint(x: 77, y: 23))
                    path.addLine(to: CGPoint(x: 77, y:0))
                }
            default:
                // Junction
                switch calculateCurve(connections: connections, start: greyStart) {
                case Curve.left:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 100 - greyPC, y: 100 - greyPC))
                    path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: 100, y: greyPC))
                    path.addLine(to: CGPoint(x: 100, y: 0))
                case Curve.right:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: greyPC))
                    path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: greyPC, y: 100 - greyPC))
                    path.addLine(to: CGPoint(x: 100, y: 0))
                case Curve.both:
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 100 - greyPC, y: 100 - greyPC))
                    path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                    path.addLine(to: CGPoint(x: greyPC, y: 100 - greyPC))
                    path.addLine(to: CGPoint(x: 100, y: 0))
                }
            }
        case 67...77:
            // 33% - 50% fill to the centre:
            switch connections {
            case 1, 2, 4, 8:
                // ending
                path.move(to: CGPoint(x: 33, y: 0))
                path.addLine(to: CGPoint(x: 33, y: 50))
                path.addCurve(to: CGPoint(x: 67, y: 50), controlPoint1: CGPoint(x: 33, y: greyPC), controlPoint2: CGPoint(x: 67, y: greyPC))
                path.addLine(to: CGPoint(x: 67, y:0))
            case 3, 6, 9, 12:
                // elbow
                let dx = 53 * (greyPC - 50) / 27
                if calculateCurve(connections: connections, start: greyStart) == Curve.left {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 23))
                    path.addLine(to: CGPoint(x: 77 - dx, y: 77))
                    path.addLine(to: CGPoint(x: 77, y: 77))
                    path.addLine(to: CGPoint(x: 77, y:0))
                } else {
                    path.move(to: CGPoint(x: 23, y: 0))
                    path.addLine(to: CGPoint(x: 23, y: 77))
                    path.addLine(to: CGPoint(x: 23 + dx, y: 77))
                    path.addLine(to: CGPoint(x: 77, y: 23))
                    path.addLine(to: CGPoint(x: 77, y:0))
                }
            default:
                // Junction & Straight through
                path.move(to: CGPoint(x: 100 - greyPC, y: 0))
                path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
                path.addLine(to: CGPoint(x: greyPC, y: greyPC))
                path.addLine(to: CGPoint(x: greyPC, y:0))
            }
        default:
            // Greater than 77% - progress from centre in all directions and full from start:
            path.move(to: CGPoint(x: 100 - greyPC, y: 0))
            path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
            path.addLine(to: CGPoint(x: greyPC, y: greyPC))
            path.addLine(to: CGPoint(x: greyPC, y:0))
        }
    
        // Rotate the picture based on the direction we're coming from
        switch greyStart {
        case 2:
            break;
        case 1:
            path = rotatePath(path: path, steps: 1)
        case 0:
            path = rotatePath(path: path, steps: 2)
        case 3:
            path = rotatePath(path: path, steps: 3)
        default:
            path.removeAllPoints()
            path.move(to: CGPoint(x: greyPC, y: greyPC))
            path.addLine(to: CGPoint(x: greyPC, y: 100-greyPC))
            path.addLine(to: CGPoint(x: 100 - greyPC, y: 100 - greyPC))
            path.addLine(to: CGPoint(x: 100 - greyPC, y: greyPC))
        }

        path.close()
        
        // Clip graphics context to path
        ctx.addPath(path.cgPath);
        ctx.clip();

        // Finally draw in grey image - only clipping region inside path will be affected
        ctx.draw(GreyImage!.cgImage!, in: CGRect(origin: CGPoint(x: 0, y: 0), size: GreyImage!.size))
        
        let NewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext(); // clean up and finish context
        
        return NewImage // return image
        
    }
    
    private func rotatePath(path: UIBezierPath, steps: Int) -> UIBezierPath {
//        var transform = CGAffineTransform(translationX: -50, y: -50)
//        //transform = transform.translatedBy(x: -50, y: -50)
//        transform = transform.rotated(by: CGFloat(Float(steps) * Float.pi / 2))
//        transform = transform.translatedBy(x: 50, y: 50)
        let transform = CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 100, ty: 0)
        
        for _ in 0 ..< steps {
            path.apply(transform)
        }
        return path
    }
    
    private func calculateCurve(connections: Int, start: Int) -> Curve {
        var L = 0
        var R = 0
        
        switch start {
        case 0:
            L = 8
            R = 2
        case 1:
            L = 4
            R = 1
        case 2:
            L = 2
            R = 8
        default:
            L = 1
            R = 4
        }
        
        if connections & L == 0 {
            // no L, must be R
            return Curve.right
        } else {
            // has L
            if connections & R == 0 {
                // L but no R
                return Curve.left
            } else {
                return Curve.both
            }
        }
    }
}
