//
//  StaffPreview.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/7/25.
//

import UIKit

class StaffPreview: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var staffImageView: UIImageView!
    @IBOutlet weak var staffNameLabel: UILabel!
    @IBOutlet weak var staffRoleLabel: UILabel!
    var staffID: Int?
    weak var fetchStaffDataDelegate: FetchStaffDataDelegate?
    
    init(frame: CGRect, staffID: Int?, fetchStaffDataDelegate: FetchStaffDataDelegate?) {
        super.init(frame: frame)
        self.staffID = staffID
        self.fetchStaffDataDelegate = fetchStaffDataDelegate
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.staffID = nil
        self.fetchStaffDataDelegate = nil
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
            fetchStaffDataDelegate?.fetchStaffDetailData(staffID: staffID)
        }
    }

}

protocol FetchStaffDataDelegate: AnyObject {
    func fetchStaffDetailData(staffID: Int)
}
