//
//  ActivityDetailController.swift
//  dejavu
//
//  Created by thongvm on 16/03/2022.
//

import Foundation
import UIKit
class ActivityDetailController: UIViewController {
    var activity: ActivityModel?
    @IBOutlet weak var lbActivity: UILabel!
    @IBOutlet weak var lbAccessibility: UILabel!
    @IBOutlet weak var lbParticipants: UILabel!
    @IBOutlet weak var lbPrice: UILabel!
    @IBOutlet weak var lbLink: UILabel!
    @IBOutlet weak var lbKey: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.render()
    }
    
    func render() {
        self.title = self.activity?.type.uppercased()
        self.lbActivity.text = self.activity?.activity
        self.lbAccessibility.text = "\(self.activity?.accessibility ?? 0)"
        self.lbParticipants.text = "\(self.activity?.participants ?? 0)"
        self.lbPrice.text = "\(self.activity?.price ?? 0)"
        self.lbLink.text = self.activity?.link
        self.lbKey.text = self.activity?.key
    }
}
