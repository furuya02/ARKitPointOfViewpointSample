//
//  ViewController.swift
//  ARKitPointOfViewpointSample
//
//  Created by SIN on 2017/10/20.
//  Copyright © 2017年 jp.ne.sapporoworks. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var recordingButton: RecordingButton!
    
    enum Mode {
        case none // 考慮なし
        case positoin // カメラの現在位置を考慮する
        case rotation // カメラの現在位置と角度を考慮する
        case eulerAngles // カメラの現在位置と角度と仰角を考慮する
    }
    var mode = Mode.none

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        // 録画ボタン
        self.recordingButton = RecordingButton(self)

        DispatchQueue.main.async {
            self.setMode()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func setMode()  {
        let actionSheet = UIAlertController(title: "mode", message: "select the mode to place the Cube.", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "position", style: .default) { _ in self.mode = .positoin })
        actionSheet.addAction(UIAlertAction(title: "rotation", style: .default) { _ in self.mode = .rotation })
        actionSheet.addAction(UIAlertAction(title: "eulerAngles", style: .default) { _ in self.mode = .eulerAngles })
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel) {_ in })
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    // 画面をタップすると、色々な色でキューブを表示する
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let node = SCNNode() // ノードを生成
        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial() // マテリアル（表面）を生成する
        material.diffuse.contents = randomColor()
        node.geometry?.materials = [material] // 表面の情報をノードに適用
        
        if mode == .none {
            node.position = SCNVector3(0, 0, -0.5) // ノードの位置は、左右：0m 上下：0m　奥に50cm
        } else {
            let position = SCNVector3(x: 0, y: 0, z: -0.5) // ノードの位置は、左右：0m 上下：0m　奥に50cm
            if let camera = sceneView.pointOfView {
                node.position = camera.convertPosition(position, to: nil) // カメラ位置からの偏差で求めた位置
                if mode == .rotation {
                    node.rotation = camera.rotation // カメラの角度と同じにする
                } else if mode == .eulerAngles {
                    node.rotation = camera.rotation // カメラの角度と同じにする
                    node.eulerAngles = camera.eulerAngles  // カメラの仰角と同じにする
                }
            }
        }
        sceneView.scene.rootNode.addChildNode(node) // 生成したノードをシーンに追加する
    }

    // ランダムな色の生成
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random() % 10) * 0.1
        let green = CGFloat(arc4random() % 10) * 0.1
        let blue = CGFloat(arc4random() % 10) * 0.1
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
        
    }
}
