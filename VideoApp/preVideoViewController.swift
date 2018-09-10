//
//  preVideoViewController.swift
//  VideoApp
//
//  Created by Nicolas Paré on 18-09-05.
//  Copyright © 2018 Nicolas Paré. All rights reserved.
//

import UIKit

class preVideoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func startApp(_ sender: Any) {
        self.performSegue(withIdentifier:"commencerToVideo", sender: self)
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

}
