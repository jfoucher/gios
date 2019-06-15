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

struct RequestError: Error {
    enum ErrorKind {
        case nodata
        case encodingFailed
        case decodingFailed
        case notJson
    }
    
    var requestData: Data? = nil
    var responseData: Data? = nil
    var kind: ErrorKind
}

class Request {
    var url: URL
    var task: URLSessionDataTask?
    
    init(url: String) {
        self.url = URL(string: url)!
    }
    
    
    func postRaw<T>(rawTx: String, type: T.Type, callback: ((Error?, T?) -> Void)?) where T : Decodable {
        let session = URLSession.shared
        var request = URLRequest(url: self.url)
        print("raw transaction", rawTx)
        let tRequest = TransactionRequest(transaction: rawTx)
        guard let jsonData = try? JSONEncoder().encode(tRequest) else {
            let er = RequestError(requestData: nil, responseData: nil, kind: .encodingFailed)
            callback?(er, nil)
            print("could not encode transaction")
            return
        }

        request.httpMethod = "POST"
        request.httpBody = Data(jsonData)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        self.task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                print("error")
                callback?(error, nil)
                return
            }
            
            guard let data = data else {
                callback?(RequestError(requestData: nil, responseData: nil, kind: .nodata), nil)
                print("no data")
                return
            }
            

            //create json object from data
            let decoder = JSONDecoder()
            do {
                let decodedResponse = try decoder.decode(type, from: data)
                //We have the response data, do callback
                callback?(nil, decodedResponse)
            } catch let err {
                
                callback?(RequestError(requestData: nil, responseData: data, kind: .decodingFailed), nil)
                print("Error trying to convert data to JSON", String(data: data, encoding: .utf8)!, err)
            }

        })
        self.task?.resume()
    }
    
    func jsonDecodeWithCallback<T>(type: T.Type, callback: ((Error?, T?) -> Void)?) where T : Decodable {
        let session = URLSession.shared
        session.configuration.requestCachePolicy = .returnCacheDataElseLoad
        print(self.url)
        self.task = session.dataTask(with: self.url, completionHandler: { data, response, error in
            if let type = response?.mimeType {
                guard type == "application/json" else {
                    //print("Not JSON " + String(self.url.absoluteString) + " " + type)
                    callback?(RequestError(requestData: nil, responseData: data, kind: .notJson), nil)
                    return
                }
            }
            guard let responseData = data else {
                //print("no data")
                callback?(RequestError(requestData: nil, responseData: data, kind: .nodata), nil)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let decodedResponse = try decoder.decode(type, from: responseData)
                //We have the response data, do callback
                callback?(nil, decodedResponse)
            } catch {
                callback?(RequestError(requestData: nil, responseData: responseData, kind: .decodingFailed), nil)
                //print( try! JSONSerialization.jsonObject(with: responseData, options: .mutableContainers))
                //print("Error trying to convert data to JSON")
            }
        })
        
        self.task?.resume()
    }
    func cancel() {
        self.task?.cancel()
    }
}
