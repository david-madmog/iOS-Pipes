//
//  ViewController.swift
//  Pipes
//
//  Created by David Poirier on 16/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var Grid: PipesGrid!
    @IBOutlet weak var Progress: UIProgressView!
    @IBOutlet weak var ScoreLabel: UILabel!
        
    var Score: Int = 0
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func RandomizeButton(_ sender: Any) {
        Grid.Randomise()
        Progress.progress = 1.0
        Score = 1000
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TimerFired), userInfo: nil, repeats: true)
    }

    
    func TimerFired()
    {
        Score -= 1
        ScoreLabel.text = "Score: " + String(describing: Score)
        if Progress.progress > 0 {
            Progress.progress -= 0.005
        }
    }
    
    /*
    Important note: because your object has a property to store the timer, and the timer calls a method on the object, you have a strong reference cycle that means neither object can be freed. To fix this, make sure you invalidate the timer when you're done with it, such as when your view is about to disappear:
    
    gameTimer.invalidate()
 */
    
}

