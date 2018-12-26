//
//  Constants.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class Constants: NSObject {

    static let ID_UNDEFINED = -1
    
    static let ACTIVITY_ADVANCE_TASKS = "com.efbware.activity.advanceTaks"
    static let ACTIVITY_ADVANCE_TASKS_PERIOD = 60.0
    
    static let HEADER_SESSION_ID = "app-session-id"
    
    static let DIR_APPLICATION = "efbware"
    static let DIR_DATABASE = "database"
    static let DIR_DOCUMENTS = "documents"
    static let DIR_TECHLOGS = "techlogs"
    
    static let FILE_SID = "sid"
    static let FILE_DATABASE = "efbware.sqlite"
    
    static let URL_API = "http://my.doka.live/adserver"
    
    static let URL_ITEM_SEARCH  = URL_API + "/item/search"
    static let URL_INFO         = URL_API + "/session/info"
    static let URL_LOGIN        = URL_API + "/session/login"
    static let URL_LOGOUT       = URL_API + "/session/logout"
    
    static let SEGUE_APP_TO_LOGIN = "appToLogin"
}
