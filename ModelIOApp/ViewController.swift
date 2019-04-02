
//  Created by Devi Prasad Ghimire on 2/4/19.
//  Copyright © 2019 iOS Developer Zone. All rights reserved.
//

import UIKit
import ModelIO
import SceneKit
import SceneKit.ModelIO

extension MDLMaterial {
    func setTextureProperties(_ textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}


class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadObjScene()
        
        loadObjFromServer()
    }
   
    
    func loadObjFromServer() {
        ObjDownloader.download(forNode: SCNNode())
        
        //ObjDownloader.downloadWithSession(forNode: SCNNode())
    }
    
    func loadObjScene() {
        // Load the .OBJ file
        
        //let fighter = "Fighter"
        //let body = "BodyMesh"
        let avatar = "Avatar"
        
        //loading form localie file system
        guard let url = Bundle.main.url(forResource: avatar, withExtension: "obj") else {
            fatalError("Failed to find model file.")
        }
        
        //converting to ModelIo Asset
        let asset = MDLAsset(url:url)
        guard let object = asset.object(at: 0) as? MDLMesh else {
            fatalError("Failed to get mesh from asset.")
        }
        
        /*
        //Assigning material propperties to mesh
        // Create a material from the various textures
         //option 1
         
         let scatteringFunction = MDLScatteringFunction()
         let material = MDLMaterial(name: "baseMaterial", scatteringFunction: scatteringFunction)
         
         let diffColor =   #colorLiteral(red: 0.8894657493, green: 0.7006013989, blue: 0.130964309, alpha: 1).cgColor
         let diffuse = MDLMaterialProperty(name: "diffuse", semantic: .baseColor, color: diffColor)
         material.setProperty(diffuse)
         
         let metalic = MDLMaterialProperty(name: "Lighting", semantic: .metallic)
         metalic.floatValue = 1
         material.setProperty(metalic)
         
         //material.setProperty(diffuse)
         
         //let emmission = MDLMaterialProperty(name: "emmi", semantic: .emission, color: UIColor.gray.cgColor)
         //   material.setProperty(emmission)
         
        //let property = MDLMaterialProperty(name: "spec", semantic: .specular, color: UIColor.gray.cgColor)
        
         /* option 2
         //can property be seted with image imageblock for better performance
         //this is actual way of passing graphic on game rendering
        
        material.setProperty(property)
                material.setTextureProperties([
                    .baseColor:"Fighter_Diffuse_25.jpg",
                    .specular:"Fighter_Specular_25.jpg",
                    .emission:"Fighter_Illumination_25.jpg"])
        */
        
        //Apply the texture to every submesh of the asset
        //for option 1 or option 2
        
         for  submesh in object.submeshes!  {
            if let submesh = submesh as? MDLSubmesh {
                submesh.material = material
            }
        }
         */
        
        //Wrap the ModelIO object in a SceneKit object
        let node = SCNNode(mdlObject: object)
        
        
        //accessing directly Material of node
        //node.geometry?.firstMaterial?.normal.contents = UIColor.gray
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        
        //animate the 3d object
        node.runAction(
            SCNAction.repeatForever(
                SCNAction.rotateBy(
                    x: 0, y: 2, z: 0, duration: 3
                )
            )
        )
        
        //accessing materil directly
        if let material = scene.rootNode.childNodes.first?.geometry?.materials.first {
            
            material.shininess = 1
            if #available(iOS 10.0, *) {
                material.lightingModel = .physicallyBased
                //material.metalness = 1
            } else {
                // Fallback on earlier versions
            }
            material.diffuse.contents =  #colorLiteral(red: 0.8894657493, green: 0.7006013989, blue: 0.130964309, alpha: 1).cgColor
            
            if #available(iOS 10.0, *) {
                //scene.rootNode.childNodes.first!.geometry!.materials.first!.metalness.contents = 1
                //scene.rootNode.childNodes.first!.geometry!.materials.first!.roughness.contents = 0
            } else {
                // Fallback on earlier versions
            }
        }
        
        //Set up the SceneView
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.white
        
        
        //managing light for scene
        //FYI: light can be passed to the object directly
        
        ambientLightLineOn(scene: sceneView.scene!)
        //omniLightOn(scene: sceneView.scene!)
    }
    
}

func ambientLightLineOn(scene: SCNScene) {
    let ambientLightNode = SCNNode()
    ambientLightNode.light = SCNLight()
    ambientLightNode.light!.type = SCNLight.LightType.ambient
    if #available(iOS 10.0, *) {
        ambientLightNode.light!.intensity = 1
    } else {
        // Fallback on earlier versions
    }
    ambientLightNode.light!.color =  #colorLiteral(red: 0.8894657493, green: 0.7006013989, blue: 0.130964309, alpha: 1)
    scene.rootNode.addChildNode(ambientLightNode)
}

func omniLightOn(scene: SCNScene) {
    let omniLightNode = SCNNode()
    omniLightNode.light = SCNLight()
    omniLightNode.light!.type = SCNLight.LightType.omni
    omniLightNode.light!.color = #colorLiteral(red: 0.8894657493, green: 0.7006013989, blue: 0.130964309, alpha: 1)
    omniLightNode.position = SCNVector3Make(0, 50, 50)
    scene.rootNode.addChildNode(omniLightNode)
}
