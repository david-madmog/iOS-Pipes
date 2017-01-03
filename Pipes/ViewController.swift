//
//  ViewController.swift
//  Pipes
//
//  Created by David Poirier on 16/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ValueReturner {

    @IBOutlet weak var Grid: PipesGrid!
    @IBOutlet weak var Progress: UIProgressView!
    @IBOutlet weak var ScoreLabel: UILabel!
        
    var Score: Int = 0
    var timer = Timer()
    private var TimerCounter = 0
    var FillingInterval = 2
    var returnValueToCaller: ((Any) -> ())?
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        Progress.progress = 1.0
        Score = 10000
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TimerFired), userInfo: nil, repeats: true)
        Grid.CurrentGameMode = .Initialising
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func RandomizeButton(_ sender: Any) {
        Progress.progress = 1.0
        Score = 10000
        timer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(TimerFired), userInfo: nil, repeats: true)
        TimerCounter = 0
        Grid.CurrentGameMode = .Initialising
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    func TimerFired()
    {
        TimerCounter += 1
        
        switch Grid.CurrentGameMode {
        case .Initialising,
             .Generating:
            Grid.Randomise()
        case .GracePeriod:
            if TimerCounter % FillingInterval == 0 {
                Score -= 1
                ScoreLabel.text = "Score: " + String(describing: Score)
                
                if Progress.progress > 0 {
                    Progress.progress -= 0.02
                } else {
                    Grid.CurrentGameMode = .Filling
                    Grid.FillInit()
                }
            }
            if Grid.isFinished() {
                Grid.CurrentGameMode = .Finished
            }
        case .Filling:
            if TimerCounter % FillingInterval == 0 {
                Score -= 1
                ScoreLabel.text = "Score: " + String(describing: Score)
                Grid.Fill()
            }	
            if Grid.isFinished() {
                Grid.CurrentGameMode = .FinalFilling
            }
        case .FinalFilling:
            Grid.Fill(step: 5)
            _ = Grid.isFinished() // easiest way to redraw...
        case .Spilt:
            let alert = UIAlertController(title: "You spilt the water", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let abandon = UIAlertAction(title: "Abandon Game", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                self.Grid.CurrentGameMode = .Finished
            }
            
            let cont = UIAlertAction(title: "Carry On playing", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                // Do something when email is tapped
                self.Grid.CurrentGameMode = .GracePeriod
                self.Progress.progress = 1.0
            }
            
            alert.addAction(abandon)
            alert.addAction(cont)
            
            Grid.CurrentGameMode = .SpiltQuery
            present(alert, animated: true, completion: nil)
            break
        case .SpiltQuery:
            break // do nothing while waiting for response
        case .Finished:
            timer.invalidate()
            returnValueToCaller?(Score)
            self.dismiss(animated: true)
        }
    }
    
    
}

