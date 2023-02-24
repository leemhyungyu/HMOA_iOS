//
//  AppTabbarController.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/01/12.
//

import UIKit

class AppTabbarController: UITabBarController {
    
    // MARK: - Properties
    
    let menuTab: UITabBarItem = {
       
        let item = UITabBarItem()
        item.customTabBar(imageName: "menu")

        return item
    }()
    
    let newsTab: UITabBarItem = {
       
        let item = UITabBarItem()
        item.customTabBar(imageName: "news")

        return item
    }()
    
    let homeTab: UITabBarItem = {
       
        let item = UITabBarItem()
        item.customTabBar(imageName: "home")
        
        return item
    }()
    
    let drawerTab: UITabBarItem = {
       
        let item = UITabBarItem()
        item.customTabBar(imageName: "drawer")
        
        return item
    }()
    
    let myPageTab: UITabBarItem = {
       
        let item = UITabBarItem()
        item.customTabBar(imageName: "myPage")

        return item
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabbar()
    }
}

extension AppTabbarController {
    
    func configureTabbar() {
        let menuVC = MenuViewController(),
        newsVC = UINavigationController(rootViewController: NewsViewController()),
        homeVC = UINavigationController(rootViewController: HomeViewController()),
        drawerVC = DrawerViewController(),
        myPageVC = UINavigationController(rootViewController: MyPageViewController())
        
        viewControllers = [homeVC, menuVC, newsVC, drawerVC, myPageVC]
        
        self.selectedIndex = 0
        view.backgroundColor = .white
        tabBar.barTintColor = .black
        tabBar.tintColor = .white
        tabBar.backgroundColor = .black
        tabBar.isTranslucent = false
        tabBar.unselectedItemTintColor = UIColor.customColor(.tabbarColor)
        tabBar.layer.masksToBounds = true
        
        menuVC.tabBarItem = menuTab
        newsVC.tabBarItem = newsTab
        homeVC.tabBarItem = homeTab
        drawerVC.tabBarItem = drawerTab
        myPageVC.tabBarItem = myPageTab
    }
}