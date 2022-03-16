//
//  ActivityCell.swift
//  dejavu
//
//  Created by thongvm on 16/03/2022.
//

import Foundation
import UIKit

class ActivityCell: UICollectionViewCell {
    
    @IBOutlet weak var lbActivity: UILabel!
    @IBOutlet weak var lbAccessibility: UILabel!
    @IBOutlet weak var lbParticipants: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func render(model: ActivityModel) {
        self.lbActivity.text = model.activity
        self.lbAccessibility.text = "\(model.accessibility)"
        self.lbParticipants.text = "\(model.participants)"
    }
}
