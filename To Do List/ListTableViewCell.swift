//
//  ListTableViewCell.swift
//  To Do List
//
//  Created by Brishti Saha on 3/6/21.
//

import UIKit

protocol ListTableViewCellDelegate: class {
    func checkBoxToggle(sender: ListTableViewCell)
}

class ListTableViewCell: UITableViewCell {

    weak var delegate: ListTableViewCellDelegate?
    
    @IBOutlet weak var checkBoxButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBAction func checkToggle(_ sender: UIButton) {
        delegate?.checkBoxToggle(sender: self)
    }
}
