//
//  PipesGrid.swift
//  Pipes
//
//  Created by David Poirier on 16/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

@IBDesignable class PipesGrid: UIStackView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

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
        setupButtons(rows:5, cols:5)
    }

    private func setupButtons(rows: Int, cols: Int) {
        
        let invRows: CGFloat = CGFloat(1.0) / CGFloat(rows)
        let invCols: CGFloat = CGFloat(1.0) / CGFloat(cols)
        
        for row in 1...rows {
            // Create a horizontal stack view
            let HSV = UIStackView()
            
            addArrangedSubview(HSV)
            HSV.axis = UILayoutConstraintAxis.horizontal
            HSV.heightAnchor.constraint(equalTo: super.heightAnchor, multiplier: invRows).isActive = true
            HSV.widthAnchor.constraint(equalTo: super.widthAnchor, multiplier: 1).isActive = true
            
            for col in 1...cols {
                let button = UIButton()
                switch (row + col) % 3 {
                case 0:
                    button.backgroundColor = UIColor.red
                case 1:
                    button.backgroundColor = UIColor.green
                default:
                    button.backgroundColor = UIColor.blue
                }
               
                // Add the button to the stack
                HSV.addArrangedSubview(button)

                // Add constraints
                //button.translatesAutoresizingMaskIntoConstraints = false
                button.heightAnchor.constraint(equalTo: HSV.heightAnchor, multiplier: 1).isActive = true
                button.widthAnchor.constraint(equalTo: HSV.widthAnchor, multiplier: invCols).isActive = true
                button.addTarget(self, action: #selector(PipesGrid.CellClicked(button:)), for: .touchUpInside)
                //button.center = CGPoint(x:20, y:20)
                //button.frame = CGRect(x:100, y:100, width:50, height:50)
                
            }
            
        }
        
        
        // Create the button
    }

    //MARK: Button pressed
    func CellClicked(button: UIButton)
    {
        let BGC:UIColor! = button.backgroundColor
        switch  BGC {
        case UIColor.red:
            button.backgroundColor = UIColor.green
        case UIColor.green:
            button.backgroundColor = UIColor.blue
        default:
            button.backgroundColor = UIColor.red
        }
    }
    
}
