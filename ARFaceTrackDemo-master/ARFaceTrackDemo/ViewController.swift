//
//  ViewController.swift
//  ARFaceTrackDemo
//
//  Created by Mohammed Azeem Azeez on 4/23/20.
//  Copyright © 2020 Blue Mango Global. All rights reserved.
//

import UIKit
import ARKit

private let planeWidth: CGFloat = 0.13
private let planeHeight: CGFloat = 0.06
private let nodeYPosition: Float = 0.022
private let minPositionDistance: Float = 0.0025
private let minscaling:CGFloat = 0.025
private let cellIdentifier = "GlassesCollecitonViewCell"
private let glassesCount = 4
private let animationDuration: TimeInterval = 0.25
private let cornerRadius: CGFloat = 10

class ViewController: UIViewController {
    
   
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var glassesView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calibrationView: UIView!
    @IBOutlet weak var calibrationTransparentView: UIView!
    @IBOutlet weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var calibrationBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionButton: UIButton!
    @IBOutlet weak var calibrationButton: UIButton!
    @IBOutlet weak var alertLabel: UILabel!
    
    private let glassesPlane = SCNPlane(width: planeWidth, height: planeHeight)
    private let glassesNode = SCNNode()
    
    private var scalling:CGFloat = 1
    private var isColllectionOpened = false {
        didSet{
            updateCollectionPosition()
        }
    }
    
    private var isCalibrationOpended = false {
        didSet{
            updateCalibrationPosition()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else {
        alertLabel.text = "Face tracking is not supported on this device"
        return
        }
        sceneView.delegate = self
        
        setupCollectionView()
        setupCalibrationView()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         let configuration = ARFaceTrackingConfiguration()
         sceneView.session.run(configuration)
     }
     
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         sceneView.session.pause()
     }
    
    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionBottomConstraint.constant = -glassesView.bounds.size.height
    }
    
    private func setupCalibrationView(){
        calibrationTransparentView.layer.cornerRadius = cornerRadius
        calibrationBottomConstraint.constant = -calibrationView.bounds.size.height
        
    }
  
    private func updateGlassess(with index: Int){
        let imageName = "glasses\(index)"
        glassesPlane.firstMaterial?.diffuse.contents = UIImage(named: imageName)
    }
  
    private func updateCollectionPosition(){
        collectionBottomConstraint.constant = isColllectionOpened ? 0 : -glassesView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.calibrationButton.alpha = self.isColllectionOpened ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCalibrationPosition(){
        calibrationBottomConstraint.constant = isCalibrationOpended ? 0 : -calibrationView.bounds.size.height
        UIView.animate(withDuration: animationDuration) {
            self.collectionButton.alpha = self.isCalibrationOpended ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    private func updateSize(){
        glassesPlane.width = scalling * planeWidth
        glassesPlane.height = scalling * planeWidth
    }
    
    @IBAction func collecitonButtonTapped(_ sender: Any) {
        isColllectionOpened = !isColllectionOpened
    }
    
    @IBAction func calibrationTapped(_ sender: Any) {
        isCalibrationOpended = !isCalibrationOpended
    }
    
    @IBAction func sceneARTapped(_ sender: Any) {
        isColllectionOpened = false
        isCalibrationOpended = false
    }
    
    @IBAction func tapTapped(_ sender: Any) {
        glassesNode.position.y += minPositionDistance
    }
    
    @IBAction func downTapped(_ sender: Any) {
        glassesNode.position.x -= minPositionDistance
    }
    
    @IBAction func rightTapped(_ sender: Any) {
        glassesNode.position.x += minPositionDistance
    }
    
    @IBAction func leftTapped(_ sender: Any) {
        glassesNode.position.x -= minPositionDistance
    }
    
    @IBAction func farTapped(_ sender: Any) {
        glassesNode.position.z += minPositionDistance
    }
    
    @IBAction func closerTapped(_ sender: Any) {
        glassesNode.position.z -= minPositionDistance
    }
    
    @IBAction func biggerTapped(_ sender: Any) {
        scalling += minscaling
        updateSize()
    }
    
    @IBAction func smallerTapped(_ sender: Any) {
            scalling -= minscaling
        updateSize()
    }
    
    
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.transparency = 0
        glassesPlane.firstMaterial?.isDoubleSided = true
        updateGlassess(with: 0)
        
        glassesNode.position.z = faceNode.boundingBox.max.z * 3 / 4
        glassesNode.position.y = nodeYPosition
        glassesNode.geometry = glassesPlane
        
        faceNode.addChildNode(glassesNode)
       
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else {
            return
        }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }
}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return glassesCount
    }
    
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GlassesCollecitonViewCell
        let imageName = "glasses\(indexPath.row)"
        cell.setup(with: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        updateGlassess(with: indexPath.row)
        }
    
}
