//
//  ViewController.swift
//  ImageAnimations
//
//  Created by Mayank Mangukiya on 17/03/23.
//

import UIKit
import AVFoundation
import Photos
import AVKit
var tempurl = ""
class ViewController: UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    private var screenRecorder = Recorder()
    @IBOutlet weak var speedProgressBar: UISlider!
    @IBOutlet weak var myView: UIView!
    
    @IBAction func startRecordAction(_ sender: UIButton) {
         self.screenRecorder.start()
     }

    @IBAction func StopRecordAction(_ sender: UIButton) {
         self.screenRecorder.stop { (strUrl) in
            print("Final Video Document Direcotry URL : " + strUrl)
        }
    }
    
    @IBAction func tappedSaveButton(_ sender: Any) {
        ImageSaveManager().saveImageToAlbum(UIImage(view: backView), name: "Shubh")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Do any additional setup after loading the view.
        backView.rotate360Degrees()
//        myView.shake(count: 100, for: 1, withTanslation: 6)
        myView.zoomInWithEasing()
        self.screenRecorder.view = self.backView
        
    }

    @IBAction func tappedColorButton(_ sender: UIButton) {
        // Initializing Color Picker
        let picker = UIColorPickerViewController()

        // Setting the Initial Color of the Picker
        picker.selectedColor = self.view.backgroundColor!

        // Setting Delegate
        picker.delegate = self

        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }
    
   
    @IBAction func tappedSlider(_ sender: UISlider) {
        var currentValue = Int(sender.value)
        myView.rotate360Degrees(durations: currentValue)
        myView.zoomInWithEasing(duration: 0 , easingOffset: CGFloat(sender.value/2))
    }
}

extension UIView {
    func rotate360Degrees(durations:Int = 5) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = CFTimeInterval(durations)
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    
}

extension ViewController: UIColorPickerViewControllerDelegate {
    
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        self.view.backgroundColor = viewController.selectedColor
        
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
            self.myView.backgroundColor = viewController.selectedColor
        self.dismiss(animated: true)
    }
}


//shake animation: http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
public extension UIView {

    func shake(count : Float? = nil,for duration : TimeInterval? = nil,withTanslation translation : Float? = nil) {
    let animation : CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

    animation.repeatCount = count ?? 2
    animation.duration = (duration ?? 0.5)/TimeInterval(animation.repeatCount)
    animation.autoreverses = true
    animation.byValue = translation ?? -5
    layer.add(animation, forKey: "shake")
    }
}

//rotate: https://www.andrewcbancroft.com/2014/10/15/rotate-animation-in-swift/
extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as! any CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

//zoom http://stackoverflow.com/questions/31320819/scale-uibutton-animation-swift
extension UIView {

    /**
     Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.
     - parameter duration: animation duration
     */
    func zoomIn(duration duration: TimeInterval = 0.2) {
        self.transform = CGAffineTransformMakeScale(0.0, 0.0)
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }) { (animationCompleted: Bool) -> Void in
        }
    }

    /**
     Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.
     - parameter duration: animation duration
     */
    func zoomOut(duration: TimeInterval = 2) {
        self.transform = CGAffineTransformIdentity
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(0.0, 0.0)
            }) { (animationCompleted: Bool) -> Void in
        }
    }

    /**
     Zoom in any view with specified offset magnification.
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomInWithEasing(duration duration: TimeInterval = 2, easingOffset: CGFloat = 2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(easeScale, easeScale)
            }, completion: { (completed: Bool) -> Void in
//                UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
//                    self.transform = CGAffineTransformIdentity
//                    }, completion: { (completed: Bool) -> Void in
//                })
        })
    }

    /**
     Zoom out any view with specified offset magnification.
     - parameter duration:     animation duration.
     - parameter easingOffset: easing offset.
     */
    func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(easeScale, easeScale)
            }, completion: { (completed: Bool) -> Void in
                UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(0.0, 0.0)
                    }, completion: { (completed: Bool) -> Void in
                })
        })
    }

}






