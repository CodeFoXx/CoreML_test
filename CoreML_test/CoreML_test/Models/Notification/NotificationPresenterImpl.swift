//
//  NotificationPresenterImpl.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import UIKit

class NotificationPresenterImpl: NotificationPresenter {

    weak private var view: NotificationView!
    private let router: NotificationRouter

    init(view: NotificationView, router: NotificationRouter) {
        self.view = view
        self.router = router
    }

}
