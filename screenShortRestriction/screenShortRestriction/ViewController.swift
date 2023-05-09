//
//  ViewController.swift
//  screenShortRestriction
//
//  Created by Mayank Mangukiya on 14/04/23.
//

import UIKit
import ShyView
import WebKit

class ViewController: UIViewController, WKUIDelegate {
    var balanceLabel = UIView()
    @IBOutlet weak var stackview: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        let myWebView:WKWebView = WKWebView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
               myWebView.uiDelegate = self
               self.balanceLabel.addSubview(myWebView)
               
               //1. Load web site into my web view
               let myURL = URL(string: "https://www.ngmtech.in/")
               let myURLRequest:URLRequest = URLRequest(url: myURL!)
               myWebView.load(myURLRequest)
        stackview.addArrangedSubview(ShyView(balanceLabel) ?? balanceLabel)
      

     
        
    }


}

