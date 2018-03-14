//
//  LocalNotificationRouterImpl.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import UIKit
import DITranquillity

class LocalNotificationRouterImpl: LocalNotificationRouter {
    
    private weak var viewController: UIViewController?
    private let container: DIContainer!
    
    init(viewController: LocalNotificationViewController, container: DIContainer) {
        self.viewController = viewController
        self.container = container
    }
}
