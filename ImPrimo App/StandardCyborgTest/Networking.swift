//
//  Networking.swift
//  StandardCyborgTest
//
//  Created by Ridvan Song on 2020-03-09.
//  Copyright © 2020 Ridvan Song. All rights reserved.
//

import Moya

enum PrintService {
    case sendPLY(named: String)
    case getUSDZ(named: Int)
    case printJob(named: Int)
}

extension PrintService: TargetType {
    
    var baseURL: URL { return URL(string: "http://192.168.0.15:8000/PrintProcess")! }
    
    
    var path: String {
        switch self {
        
        case .sendPLY:
            return "/sendPLY/"
        case .getUSDZ(let fileID):
            return "/\(fileID)/getUSDZ/"
        case .printJob(let fileID):
            return "/\(fileID)/printJob/"
        }
    }
    
    var method: Method {
        switch self {
        case .getUSDZ(_), .printJob(_):
            return .get
            
        //
        case .sendPLY(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .sendPLY(let data):
            return .requestParameters(parameters: ["PLYdata": data], encoding: JSONEncoding.default)
        case .getUSDZ(_):
            return .requestPlain
        case .printJob(_):
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

