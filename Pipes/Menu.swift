//
//  Menu.swift
//  Pipes
//
//  Created by David Poirier on 21/12/2016.
//  Copyright © 2016 David Poirier. All rights reserved.
//

import UIKit

protocol ValueReturner {
    var returnValueToCaller: ((Any) -> ())?  { get set }
}

class Menu: UIViewController {

    @IBOutlet weak var Score: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func unwindToMenu(sender: UIStoryboardSegue) {
        
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var secondViewController = segue.destination as? ValueReturner {
            secondViewController.returnValueToCaller = GameReturnValue
        }
    }
    
    func GameReturnValue(returnedValue: Any) {
        // cast returnedValue to the returned value type and do what you want. For example:
        if let RetScore = returnedValue as? Int {
            Score.text = "Score: " + String(RetScore)
        }
    }
}
