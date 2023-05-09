//
//  ViewController.swift
//  screenRecording
//
//  Created by Mayank Mangukiya on 14/03/23.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var record: UIButton!
    
    @IBAction func tappedRecordButtom(_ sender: Any) {
        
        let recorder =  RPScreenRecorder.shared()
        if !recorder.isRecording {
            recorder.isCameraEnabled = true
            recorder.startRecording { error in
                guard error == nil else {
                    print("Failed to start recording")
                    return
                }
                self.record.setTitle("stop", for: .normal)
            }
        }else{
            recorder.stopRecording { previewcontroller, error in
                guard error == nil else{
                    print("error")
                    return
                }
                previewcontroller?.previewControllerDelegate = self
                self.navigationController?.present(previewcontroller!, animated: true)
                self.record.setTitle("start", for: .normal)
            }
        }
    }
}

extension ViewController:RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        navigationController?.dismiss(animated: true)
    }
}

