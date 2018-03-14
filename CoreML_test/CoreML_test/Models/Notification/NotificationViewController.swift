//
//  NotificationViewController.swift
//  CoreML_test
//
//  Created Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М.. All rights reserved.
//

import UIKit
import SafariServices

class NotificationViewController: UIViewController {
    
    @IBOutlet weak var newsTableView: UITableView!
    
	var presenter: NotificationPresenter!
    static let refreshNewsFeedNotification = "RefreshNewsFeedNotification"
    let newsStore = NewsStore.shared
    
	override func viewDidLoad() {
        super.viewDidLoad()
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        
        if let patternImage = UIImage(named: "pattern-grey") {
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(patternImage: patternImage)
            newsTableView.backgroundView = backgroundView
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotificationViewController.receivedRefreshNewsFeedNotification(_:)), name: NSNotification.Name(rawValue: NotificationViewController.refreshNewsFeedNotification), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        newsTableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func receivedRefreshNewsFeedNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.newsTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.newsTableView.reloadData()
        }
    }
    
   
    
}

extension NotificationViewController: NotificationView, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(newsStore.items.count)
        return newsStore.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemCell", for: indexPath) as! NewsItemCell
        cell.updateWithNewsItem(newsStore.items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let item = newsStore.items[indexPath.row]
        if let url = URL(string: item.link), url.scheme == "https" {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = newsStore.items[indexPath.row]
        
        if let url = URL(string: item.link) {
            let safari = SFSafariViewController(url: url)
            present(safari, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
