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

class ObjDownloader {
    
    class func download() {
        let fileManager = FileManager.default
        let localModelName = "model.obj"
        let serverModelURL = URL(string: "https://testrestapi.mport.com/api/avatar/AvatarObjWithCookie/4046329")!
        
//        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
//            let file = "file1.txt"
//            let fileURL = dir.appendingPathComponent(file)
//                
//            }
//        
        
        let localModelURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(localModelName)

        
        let session = URLSession(configuration: .default)
        
        /*
         <NSHTTPCookie
         version:0
         name:mportpassport
         value:memberid=rR5Ft%2fbRzy0%3d&expiry=QExKy6XInMU%2fy3rV0ZK8Ww%3d%3d
         expiresDate:'2019-04-02 03:49:53 +0000'
         created:'2019-04-02 02:49:57 +0000'
         sessionOnly:FALSE
         domain:testrestapi.mport.com
         partition:none
         sameSite:none
         path:/
         isSecure:FALSE
         path:"/" isSecure:FALSE>
         */
        
        let cookieProperties:[HTTPCookiePropertyKey: Any] = [
            HTTPCookiePropertyKey.name : "mportpassport",
            HTTPCookiePropertyKey.value :      "mportpassport=memberid=BfDs2G%2fst8s%3d&expiry=QExKy6XInMVUdggjdwXIgg%3d%3d; path=/; domain=.testrestapi.mport.com; Expires=Tue, 02 Apr 2019 03:56:07 GMT",
            
            HTTPCookiePropertyKey.expires: "'2019-04-02 03:49:53 +0000'",
            HTTPCookiePropertyKey.expires:  "testrestapi.mport.com"
        ]
        

        
        let cookie = HTTPCookie(properties: cookieProperties)
        session.configuration.httpCookieStorage?.setCookie(cookie!)
        
        let task = session.downloadTask(with: serverModelURL) { tempLocation, response, error in
            guard let tempLocation = tempLocation else {
                // handle error
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
            }
            
            let asset = MDLAsset(url: localModelURL)
            guard let object = asset.object(at: 0) as? MDLMesh else {
                fatalError("Failed to get mesh from asset.")
            }
        }
        
        task.resume() // don't forget to call resume to start downloading
    }

}


