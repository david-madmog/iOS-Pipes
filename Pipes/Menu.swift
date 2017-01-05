//
//  Menu.swift
//  Pipes
//
//  Created by David Poirier on 21/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

class Menu: UIViewController {

    @IBOutlet weak var Score: UILabel!
    @IBOutlet weak var GridOptions: UILabel!

    var gridSettings: gridOptionsSet = gridOptionsSet(rows: 0, cols: 0)
    var HScores = HighScores()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let loadedGridSettings = NSKeyedUnarchiver.unarchiveObject(withFile: gridOptionsSet.ArchiveURL.path) as? gridOptionsSet {
            gridSettings = loadedGridSettings
        } else {
            gridSettings = gridOptionsSet(rows: 7, cols: 5)
        }
        HScores.loadScores()
        
        GridOptions.text = " Grid " + String(gridSettings.rows!) + "x" + String(gridSettings.cols!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Options and Main game views
        if var secondViewController = segue.destination as? GridSettingsAPI {
            secondViewController.FinalScoreFunc = GameReturnValue
            secondViewController.gridSettings = gridSettings
        }
        
        // High Scores View - actually a child of segue view vontroller
        for CVC in segue.destination.childViewControllers {
            if let svc = CVC as? HSTableViewController {
                svc.HScores = HScores
                svc.gridSettings = gridSettings
            }
        }
    }
    
    // Called back just before second view closes to pass back return value
    func GameReturnValue(returnedValue: Any) {
        
        // From game grid: Returns Score
        if let RetScore = returnedValue as? Score {
            Score.text = RetScore.text()
            
            HScores.append(Score: RetScore)
        }
        
        // From options: returns options set
        if let retGridOptions = returnedValue as? gridOptionsSet {
            gridSettings = retGridOptions
            _ = NSKeyedArchiver.archiveRootObject(gridSettings, toFile: gridOptionsSet.ArchiveURL.path)
            GridOptions.text = " Grid " + String(gridSettings.rows!) + "x" + String(gridSettings.cols!)
        }
    }
}
