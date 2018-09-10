//
//  postVideoViewController.swift
//  VideoApp
//
//  Created by Nicolas Paré on 18-09-05.
//  Copyright © 2018 Nicolas Paré. All rights reserved.
//

import UIKit

class postVideoViewController: UIViewController {
    var timer = Timer()
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(delayedAction), userInfo: nil, repeats: false)
        
        // Do any additional setup after loading the view.
    }
    @objc func delayedAction() {
        self.performSegue(withIdentifier:"thanksToAccepte", sender: self)
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
