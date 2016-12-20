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
    var bundle: Bundle?
    var neighbours : [PipesGridCell?] = Array(repeating: nil, count: 4)
    var MyRC = (row: 0, col: 0)
    var isRoot = false 
    var isConnectedToRoot = false
    
     func isEmpty() -> Bool
    {
        return !(connections[0] || connections[1] || connections[2] || connections[3])
    }
    
    func  opposite(Dir: Int) -> Int
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
    
    func rotate() {
        let tmp = connections[0]
        connections[0] = connections[1]
        connections[1] = connections[2]
        connections[2] = connections[3]
        connections[3] = tmp ;
        
        mySetImage()
    }
    
    func image() -> String? {
        var Pattern = 0
        
        // determine shape in the array
        Pattern += (connections[0] ? 1 : 0)
        Pattern += (connections[1] ? 8 : 0)
        Pattern += (connections[2] ? 4 : 0)
        Pattern += (connections[3] ? 2 : 0)

        var bFull: Bool = true
        var Name: String
        
        // Determine the colour to use
        if isConnectedToRoot {
            // Connected: Green or orange
            for Dir in 0...3 {
                //see if properly connected in all 4 directions
                if connections[Dir] {
                    if neighbours[Dir] != nil {
                        if !neighbours[Dir]!.connections[opposite(Dir: Dir)] {
                            bFull = false
                        }
                    } else {
                        bFull = false
                    }
                }
            }
            if bFull {
                Name = "G" + String(Pattern)
            } else {
                Name = "O" + String(Pattern)
            }
        } else {
            // not connected
            Name = "R" + String(Pattern)
        }
        
        return Name
    }
    
    func mySetImage() {
        super.setImage(UIImage(named: self.image()!, in: bundle, compatibleWith: self.traitCollection), for: .normal)
    }

    //MARK: Button pressed
    func CellClicked(button: PipesGridCell)
    {
        button.rotate()
    }
 }
