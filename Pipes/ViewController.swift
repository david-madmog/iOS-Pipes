//
//  ViewController.swift
//  Pipes
//
//  Created by David Poirier on 16/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit


//MARK: GridSettingsAPI

// Used to pass parameters of grid settings into views from menu, and to pass something back as a result
protocol GridSettingsAPI {
    var gridSettings : gridOptionsSet { get set }
    var FinalScoreFunc: ((Any) -> ())?  { get set }
}


//MARK: View Controller

// Main view controller for game grid
class ViewController: UIViewController, GridSettingsAPI {

    // Control linkages
    @IBOutlet weak var Grid: PipesGrid!
    @IBOutlet weak var Progress: UIProgressView!
    @IBOutlet weak var ScoreLabel: UILabel!
    
    
    //var Score: Int = 0
    private var currScore = Score()
    private var timer = Timer()
    private var TimerCounter = 0
    private var FillingInterval = 2

    // GridSettingsAPI
    var gridSettings : gridOptionsSet = gridOptionsSet(rows: 3, cols: 3)
    var FinalScoreFunc: ((Any) -> ())?
 
    // MARK: Initialise
    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: make score/timer pstuff part of settings
        Progress.progress = 1.0
        currScore.value = 10000
        currScore.restarts = 0
        currScore.optionSet = gridSettings
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TimerFired), userInfo: nil, repeats: true)
        Grid.SetSize(rows: gridSettings.rows!, cols: gridSettings.cols!)
        Grid.CurrentGameMode = .Initialising
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }

    // Main processing loop here: Driven by state machine and timer
    func TimerFired()
    {
        TimerCounter += 1
        
        switch Grid.CurrentGameMode {
        case .Initialising,
             .Generating:
            Grid.Randomise()
        case .GracePeriod:
            if TimerCounter % FillingInterval == 0 {
                currScore.value! -= 1
                ScoreLabel.text = currScore.text()
                
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
                currScore.value! -= 1
                ScoreLabel.text = currScore.text()
                Grid.Fill()
            }	
            if Grid.isFinished() {
                Grid.CurrentGameMode = .FinalFilling
            }
        case .FinalFilling:
            Grid.Fill(step: 5)
            _ = Grid.isFinished() // easiest way to redraw...
        case .Spilt:
            currScore.restarts! += 1
            
            // Ask the user what they want to do, and set state accordingly
            let alert = UIAlertController(title: "You spilt the water", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let abandon = UIAlertAction(title: "Abandon Game", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
                self.Grid.CurrentGameMode = .Finished
                self.currScore.value = 0
            }
            
            let cont = UIAlertAction(title: "Carry On playing", style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in
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
            currScore.whenSet = Date()
            FinalScoreFunc?(currScore)
            self.dismiss(animated: true)
        }
    }
    
    
}

