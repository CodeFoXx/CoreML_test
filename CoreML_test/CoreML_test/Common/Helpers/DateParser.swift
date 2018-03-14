//
//  DateParser.swift
//  CoreML_test
//
//  Created by Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М. All rights reserved.
//

import UIKit

class DateParser: NSObject {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    static func dateWithPodcastDateString(_ dateString: String) -> Date?{
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return dateFormatter.date(from: dateString)
    }
    
    static func displayString(for date: Date) -> String{
        dateFormatter.dateFormat = "HH:mm dd MMMM, yyyy"
        return dateFormatter.string(from:date)
    }
}
