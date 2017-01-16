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
    
    @IBOutlet var Panner: UIPanGestureRecognizer!
    
    //var Score: Int = 0
    private var currScore = Score()
    private var timer = Timer()
    private var TimerCounter = 0
    private var FillingInterval = 2
    
    let MinCellSize = CGFloat(60.0)

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
        
        // If cells will be too small, then enlarge whole grid...
        if (Grid.bounds.width / CGFloat(gridSettings.cols!)) < MinCellSize {
            Grid.frame.size.width = MinCellSize * CGFloat(gridSettings.cols!)
        }
        if (Grid.bounds.height / CGFloat(gridSettings.rows!)) < MinCellSize {
            Grid.frame.size.height = MinCellSize * CGFloat(gridSettings.rows!)
        }
        
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
                Grid.CurrentGameMode = .FinalFilling
                Grid.FillInit()
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
            // scale so we can see the whole thing
            if Grid.bounds.width > self.view.bounds.width {
                Grid.frame.size.width = self.view.bounds.width
                Grid.center.x = Grid.frame.size.width / 2
            }
            if Grid.bounds.height > (self.view.bounds.height - UIApplication.shared.statusBarFrame.height) {
                Grid.frame.size.height = (self.view.bounds.height - UIApplication.shared.statusBarFrame.height)
                Grid.center.y = (Grid.frame.size.height / 2) + UIApplication.shared.statusBarFrame.height
            }
            
            Grid.Fill(step: 10)
            _ = Grid.isFinished() // easiest way to redraw...
        case .Spilt:
            currScore.restarts! += 1
            
            // Ask the user what they want to do, and set state accordingly
            let alert = UIAlertController(title: "Spill", message:"You spilt the water", preferredStyle: UIAlertControllerStyle.actionSheet)
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
    
    @IBAction func PanGesture(_ sender: UIPanGestureRecognizer) {
        var translation = sender.translation(in: self.view)
        if let view = sender.view {
            // BTW, we know really that view is the pipes grid, since that's the only view with a gesture recogniser
            
            //Lock panning to bounds of screen
            let left = view.center.x - (view.bounds.width / 2)
            let top = view.center.y - (view.bounds.height / 2)
            let right = view.center.x + (view.bounds.width / 2)
            let bottom = view.center.y + (view.bounds.height / 2)
            
            if view.bounds.width < self.view.bounds.width {
                translation.x = 0
            } else if translation.x + left > 0 {
                translation.x = -left
            } else if translation.x + right < self.view.bounds.width {
                translation.x = self.view.bounds.width - right
            }
            
            if view.bounds.height < (self.view.bounds.height - UIApplication.shared.statusBarFrame.height) {
                translation.y = 0
            } else if translation.y + top > UIApplication.shared.statusBarFrame.height {
                translation.y = UIApplication.shared.statusBarFrame.height - top
            } else if translation.y + bottom < self.view.bounds.height {
                translation.y = self.view.bounds.height - bottom
            }
            
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    
    }
    
}

