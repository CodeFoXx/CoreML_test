//
//  NotificationDIPart.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import Foundation
import DITranquillity

class NotificationDIPart: DIPart {
    static func load(container: DIContainer) {
        container.register { () -> NotificationViewController in
            let storyboard = UIStoryboard(name: "Notification", bundle: nil)
            return storyboard.instantiateInitialViewController() as! NotificationViewController
            }
            .as(NotificationView.self)
            .injection(cycle: true) { $0.presenter = $1 }
            .lifetime(.objectGraph)
        
        container.register(NotificationPresenterImpl.init)
            .as(NotificationPresenter.self)
                
        container.register(NotificationRouterImpl.init)
            .as(NotificationRouter.self)
    }
}
