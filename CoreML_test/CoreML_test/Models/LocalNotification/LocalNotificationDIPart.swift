//
//  LocalNotificationDIPart.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import Foundation
import DITranquillity

class LocalNotificationDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register { () -> LocalNotificationViewController in
            let storyboard = UIStoryboard(name: "LocalNotification", bundle: nil)
            return storyboard.instantiateInitialViewController() as! LocalNotificationViewController
            }
            .as(LocalNotificationView.self)
            .injection(cycle: true) { $0.presenter = $1 }
            .lifetime(.objectGraph)
        
        container.register(LocalNotificationPresenterImpl.init)
            .as(LocalNotificationPresenter.self)
                
        container.register(LocalNotificationRouterImpl.init)
            .as(LocalNotificationRouter.self)
    }
}
