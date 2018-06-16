//
//  ViewController.swift
//  RecordARKit
//
//  Created by Akshay Bharath on 6/16/18.
//  Copyright © 2018 Akshay Bharath. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import ARVideoKit

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    var recorder: RecordAR?
    
    var pinchingNode: SKNode?
    
    var randomEmoji: String {
        let emojis = ["🤓", "🔥", "😜", "😇", "🤣", "🤗", "🧐", "🐰", "🚀", "👻"]
        return emojis[Int(arc4random_uniform(UInt32(emojis.count)))]
    }
    
    var recorderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Record", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 110, height: 60)
        button.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height*0.90)
        button.layer.cornerRadius = button.bounds.height/2
        button.tag = 0
        return button
    }()
    
    var pauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Pause", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.center = CGPoint(x: UIScreen.main.bounds.width*0.15, y: UIScreen.main.bounds.height*0.90)
        button.layer.cornerRadius = button.bounds.height/2
        button.alpha = 0.3
        button.isEnabled = false
        return button
    }()
    
    var gifButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GIF", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.center = CGPoint(x: UIScreen.main.bounds.width*0.85, y: UIScreen.main.bounds.height*0.90)
        button.layer.cornerRadius = button.bounds.height/2
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        // Add buttons
        view.addSubview(recorderButton)
        view.addSubview(pauseButton)
        view.addSubview(gifButton)
        
        // Connect button actions
        recorderButton.addTarget(self, action: #selector(recorderAction(sender:)), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseAction(sender:)), for: .touchUpInside)
        gifButton.addTarget(self, action: #selector(gifAction(sender:)), for: .touchUpInside)
        
        // Initialize with SpriteKit
        recorder = RecordAR(ARSpriteKit: sceneView)
        
        // Specificy supported orientations
        recorder?.inputViewOrientations = [.portrait, .landscapeLeft, .landscapeRight]
        
        // Add pinch gesture
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(sender:)))
        sceneView.addGestureRecognizer(pinchGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        // Prep recorder
        recorder?.prepare()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        
        // End recorder session
        recorder?.rest()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: randomEmoji)
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // Record and stop method
    @objc func recorderAction(sender: UIButton) {
        if recorder?.status == .readyToRecord {
            recorder?.record()
            sender.setTitle("Stop", for: .normal)
            sender.setTitleColor(.red, for: .normal)
            pauseButton.alpha = 1.0
            pauseButton.isEnabled = true
            gifButton.alpha = 0.3
            gifButton.isEnabled = false
        } else if recorder?.status == .recording || recorder?.status == .paused {
            recorder?.stopAndExport()
            sender.setTitle("Record", for: .normal)
            sender.setTitleColor(.black, for: .normal)
            pauseButton.alpha = 0.3
            pauseButton.isEnabled = false
            gifButton.alpha = 1.0
            gifButton.isEnabled = true
        }
    }
    
    // Pause and resume method
    @objc func pauseAction(sender: UIButton) {
        if recorder?.status == .recording {
            recorder?.pause()
            sender.setTitle("Resume", for: .normal)
            sender.setTitleColor(.blue, for: .normal)
        } else if recorder?.status == .paused {
            recorder?.record()
            sender.setTitle("Pause", for: .normal)
            sender.setTitleColor(.black, for: .normal)
        }
    }
    
    // Capture GIF method
    @objc func gifAction(sender: UIButton) {
        sender.isEnabled = false
        sender.alpha = 0.3
        recorderButton.isEnabled = false
        recorderButton.alpha = 0.3
        
        recorder?.gif(forDuration: 1.5, export: true) { _, _, _ , exported in
            if exported {
                DispatchQueue.main.sync {
                    self.gifButton.isEnabled = true
                    self.gifButton.alpha = 1.0
                    self.recorderButton.isEnabled = true
                    self.recorderButton.alpha = 1.0
                }
            }
        }
    }
    
    @objc func pinchAction(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: sceneView)
            if let node = sceneView.scene?.nodes(at: point).first {
                pinchingNode = node
            }
        } else if sender.state == .changed, let node = pinchingNode {
            node.setScale(sender.scale)
        } else if sender.state == .cancelled || sender.state == .ended {
            pinchingNode = nil
        }
    }
}
