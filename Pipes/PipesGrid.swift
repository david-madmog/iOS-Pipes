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
        setupButtons()
    }
    
    required init(coder: NSCoder)
    {
        // Used by runtime
        super.init(coder: coder)
        setupButtons()
    }

    private func setupButtons() {
        
        // Create the button
        let button = UIButton()
        button.backgroundColor = UIColor.red
        
        // Add constraints
        button.translatesAutoresizingMaskIntoConstraints = false
        //button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        //button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
        button.addTarget(self, action: #selector(PipesGrid.CellClicked(button:)), for: .touchUpInside)
        //button.center = CGPoint(x:20, y:20)
        button.frame = CGRect(x:100, y:100, width:500, height:50)
        
        // Add the button to the stack
        addSubview(button)
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
