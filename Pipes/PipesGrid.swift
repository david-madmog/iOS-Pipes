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

    enum GameMode {
        case Initialising
        case Generating
        case GracePeriod
        case Filling
        case Spilt
        case Finished
    }
    
    var CurrentGameMode: GameMode = .Initialising
    
   
    //MARK: Init
    override init(frame: CGRect) {
        // Used by Interface Builder
        super.init(frame: frame)
        setupButtons(rows:5, cols:5)
    }
    
    required init(coder: NSCoder)
    {
        // Used by runtime
        super.init(coder: coder)
        setupButtons(rows:10, cols:10)
    }

    // MARK: Set up puzzle
    func Randomise()
    {
        // Reset all the cells to empty
        for A in Cells {
            for Cell in A {
                for k in 0...3 {
                    Cell!.connections[k] = false
                }
                Cell!.isRoot = false
                Cell!.isConnectedToRoot = false
                Cell?.mySetImage()
                //Cell.GreyPC = 0 ;
            }
        }
        
        // Set mode
 //       OwnDrawPanel ODP = (OwnDrawPanel) mainPanel ;
 //       ODP.DM = OwnDrawPanel.DrawModes.ModeWorking ;
 //       ODP.Score = 10000 ;
        
        // building the initial grid...
        var EmptyCount = CountEmptyCells()
        
        while EmptyCount > 0
        {
            GrowConnection(EmptyCount: EmptyCount)
            EmptyCount = CountEmptyCells()
        }
        
        RandomiseCellRotations() ;
        CheckCellRootConnections() ;
        //Restarts = 0 ;
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
//    var bFirstTime = true
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
//            List<PipeCell> EdgeCells = FindEdgeCells() ;
//            PipeCell GrowthBase = EdgeCells.get(R.nextInt(EdgeCells.size())) ;
//            i = GrowthBase.MyX ;
//            j = GrowthBase.MyY ;
            
            repeat {
                bDone  = false
                i = Int(arc4random_uniform(UInt32(xs)))
                j = Int(arc4random_uniform(UInt32(ys)))

                if Cells[i][j]!.isConnectedToRoot {
                    // Does it have any empty neibours?
                    for k in 0...3 {
                        if Cells[i][j]!.neighbours[k] != nil {
                            if Cells[i][j]!.neighbours[k]!.isEmpty() {
                                bDone = true ;
                            }
                        }
                    }
                }
            } while !bDone
        }
        
        repeat {
            bDone = true ;
    
            // We've now got a starting cell for this growth, connected to the root
            // Continue from this cell, and pick a direction
            var k = Int(arc4random_uniform(UInt32(4)))
    
            // First time... must be an empty neibour somewhere, so ensure we've hit it
//            if bFirstTime {
//                while (Cells[i][j]!.neighbours[k]?.isConnectedToRoot)! {
//                    k = Int(arc4random_uniform(UInt32(4)))
//                }
//            }
//            bFirstTime = false
    
            // stop if falling off the edge or linking back
            if Cells[i][j]!.neighbours[k] != nil {
                if Cells[i][j]!.neighbours[k]!.isEmpty() {
                    // Link cells
                    Cells[i][j]!.connections[k] = true
                    Cells[i][j]!.neighbours[k]!.connections[Cells[i][j]!.opposite(Dir: k)] = true
                    Cells[i][j]!.mySetImage()
                    Cells[i][j]!.neighbours[k]!.mySetImage()
                    
//                    print ("Cell " + String(i) + "," + String(j) + ":" + String(k))
                
    
                    // and move into this cell
                    (i, j) = Cells[i][j]!.neighbours[k]!.MyRC

                    bDone = false ;
                }
            }
    
            CheckCellRootConnections() ;
        } while !bDone
    }
}

    
func CheckCellRootConnections()
//func CheckCellRootConnections() -> Int
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

    
//    var count = 0
    for A in Cells {
        for Cell in A {
            Cell!.mySetImage()
//            if !Cell!.isConnectedToRoot {
//                count += 1
//            }
        }
    }
//    return count ;
}
 
    
func RandomiseCellRotations() {
    for A in Cells {
        for Cell in A {
            let k = Int(arc4random_uniform(UInt32(4)))
            for _ in 0...k {
                Cell!.rotate()
            }
        }
    }
    
}
    
/*
    
    private List<PipeCell> FindEdgeCells() {
    List<PipeCell> ECS = new ArrayList<PipeCell>() ;
    
    for (int i = 0; i< xs; i++) {
    for (int j = 0; j< ys; j++) {
    // Must be connected
    Cells[i][j].IsEdge = false ;
    if (Cells[i][j].IsConnectedToRoot) {
    // Does it have any empty neibours?
    for (int k = 0; k<4 ; k++) {
    if (Cells[i][j].Neighbours[k] != null) {
    if (Cells[i][j].Neighbours[k].IsEmpty()) {
    Cells[i][j].IsEdge = true ;
    ECS.add(Cells[i][j]);
    }
    }
    }
    }
    }
    }
    return ECS ;
    }
*/
    
    
    private func setupButtons(rows: Int, cols: Int) {
        
        let invRows: CGFloat = CGFloat(1.0) / CGFloat(rows)
        let invCols: CGFloat = CGFloat(1.0) / CGFloat(cols)
        let bundle = Bundle(for: type(of: self))
        
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
                button.bundle = bundle
                button.MyRC = (row, col)
                Cells[row].append(button)
                
                button.mySetImage()
               
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

    //MARK: Button pressed
    func CellClicked(button: UIButton)
    {
        let Cell: PipesGridCell = button as! PipesGridCell
        Cell.CellClicked(button: Cell)
        CheckCellRootConnections()
    }
    
    func TimerFired()
    {
        
    }
}
