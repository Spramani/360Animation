//
//  ViewController.swift
//  AiCup
//
//  Created by Mayank Mangukiya on 30/03/23.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the "Box" scene from the "Experience" Reality File
       // let boxAnchor = try! Experience.loadBox()
        
        // Add the box anchor to the scene
    //    arView.scene.anchors.append(boxAnchor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        arView.session.delegate = self
        setupCustomObject()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        arView.addGestureRecognizer(tapGesture)
    }
    @IBAction func onTap(recognizer:UITapGestureRecognizer){
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "cup_saucer_set.usdz", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        }else{
            print("Object placement failed")
        }
        
    }
    
    
    func setupCustomObject(){
        arView.automaticallyConfigureSession = false
        let configuaration = ARWorldTrackingConfiguration()
        configuaration.planeDetection = [.horizontal, .vertical]
        configuaration.environmentTexturing = .automatic
        arView.session.run(configuaration)
    }
    
    func placeObject(name entityName: String, for anchor: ARAnchor){
        let entity = try! ModelEntity.loadModel(named: entityName)
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}
extension ViewController :ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorObject = anchor.name, anchorObject == "cup_saucer_set.usdz" {
                placeObject(name: anchorObject, for: anchor)
            }
        }
    }
    
}
