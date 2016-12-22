//
//  PipesGridCell.swift
//  Pipes
//
//  Created by David Poirier on 16/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

class PipesGridCell: UIButton {
  
    var connections : [Bool] = Array(repeating: false, count: 4)
    var neighbours : [PipesGridCell?] = Array(repeating: nil, count: 4)
    var MyRC = (row: 0, col: 0)
    var isRoot = false 
    var isConnectedToRoot = false
    var greyPC = 0
    var greyStart = -1
    
    func isEmpty() -> Bool
    {
        return !(connections[0] || connections[1] || connections[2] || connections[3])
    }
    
    static func opposite(Dir: Int) -> Int
    {
        return (Dir + 2) % 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for i in 0 ... 3 {
            connections[i] = RandomBool()
        }
    }
    
    override init(frame: CGRect) {
        // Used by Interface Builder
        super.init(frame: frame)
        for i in 0 ... 3 {
            connections[i] = RandomBool()
        }
    }
    
    private func RandomBool() -> Bool {
        return (arc4random_uniform(UInt32(1000)) < 500 ? true : false)
    }

    private func RandomFlt() -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(255))) / 255.0
    }
    
    func rotate() {
        let tmp = connections[0]
        connections[0] = connections[1]
        connections[1] = connections[2]
        connections[2] = connections[3]
        connections[3] = tmp ;
    }
    
    func mySetImage(ImageFactory: PipesImageFactory) {
        var Pattern = 0
        
        // determine shape in the array
        Pattern += (connections[0] ? 1 : 0)
        Pattern += (connections[1] ? 8 : 0)
        Pattern += (connections[2] ? 4 : 0)
        Pattern += (connections[3] ? 2 : 0)

        var bFull: Bool = true
        let Colour: String
        
        // Determine the colour to use
        if isConnectedToRoot {
            // Connected: Green or orange
            for Dir in 0...3 {
                //see if properly connected in all 4 directions
                if connections[Dir] {
                    if neighbours[Dir] != nil {
                        if !neighbours[Dir]!.connections[PipesGridCell.opposite(Dir: Dir)] {
                            bFull = false
                        }
                    } else {
                        bFull = false
                    }
                }
            }
            if bFull {
                Colour = "G"
            } else {
                Colour = "O"
            }
        } else {
            // not connected
            Colour = "R"
        }
        
        super.setImage(ImageFactory.PipeImage(colour: Colour, connections: Pattern, greyPC: greyPC, greyStart: greyStart), for: .normal)
    }
    
    func mySetWorkingActivity() {
        super.setImage(nil, for: .normal)
        super.backgroundColor = UIColor(red: RandomFlt(), green: RandomFlt(), blue: RandomFlt(), alpha: 1)
    }
 }
