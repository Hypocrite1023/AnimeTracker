//
//  TabBarViewController.swift
//  AnimeTracker
//
//  Created by 邱翊均 on 2024/8/7.
//

import UIKit
import FirebaseAuth
import UserNotifications

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // logout
        let logoutAction = UIAction(title: "Logout", image: UIImage(systemName: "figure.walk")) { action in
            do {
                AnimeNotification.shared.removeAllNotification() // remove all notification that record in user default
                print("remove all notification.")
                try Auth.auth().signOut()
                let loginPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginPage")
                self.navigationController?.setViewControllers([loginPage], animated: true) // navigate to login page
            } catch {
                print(error)
            }
        }
        
        let menu = UIMenu(title: "Options", children: [logoutAction])
        if let userName = Auth.auth().currentUser?.displayName {
            navigationItem.title = "Hello, \(userName)"
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"), menu: menu)
        }
        requestNotificationPermission() // request notification permission
        print("check notification.")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
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

extension TabBarViewController: NavigateDelegate {
    func navigateTo(page: Int) {
        print(page)
        self.selectedIndex = page
    }
}


