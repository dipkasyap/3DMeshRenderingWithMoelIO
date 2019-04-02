//
//  ObjDownloader.swift
//  ModelIOApp
//
//  Created by Devi Prasad Ghimire on 2/4/19.
//  Copyright © 2019 iOS Developer Zone. All rights reserved.
//

import UIKit
import ModelIO
import SceneKit
import SceneKit.ModelIO
import Alamofire


let thirdPartyURl = "https://cloud.box.com/shared/static/ock9d81kakj91dz1x4ea.obj"
let ourURL = "https://testrestapi.mport.com/api/avatar/AvatarObjWithCookie/4046329"
let cookieString = "memberid=BfDs2G%2fst8s%3d&expiry=QExKy6XInMUgGItrSfrQfg%3d%3d"

class ObjDownloader {
    
    class func getCookie()-> HTTPCookie? {
        
        let ExpTime = TimeInterval(60 * 60 * 24 * 365)
        
        let cookieProps: [HTTPCookiePropertyKey : Any] = [
            
            HTTPCookiePropertyKey.domain: "testrestapi.mport.com",
            HTTPCookiePropertyKey.path: "/",
            HTTPCookiePropertyKey.name: "mportpassport",
            HTTPCookiePropertyKey.value: cookieString,
            // HTTPCookiePropertyKey.secure: "TRUE",
            HTTPCookiePropertyKey.expires: NSDate(timeIntervalSinceNow: ExpTime),
            //  HTTPCookiePropertyKey.version: "0"
        ]
        
        return HTTPCookie(properties: cookieProps)
    }
    
    //With Alamofire
    class func download(forNode node: SCNNode) {
        
    let serverModelURL =  ourURL //thirdPartyURl
        
        func startDownload(audioUrl:String) -> Void {
            let fileUrl = getSaveFileUrl(fileName: "onFirebase" + ".obj")
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
            }
            
            if let cookie = getCookie() {
                Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookie(cookie)
            }
            
            Alamofire.download(audioUrl, to:destination)
                .downloadProgress { (progress) in
                   let progress = (String)(progress.fractionCompleted)
                    
                    print(progress)
                    
                }
                .responseData { (data) in
                   print("data\n",data)
                    
                    if data.response?.statusCode == 401 {
                        print("Cookie has expired.....")
                        return
                    }
                    
                    if let _ = data.value {
                        let asset = MDLAsset(url: fileUrl)
                        
                        print(fileUrl)
                        
                        guard let object = asset.object(at: 0) as? MDLMesh else {
                            print("\n\nEmpty File")
                            return
                        }
                    }
                    print(data.response?.statusCode ?? "code not found ")

            }
        }
        
        func getSaveFileUrl(fileName: String) -> URL {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let nameUrl = URL(string: fileName)
            let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
            NSLog(fileURL.absoluteString)
            return fileURL;
        }
        
        
        startDownload(audioUrl: serverModelURL)
        
    }
    
    class func downloadWithSession(forNode node: SCNNode) {
        let fileManager = FileManager.default
        let localModelName = "onSeeeion.obj"
        let serverModelURL = URL(string: ourURL)!
        
        let localModelURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(localModelName)
        let session = URLSession(configuration: .default)
        
        if let cookie = getCookie() {
            //session.configuration.httpCookieStorage?.setCookie(cookie)
        }
   
        let task = session.downloadTask(with: serverModelURL) { tempLocation, response, error in
            guard let tempLocation = tempLocation else {
                // tempLocation
                print("Url is not valid .....")
                return
            }
            
            guard  error == nil else {
                print(error?.localizedDescription ?? "Server throwing error")
                return
            }
            
            do {
                // FileManager's copyItem throws an error if the file exist
                // so we check and remove previously downloaded file
                // That's just for testing purposes, you probably wouldn't want to download
                // the same model multiple times instead of just persisting it
                
                if fileManager.fileExists(atPath: localModelURL.path) {
                    try fileManager.removeItem(at: localModelURL)
                }
                
                try fileManager.copyItem(at: tempLocation, to: localModelURL)
                
            } catch {
                // handle error
                print("Cannot get file form server" )
            }
            
            let asset = MDLAsset(url: localModelURL)
            guard let object = asset.object(at: 0) as? MDLMesh else {
                print("\n\nEmpty File")
                return
            }
        }
        
        task.resume() // don't forget to call resume to start downloading
    }

}


