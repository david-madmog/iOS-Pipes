		//
//  PipesGrid.swift
//  Pipes
//
//  Created by David Poirier on 16/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

@IBDesignable class PipesGrid: UIStackView {
   
    var Cells = [[PipesGridCell?]]()
    private var ImageFactory: PipesImageFactory?
    private static let FULL = 200

    enum GameMode {
        case Initialising
        case Generating
        case GracePeriod
        case Filling
        case Spilt
        case SpiltQuery
        case FinalFilling
        case Finished
    }
    
    var CurrentGameMode: GameMode = .Initialising
    
   
    //MARK: Init
    override init(frame: CGRect) {
        // Used by Interface Builder
        super.init(frame: frame)
        setupButtons(rows:7, cols:5)
    }
    
    required init(coder: NSCoder)
    {
        // Used by runtime
        super.init(coder: coder)
    }

    func SetSize(rows: Int, cols: Int) {
        
        for SV in self.subviews {
            self.removeArrangedSubview(SV)
        }
        Cells.removeAll(keepingCapacity: true)
        setupButtons(rows: rows, cols: cols)
    }
    
    private func setupButtons(rows: Int, cols: Int) {
        
        let invRows: CGFloat = CGFloat(1.0) / CGFloat(rows)
        let invCols: CGFloat = CGFloat(1.0) / CGFloat(cols)
        let bundle = Bundle(for: type(of: self))
        
        ImageFactory = PipesImageFactory(in: bundle, compatibleWith: self.traitCollection)
        
        for row in 0..<rows {
            // Create a horizontal stack view
            let HSV = UIStackView()
            
            addArrangedSubview(HSV)
            HSV.axis = UILayoutConstraintAxis.horizontal
            HSV.heightAnchor.constraint(equalTo: super.heightAnchor, multiplier: invRows).isActive = true
            HSV.widthAnchor.constraint(equalTo: super.widthAnchor, multiplier: 1).isActive = true
            
            Cells.append([])
            
            for col in 0..<cols {
                // Create the button
                let button = PipesGridCell()
                button.MyRC = (row, col)
                Cells[row].append(button)
                button.contentMode = UIViewContentMode.scaleToFill
                button.contentVerticalAlignment = UIControlContentVerticalAlignment.fill
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.fill
                button.mySetImage(ImageFactory: self.ImageFactory!)
                
                // Add the button to the stack
                HSV.addArrangedSubview(button)
                
                // Add constraints
                //button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalTo: HSV.heightAnchor, multiplier: 1).isActive = true
                button.widthAnchor.constraint(equalTo: HSV.widthAnchor, multiplier: invCols).isActive = true
                button.addTarget(self, action: #selector(PipesGrid.CellClicked(button:)), for: .touchUpInside)
            }
            
        }
        
        // Now we've created them all, we can set up their neigbours
        for row in 0..<rows {
            for col in 0..<cols {
                if col > 0 {
                    Cells[row][col]!.neighbours[3] = Cells[row][col-1]
                }
                if row < (rows-1) {
                    Cells[row][col]!.neighbours[2] = Cells[row+1][col]
                }
                if col < (cols-1) {
                    Cells[row][col]!.neighbours[1] = Cells[row][col+1]
                }
                if row > 0 {
                    Cells[row][col]!.neighbours[0] = Cells[row-1][col]
                }
            }
        }
        
        
    }

    
    
    // MARK: Set up puzzle
    func Randomise()
    {
        // called from timer to increase puzzle fill state
        
        if self.CurrentGameMode == .Initialising {
            // First time through: reset all the cells to empty
            for A in Cells {
                for Cell in A {
                    for k in 0...3 {
                        Cell!.connections[k] = false
                    }
                    Cell!.isRoot = false
                    Cell!.isConnectedToRoot = false
                    Cell!.greyPC = 0 ;
                    Cell!.mySetImage(ImageFactory: self.ImageFactory!)
                }
            }
        }
        
        CurrentGameMode = .Generating
        
        // building the initial grid...
        let EmptyCount = CountEmptyCells()
        
        if EmptyCount > 0
        {
            GrowConnection(EmptyCount: EmptyCount)
        } else {
            RandomiseCellRotations()
            _ = CheckCellRootConnections()
            CurrentGameMode = .GracePeriod
            //restarts = 0 ;
        }
    }
    
    private func CountEmptyCells() -> Int
    {
        var count = 0
        for A in Cells {
            for Cell in A {
                if Cell!.isEmpty() {
                    count += 1
                }
            }
        }
        return count ;
    }
    
    private func GrowConnection(EmptyCount: Int) {
        var bDone = false
        var bFirstTime = true
        var i:Int = 0
        var j:Int = 0
        
        
        let xs = Cells.count
        let ys = Cells[0].count
        
        if EmptyCount > 0 {
            if EmptyCount == xs * ys {
                // very first time, Make root
                i = Int(arc4random_uniform(UInt32(xs)))
                j = Int(arc4random_uniform(UInt32(ys)))
                Cells[i][j]!.isRoot = true ;
            } else {
                // ensure we start this growth on a connected cell
                
                //V2 Algorithm: not only connected, but with empty neighbour
                // So, find all edge cells and pick one at random
                let Edges = FindEdgeCells()
                let GrowthBase = Edges[Int(arc4random_uniform(UInt32(Edges.count)))]
                (i, j) = GrowthBase.MyRC
            }
            
            repeat {
                bDone = true ;
                
                // We've now got a starting cell for this growth, connected to the root
                // Continue from this cell, and pick a direction
                var k = Int(arc4random_uniform(UInt32(4)))
                
                // First time this loop... must be an empty neibour somewhere, so ensure we've hit it
                if bFirstTime {
                    var bLocalDone = false
                    while !bLocalDone {
                        k = Int(arc4random_uniform(UInt32(4)))
                        
                        if Cells[i][j]!.neighbours[k] != nil {
                            if Cells[i][j]!.neighbours[k]!.isEmpty() {
                                bLocalDone = true
                            }
                        }
                    }
                }
                bFirstTime = false
                
                // don't stop if not falling off the edge and not linking back
                if Cells[i][j]!.neighbours[k] != nil {
                    if Cells[i][j]!.neighbours[k]!.isEmpty() {
                        // Link cells
                        Cells[i][j]!.connections[k] = true
                        Cells[i][j]!.neighbours[k]!.connections[PipesGridCell.opposite(Dir: k)] = true
                        Cells[i][j]!.mySetWorkingActivity()
                        Cells[i][j]!.neighbours[k]!.mySetWorkingActivity()
                        
                        // and move into this cell
                        (i, j) = Cells[i][j]!.neighbours[k]!.MyRC
                        
                        bDone = false ;
                    }
                }
                
                _ = CheckCellRootConnections(Redraw: false) ;
            } while !bDone
        }
    }
    
    
    func CheckCellRootConnections(Redraw: Bool = true) -> Int
    {
        var bDoneOne = true ;
        
        for A in Cells {
            for Cell in A {
                Cell!.isConnectedToRoot = false ;
            }
        }
        
        
        // Find root
        while bDoneOne
        {
            bDoneOne = false ;
            for A in Cells {
                for Cell in A {
                    if !Cell!.isConnectedToRoot {
                        if Cell!.isRoot {
                            Cell!.isConnectedToRoot = true ;
                            bDoneOne = true ;
                        }
                        for k in 0...3 {
                            if Cell!.connections[k] {
                                if Cell?.neighbours[k] != nil {
                                    if Cell!.neighbours[k]!.connections[(k + 2) % 4] {
                                        if (Cell!.neighbours[k]?.isConnectedToRoot)! {
                                            Cell!.isConnectedToRoot = true ;
                                            bDoneOne = true ;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        var count = 0
        for A in Cells {
            for Cell in A {
                if Redraw {
                    Cell!.mySetImage(ImageFactory: self.ImageFactory!)
                }
                if !Cell!.isConnectedToRoot {
                    count += 1
                }
            }
        }
        return count ;
    }
    
    
    private func RandomiseCellRotations() {
        for A in Cells {
            for Cell in A {
                let k = Int(arc4random_uniform(UInt32(4)))
                for _ in 0...k {
                    Cell!.rotate()
                    Cell!.mySetImage(ImageFactory: self.ImageFactory!)
                }
            }
        }
        
    }
    
    private func FindEdgeCells() -> Array<PipesGridCell> {
        var Edges = Array<PipesGridCell>()
        
        for A in Cells {
            for Cell in A {
                if (Cell!.isConnectedToRoot) {
                    // Does it have any empty neibours?
                    for k in 0...3 {
                        if Cell!.neighbours[k] != nil {
                            if Cell!.neighbours[k]!.isEmpty() {
                                Edges.append(Cell!)
                            }
                        }
                    }
                }
            }
        }
        
        return Edges
    }
    
    func isFinished() -> Bool {
        return CheckCellRootConnections() == 0
    }
    
    //MARK: Button pressed
    func CellClicked(button: UIButton)
    {
        let Cell: PipesGridCell = button as! PipesGridCell
        Cell.rotate()
        Cell.mySetImage(ImageFactory: self.ImageFactory!)
        _ = CheckCellRootConnections()
        if Cell.greyPC >= 100 {
            Cell.greyPC = 99
        }
    }
    
    // MARK: timer fired in "Filling" mode
    func FillInit()
    {
        for A in Cells {
            for Cell in A {
                if Cell!.isRoot && Cell!.greyPC == 0
                {
                    Cell!.greyPC = 50
                }
                if Cell!.greyPC >= 100
                {
                    // Might be after a restart
                    // Reset to nearly full so will reevaluate spread to neighbours
                    Cell!.greyPC = 99
                }
            }
        }
       
    }
    
    func Fill(step: Int = 1)
    {
        var bFull = true
        
        // Have we finished filling all cells?
        for A in Cells {
            for Cell in A {
                if Cell!.greyPC < 100 {
                    bFull = false
                    break
                }
            }
        }
        if bFull {
            // Yes, so move on to next mode
            CurrentGameMode = .Finished
        }
        
        for A in Cells {
            for Cell in A {
                // Has this cell started filling
                if Cell!.greyPC > 0 && Cell!.greyPC < PipesGrid.FULL {
                    Cell!.greyPC += step
                }
                // Has it just reached total fullness...?
                // If so, spread it or spill...
                if Cell!.greyPC >= 100 && Cell!.greyPC < PipesGrid.FULL {
                    Cell!.greyPC = PipesGrid.FULL
                    for Dir in 0...3 {
                        //see if properly connected
                        if Cell!.connections[Dir] {
                            if Cell!.neighbours[Dir] != nil {
                                if Cell!.neighbours[Dir]!.connections[PipesGridCell.opposite(Dir: Dir)] {
                                    // Properly connected, so spread
                                    if Cell!.neighbours[Dir]!.greyPC == 0 {
                                        Cell!.neighbours[Dir]!.greyPC = 1
                                        Cell!.neighbours[Dir]!.greyStart = PipesGridCell.opposite(Dir: Dir)
                                    }
                                } else {
                                    // Has neibour, but not connected
                                    CurrentGameMode = .Spilt
                                }
                            } else {
                                // At edge of board... can't be connected there!
                                CurrentGameMode = .Spilt
                            }
                        }
                    }
     
                }
                
            }
        }
        
        
    }
}
