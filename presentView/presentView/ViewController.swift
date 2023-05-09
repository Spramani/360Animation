//
//  ViewController.swift
//  presentView
//
//  Created by Mayank Mangukiya on 19/10/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        present()
    }

    @IBAction func clicks(_ sender: Any) {

    }
    
    func present(){
        let vc = secViewController()
        let navVC = UINavigationController(rootViewController: vc)
        navVC.isModalInPresentation = true
        if let sheet = navVC.sheetPresentationController {
            sheet.preferredCornerRadius = 20
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(resolver: { context in
                    0.10 * context.maximumDetentValue
                }),.medium(), .large()]
            } else {
                // Fallback on earlier versions
            }
            sheet.largestUndimmedDetentIdentifier = .large
        }
        
        navigationController?.present(navVC, animated: true)
    }
    
}

