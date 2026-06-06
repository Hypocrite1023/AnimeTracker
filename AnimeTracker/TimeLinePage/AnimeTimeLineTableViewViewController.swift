import UIKit
import SwiftUI
import SnapKit

class AnimeTimeLineTableViewViewController: UIViewController {
    
    @IBOutlet weak var animeTimeLineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Embed the SwiftUI TimelineView using UIHostingController
        let timelineUIHostingController = UIHostingController(rootView: TimelineView())
        let timelineView = timelineUIHostingController.view!
        self.addChild(timelineUIHostingController)
        self.view.addSubview(timelineView)
        
        timelineView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        timelineUIHostingController.didMove(toParent: self)
        
        // Hide the original storyboard table view
        animeTimeLineTableView.isHidden = true
    }
}
