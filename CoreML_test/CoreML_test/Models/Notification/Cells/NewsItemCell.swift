//
//  NewsItemCell.swift
//  CoreML_test
//
//  Created by Осина П.М. on 12.03.18.
//  Copyright © 2018 Осина П.М. All rights reserved.
//

import UIKit

class NewsItemCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func updateWithNewsItem(_ item: NewsItem){
        self.nameLabel.text = item.title
        self.nameLabel.textColor = .white
        
        self.dateLabel.text = DateParser.displayString(for: item.date)
        self.dateLabel.textColor = .white
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
