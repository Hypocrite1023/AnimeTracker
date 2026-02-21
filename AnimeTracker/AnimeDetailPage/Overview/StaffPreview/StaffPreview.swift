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
    
    init() {
        super.init(frame: .zero)
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
        setStyle()
    }
    
    @objc func showStaffDetail() {
        if let staffID = staffID {
            staffIdDelegate?.showStaffPage(staffID: staffID)
        }
    }
    
    func bind(_ model: Model) {
        staffImageView.kf.setImage(with: model.staffImageURL)
        staffNameLabel.text = model.staffName
        staffRoleLabel.text = model.staffRole
        staffID = model.staffID
    }
    
    func setStyle() {
        staffNameLabel.font = .atBody
        staffNameLabel.textColor = .atTextPrimary
        
        staffRoleLabel.font = .atCaption
        staffRoleLabel.textColor = .atTextSecondary
        
        contentView.backgroundColor = .atSecondaryBackground
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
    }
}

extension StaffPreview {
    struct Model {
        let staffImageURL: URL?
        let staffName: String?
        let staffRole: String?
        let staffID: Int?
    }
}

protocol StaffIdDelegate: AnyObject {
    func showStaffPage(staffID: Int)
}
