//
//  Request.swift
//  Cesium
//
//  Created by Jonathan Foucher on 31/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

class Request {
    var url: URL
    
    init(url: String) {
        self.url = URL(string: url)!
    }
    
    func jsonDecodeWithCallback<T>(type: T.Type, callback: ((T) -> Void)?, fail: (() -> Void)?) where T : Decodable {
        let session = URLSession.shared
        let task = session.dataTask(with: self.url, completionHandler: { data, response, error in
            if let type = response?.mimeType {
                guard type == "application/json" else {
                    print("Not JSON " + String(self.url.absoluteString) + type)
                    fail?()
                    return
                }
            }
            guard let responseData = data else {
                print("no data")
                fail?()
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedResponse = try decoder.decode(type, from: responseData)
                //We have the response data, do callback
                callback?(decodedResponse)
            } catch {
                fail?()
                print("Error trying to convert data to JSON")
            }
        })
        
        task.resume()
    }
}
