//
//  WSLogger.swift
//  ws
//
//  Created by Sacha Durand Saint Omer on 13/11/2016.
//  Copyright © 2016 s4cha. All rights reserved.
//

import Alamofire
import Foundation

public enum WSLogLevel {
    
    @available(*, unavailable, renamed: "off")
    case none
    @available(*, unavailable, renamed: "info")
    case calls
    @available(*, unavailable, renamed: "debug")
    case callsAndResponses
    
    case off
    case info
    case debug
}

class WSLogger {
    
    var logLevels = WSLogLevel.off
    
    func logMultipartRequest(_ request: WSRequest) {
        guard logLevels != .off else {
            return
        }
        print("\(request.httpVerb.rawValue.uppercased()) '\(request.URL)'")
        let paramsText = prettyPrintedObjectString(from: request.params) ?? "\(request.params)"
        print("  params : \(paramsText)")
        
        for (k, v) in request.headers {
            print("  \(k) : \(v)")
        }
        request.multiPartData.forEach { 
            print("  name : \($0.multipartName),"
                + "mimeType: \($0.multipartMimeType), filename: \($0.multipartFileName)")
        }
        
        if logLevels == .debug {
            print()
        }
    }
    
    func logRequest(_ request: DataRequest) {
        guard logLevels != .off else {
            return
        }
        if let urlRequest = request.request,
            let verb = urlRequest.httpMethod,
            let url = urlRequest.url {
            print("\(verb) '\(url.absoluteString)'")
            logHeaders(urlRequest)
            logBody(urlRequest)
            if logLevels == .debug {
                print()
            }
        }
    }
    
    func logResponse(_ response: DefaultDataResponse) {
        guard logLevels != .off else {
            return
        }
        logStatusCodeAndURL(response.response)
        if logLevels == .debug {
            print()
        }
    }
    
    func logResponse(_ response: DataResponse<Any>) {
        guard logLevels != .off else {
            return
        }
        logStatusCodeAndURL(response.response)
        if logLevels == .debug {
            switch response.result {
            case .success(let value):
                if let data = response.data,
                   let utf8Text = prettyPrintedJSONString(from: data) {
                    print(utf8Text)
                } else {
                    print(value)
                }
            case .failure(let error):
                print(error)
            }
        }
        if logLevels == .debug {
            print()
        }
    }
    
    private func logHeaders(_ urlRequest: URLRequest) {
        if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
            for (k, v) in allHTTPHeaderFields {
                print("  \(k) : \(v)")
            }
        }
    }
    
    private func logBody(_ urlRequest: URLRequest) {
        if let body = urlRequest.httpBody,
            let str = String(data: body, encoding: .utf8) {
            print("  HttpBody : \(str)")
        }
    }
    
    private func logStatusCodeAndURL(_ urlResponse: HTTPURLResponse?) {
        if let urlResponse = urlResponse, let url = urlResponse.url {
            print("\(urlResponse.statusCode) '\(url.absoluteString)'")
        }
    }

    private func prettyPrintedJSONString(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
              JSONSerialization.isValidJSONObject(object),
              let normalizedData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) else {
            return String(data: data, encoding: .utf8)
        }

        return String(data: normalizedData, encoding: .utf8)
    }

    private func prettyPrintedObjectString(from object: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let text = String(data: data, encoding: .utf8) else {
            return nil
        }

        return text
    }
}
