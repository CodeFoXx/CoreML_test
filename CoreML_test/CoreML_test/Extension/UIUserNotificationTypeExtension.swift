//
//  UIUserNotificationTypeExtension.swift
//  CoreML_test
//
//  Created by Осина П.М. on 13.03.18.
//  Copyright © 2018 Осина П.М. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

extension UIUserNotificationType {
    
    @available(iOS 10.0, *)
    func authorizationOptions() -> UNAuthorizationOptions{
        var options: UNAuthorizationOptions = []
        if contains(.alert){
            options.formUnion(.alert)
        }
        if contains(.sound){
            options.formUnion(.sound)
        }
        if contains(.badge){
            options.formUnion(.badge)
        }
        return options
    }
}


