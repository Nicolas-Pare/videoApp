//
//  permissionViewController.swift
//  VideoApp
//
//  Created by Nicolas Paré on 18-08-11.
//  Copyright © 2018 Nicolas Paré. All rights reserved.
//

import UIKit

class permissionViewController: UIViewController {
    
    @IBOutlet weak var visibleView: UIView!
    @IBOutlet weak var visibleText: UITextView!
    @IBOutlet weak var visibleBtn: UIButton!
    @IBOutlet weak var visibleLogo: UIImageView!
    
    @IBAction func startBtn(_ sender: Any) {
        visibleView.isHidden = true
        visibleText.isHidden = true
        visibleBtn.isHidden = true
        visibleLogo.isHidden = true
    }
    
    @IBAction func continuBtn(_ sender: Any) {
        self.performSegue(withIdentifier:"permissionToVideo", sender: self)
    }
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

}
