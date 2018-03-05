//
//  NewsStore.swift
//  CoreML_test
//
//  Created by Осина П.М. on 05.03.18.
//  Copyright © 2018 Осина П.М. All rights reserved.
//

import Foundation


class NewsStore: NSObject{
    static let shared = NewsStore()
    
    var items: [NewsItem] = []
    
    override init() {
        super.init()
        self.loadItemsFromCache()
    }
    
    func add(item: NewsItem){
        items.insert(item, at: 0)
        saveItemsToCache()
    }
}

extension NewsStore{
    func saveItemsToCache(){
        NSKeyedArchiver.archiveRootObject(items, toFile: itemsCachePath)
    }
    
    func loadItemsFromCache(){
        if let cachedItems = NSKeyedUnarchiver.unarchiveObject(withFile: itemsCachePath){
            items = cachedItems as! [NewsItem]
        }
    }
    
    var itemsCachePath: String{
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentURL.appendingPathComponent("news.dat")
        return fileURL.path
    }
}
