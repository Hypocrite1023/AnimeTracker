//
//  StaffPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/25.
//

import UIKit

class StaffPreview: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var staffImageView: UIImageView!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var staffRoleLabel: UILabel!
    var staffID: Int?
    weak var staffIdDelegate: StaffIdDelegate?
    
    init(frame: CGRect, staffID: Int?) {
        super.init(frame: frame)
        self.staffID = staffID
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.staffID = nil
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("StaffPreview", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showStaffDetail))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc func showStaffDetail() {
        print(staffID)
        if let staffID = staffID {
            staffIdDelegate?.showStaffPage(staffID: staffID)
        }
    }

}

protocol StaffIdDelegate: AnyObject {
    func showStaffPage(staffID: Int)
}
