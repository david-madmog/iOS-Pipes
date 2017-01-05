//
//  Options.swift
//  Pipes
//
//  Created by David Poirier on 03/01/2017.
//  Copyright © 2017 David Poirier. All rights reserved.
//

import Foundation
import UIKit

//MARK: GridOptionsSet
// Class for persistence of options
class gridOptionsSet: NSObject, NSCoding {
    var rows: Int?
    var cols: Int?
    
    struct PropertyKey {
        static let rows = "rows"
        static let cols = "cols"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("pipes")
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(rows, forKey: PropertyKey.rows)
        aCoder.encode(cols, forKey: PropertyKey.cols)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let rows = aDecoder.decodeObject(forKey: PropertyKey.rows) as? Int
        let cols = aDecoder.decodeObject(forKey: PropertyKey.cols) as? Int
    
        self.init(rows: rows, cols: cols)
    }
    
    init(rows r: Int?, cols c: Int?) {
        rows = r
        cols = c
    }
    
    static public func EQ(lhs: gridOptionsSet, rhs: gridOptionsSet) -> Bool
    {
        return lhs.rows == rhs.rows && lhs.cols == rhs.cols
    }
}

// MARK: Options view controller
class Options: UIViewController, UITextFieldDelegate, GridSettingsAPI {
    
    // Control linkages
    @IBOutlet weak var numRows: UITextField!
    @IBOutlet weak var numRowsSlider: UISlider!
    @IBOutlet weak var numCols: UITextField!
    @IBOutlet weak var numColsSlider: UISlider!
    
    // GridSettingsAPI
    var gridSettings : gridOptionsSet = gridOptionsSet(rows: 3, cols: 3)
    var FinalScoreFunc: ((Any) -> ())?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        numRows.delegate = self
        numCols.delegate = self
        
        numRows.text = String(gridSettings.rows!)
        numCols.text = String(gridSettings.cols!)
        numRowsSlider.value = Float(numRows.text ?? "") ?? numRowsSlider.minimumValue
        numColsSlider.value = Float(numCols.text ?? "") ?? numColsSlider.minimumValue
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // This will be called before "save" action segues back to caller
    // So, this is the place to pass changed settings back
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        FinalScoreFunc?(gridSettings)
//    }
    
    @IBAction func CancelPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SavePressed(_ sender: UIBarButtonItem) {
        FinalScoreFunc?(gridSettings)
        dismiss(animated: true, completion: nil)
    }
    
    // Set of functions to synch text and sliders
    @IBAction func rowsEdited(_ sender: Any) {
        numRowsSlider.value = Float(numRows.text ?? "") ?? numRowsSlider.minimumValue
        gridSettings.rows = Int(numRowsSlider.value)
    }
    
    @IBAction func rowsSliderChanged(_ sender: Any) {
        numRows.text = String(Int(numRowsSlider.value))
        gridSettings.rows = Int(numRowsSlider.value)
    }
    
    @IBAction func colsEdited(_ sender: Any) {
        numColsSlider.value = Float(numCols.text ?? "") ?? numColsSlider.minimumValue
        gridSettings.cols = Int(numColsSlider.value)
    }
    
    @IBAction func colsSliderChanged(_ sender: Any) {
        numCols.text = String(Int(numColsSlider.value))
        gridSettings.cols = Int(numColsSlider.value)
    }
    
    //MARK: Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
