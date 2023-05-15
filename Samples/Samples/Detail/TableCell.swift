//
//  TableCellTableViewCell.swift
//  Test
//
//  Created by Serkan Kayaduman on 14.05.2023.
//

import UIKit

class TableCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = .zero
        self.separatorInset = .zero
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateViews(rowData:Int) {
        let imageName = "image\((rowData % 2) + 1)"
        
        self.picture.image = UIImage(named: imageName)
        self.label.text = "Data \(rowData)"
    }
}
