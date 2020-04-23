//
//  ASNetManager.swift
//  ZeroShare
//
//  Created by saeipi on 2019/5/30.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit
import Alamofire

class ASNetManager: NSObject {
    public static func request(url: URLConvertible,
                method:  HTTPMethod = .get,
                       parameters: [String: Any]?,
                       success: @escaping ((_ result: Any?)->Void),failure: @escaping ((_ error: ASRequestError?)->Void)) {
        AF.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil, interceptor: nil).responseJSON { (response) in
            switch response.result {
            case .success:
                success(response.value);
            case .failure(let error):
                print("request error")
                let errorInfo   = ASRequestError.init()
                errorInfo.error = error
                failure(errorInfo)
            }
        }
    }
}

class ASRequestError: NSObject {
    var error: Error?
    var domain: String?
}
