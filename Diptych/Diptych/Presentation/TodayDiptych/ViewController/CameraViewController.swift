//
//  CameraViewController.swift
//  Diptych
//
//  Created by 윤범태 on 2023/07/13.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var lblTopic: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnActShutter(_ sender: UIButton) {
        lblTopic.text = #function
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
