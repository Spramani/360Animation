//
//  GameViewController.swift
//  Simple3DGame
//
//  Created by Mayank Mangukiya on 02/05/23.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController,SCNSceneRendererDelegate {

    var scores:Int = 0
    
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var gameView: SCNView!
        //var gameView:SCNView!
    var gameScane:SCNScene!
    var camaraNode:SCNNode!
    var targetCreationTime:TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
    }
    
    func initView(){
     //   gameView = self.view as! SCNView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
        gameView.delegate = self
    }
    
    func initCamera(){
        camaraNode = SCNNode()
        camaraNode.camera = SCNCamera()
        camaraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        
        gameScane.rootNode.addChildNode(camaraNode)
    }
    
    func initScene(){
        gameScane = SCNScene()
        gameView.scene = gameScane
        gameView.isPlaying = true
    }
    
    func cleanup(){
        for node in gameScane.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    func crateTarget(){
        let geometery:SCNGeometry = SCNPyramid(width: 1, height: 1, length: 1)
        let randomColor = arc4random_uniform(2) == 0 ? UIColor.green : UIColor.red
        
        geometery.materials.first?.diffuse.contents = randomColor
        
        let geometeryNode = SCNNode(geometry: geometery)
        geometeryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        if randomColor == UIColor.red {
            geometeryNode.name = "enemy"
        }else{
            geometeryNode.name = "friend"
        }
        gameScane.rootNode.addChildNode(geometeryNode)
        
        let randomDirection:Float = arc4random_uniform(2) == 0 ? -1.0 : 1.0
        
        
        let force = SCNVector3(x: randomDirection, y: 15, z: 0)
        geometeryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z: 0.05), asImpulse: true)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            crateTarget()
            targetCreationTime = time + 0.6
        }
        cleanup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location,options: nil)
        if let hitobject = hitList.first {
            let node = hitobject.node
            if node.name == "friend" {
                scores = scores + 1
                self.score.text = "Score: \(scores)"
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.green
            }else{
                scores = 0
                self.score.text = "Score:= \(scores)"
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
            }
        }
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
