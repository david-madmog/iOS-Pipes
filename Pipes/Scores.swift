//
//  Scores.swift
//  Pipes
//
//  Created by David Poirier on 04/01/2017.
//  Copyright © 2017 David Poirier. All rights reserved.
//

import Foundation
import UIKit

class Score: NSObject, NSCoding {
    var value: Int?
    var restarts: Int?
    var optionSet: gridOptionsSet?
    var whenSet: Date?

    struct PropertyKey {
        static let value = "value"
        static let restarts = "restarts"
        static let optionSet = "optionSet"
        static let whenSet = "whenSet"
    }

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("pipes_Hiscores")
    
    static func sorter(this: Score, that: Score) -> Bool {
        if this.restarts != that.restarts {
            return this.restarts! < that.restarts!
        } else {
            return this.value! > that.value!
        }
    }
    
    func text() -> String {
        var txt = " Score: " + String(describing: self.value!)
        if self.restarts! > 0 {
            txt = txt + " (" + String(describing: self.restarts!) + (self.restarts! > 1 ? " restarts)" : " restart)")
        }
        return txt
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(value, forKey: PropertyKey.value)
        aCoder.encode(restarts, forKey: PropertyKey.restarts)
        aCoder.encode(optionSet, forKey: PropertyKey.optionSet)
        aCoder.encode(whenSet, forKey: PropertyKey.whenSet)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        value = aDecoder.decodeObject(forKey: PropertyKey.value) as? Int
        restarts = aDecoder.decodeObject(forKey: PropertyKey.restarts) as? Int
        optionSet = aDecoder.decodeObject(forKey: PropertyKey.optionSet) as? gridOptionsSet
        whenSet = aDecoder.decodeObject(forKey: PropertyKey.whenSet) as? Date
    }
    
    override init() {
        // Do Nothing!
        super.init()
    }
}

//MARK: High Scores Class
class HighScores  {
    var Scores = [[Score?]]()
    
    static let MAX_ENTRIES = 20
    
    func append(Score: Score) {
        if let ScoreArr = findoptionSetScores(optionSet: Score.optionSet!) {
            Scores[ScoreArr].append(Score)
            Scores[ScoreArr] = sortAndTrimScores(Scores: Scores[ScoreArr] as! [Score])
        } else {
            // No array for this option set, add it
            let ScoreArr = [Score]
         //   ScoreArr.append(Score)
            Scores.append(ScoreArr)
        }
        saveScores()
     }

    func findoptionSetScores(optionSet: gridOptionsSet) -> Int? {
        for i in 0..<Scores.count {
            let T = Scores[i]
            if let FirstScore = T[0]  {
                // There is something in this slot
                if gridOptionsSet.EQ(lhs: FirstScore.optionSet!, rhs: optionSet) {
                    // Cool, this is the one we want
                    return i
                }
            }
        }
        return nil
    }
    
    private func sortAndTrimScores(Scores: [Score]) -> [Score]{
        var NewScores = Scores.sorted(by: Score.sorter)

        while NewScores.count > HighScores.MAX_ENTRIES {
            NewScores.remove(at: NewScores.count - 1)
        }
        
        return NewScores
    }
    
    func saveScores() {
        NSKeyedArchiver.archiveRootObject(Scores, toFile: Score.ArchiveURL.path)
    }
    
    func loadScores() {
        if let S = NSKeyedUnarchiver.unarchiveObject(withFile: Score.ArchiveURL.path) as? [[Score?]] {
            Scores = S
        }
    }
}

// MARK: Options view controller
class HSTableViewController: UITableViewController {
    var HScores: HighScores?
    var gridSettings : gridOptionsSet = gridOptionsSet(rows: 3, cols: 3)

    private var Scores: [Score?]?
    @IBOutlet weak var Nav: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Nav.title = " High Scores for Grid " + String(gridSettings.rows!) + "x" + String(gridSettings.cols!)

        if let ScoreIdx = HScores?.findoptionSetScores(optionSet: gridSettings) {
            Scores = HScores?.Scores[ScoreIdx]
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Scores?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "HSTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HSTableViewCell
        
        // Configure the cell...
        let ScoreSingle = Scores?[indexPath.row] as Score?
        
        cell?.Number.text = String(indexPath.row + 1)
        cell?.Score.text = ScoreSingle?.text()
        // "10/8/16, 10:52 PM"
        if let D = ScoreSingle?.whenSet {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            cell?.Date.text = formatter.string(from: D)
        }
        return cell!
    }

    @IBAction func DoneSelected(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: View Cell
class HSTableViewCell: UITableViewCell {
    @IBOutlet weak var Number: UILabel!
    @IBOutlet weak var Score: UILabel!
    @IBOutlet weak var Date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

