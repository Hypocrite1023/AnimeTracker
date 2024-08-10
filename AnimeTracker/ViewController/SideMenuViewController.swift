//
//  SideMenuViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/9.
//

import UIKit

class SideMenuViewController: UIViewController {
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sideMenuTableView.dataSource = self
        sideMenuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "sideMenuCell")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCell")!
        cell.backgroundColor = .blue
        return cell
    }
    
    
}
