//
//  KSSingleton.swift
//  ZeroShare
//
//  Created by saeipi on 2019/8/31.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSSingleton: NSObject {
    
    static let shared  = KSSingleton()
    
    lazy var indexConfigure: KSIndexConfigure = {
        let indexConfigure = KSIndexConfigure.init()
        return indexConfigure
    }()
    
    lazy var server: KSServer = {
        let server = KSServer.init(domain: "gw.1won.com")
        return server
    }()
    
    lazy var languageHelper: KSLanguageHelper = {
        let languageHelper = KSLanguageHelper.init()
        return languageHelper
    }()
    
    var isIphoneX: Bool {
        get {
            return true
        }
    }
}

class KSServer: NSObject {
    var domain: String       = ""
    var httpServer: String = ""
    var socketServer: String = ""
    
    convenience init(domain: String) {
        self.init()
        self.domain  = domain
        httpServer   = "https://" + domain
        socketServer = "wss://"+domain + "/websocket/v1/ws"
    }
}
