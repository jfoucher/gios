//
//  Request.swift
//  Cesium
//
//  Created by Jonathan Foucher on 31/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct TransactionRequest: Codable {
    var transaction: String
}

enum RequestError: Error {
    case nodata
    case encodingFailed
    case decodingFailed
}

class Request {
    var url: URL
    
    init(url: String) {
        self.url = URL(string: url)!
    }
    
    func postRaw<T>(data: String, type: T.Type, callback: ((Error?, T?) -> Void)?) where T : Decodable {
        let session = URLSession.shared
        var request = URLRequest(url: self.url)
        let tRequest = TransactionRequest(transaction: data)
        guard let jsonData = try? JSONEncoder().encode(tRequest) else {
            callback?(RequestError.encodingFailed, nil)
            print("could not encode transaction")
            return
        }
        print(jsonData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
        request.httpMethod = "POST"
        request.httpBody = Data(jsonData)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                print("error")
                callback?(error, nil)
                return
            }
            
            guard let data = data else {
                callback?(RequestError.nodata, nil)
                print("no data")
                return
            }
            

            //create json object from data
            let decoder = JSONDecoder()
            do {
                let decodedResponse = try decoder.decode(type, from: data)
                //We have the response data, do callback
                callback?(nil, decodedResponse)
            } catch {
                callback?(RequestError.decodingFailed, nil)
                print("Error trying to convert data to JSON")
            }

        })
        task.resume()
    }
    
    func jsonDecodeWithCallback<T>(type: T.Type, callback: ((T) -> Void)?, fail: (() -> Void)?) where T : Decodable {
        let session = URLSession.shared
        let task = session.dataTask(with: self.url, completionHandler: { data, response, error in
            if let type = response?.mimeType {
                guard type == "application/json" else {
                    print("Not JSON " + String(self.url.absoluteString) + " " + type)
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
