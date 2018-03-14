//
//  LocalNotificationPresenterImpl.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import UIKit

class LocalNotificationPresenterImpl: LocalNotificationPresenter {

    weak private var view: LocalNotificationView!
    private let router: LocalNotificationRouter

    init(view: LocalNotificationView, router: LocalNotificationRouter) {
        self.view = view
        self.router = router
    }

}
