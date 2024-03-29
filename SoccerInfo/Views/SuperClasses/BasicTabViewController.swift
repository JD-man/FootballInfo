//
//  BasicTabViewController.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/23.
//

import UIKit
import RealmSwift
import SideMenu
import SwiftUI
import SnapKit

class BasicTabViewController<T: BasicTabViewData>: UIViewController, UINavigationControllerDelegate, SideMenuNavigationControllerDelegate {
    
    var data: [T] = []
    var season: Int = PublicPropertyManager.shared.season
    var gradient = CAGradientLayer()
    var activityView = UIActivityIndicatorView()
    
    var league: League = .premierLeague {
        didSet {
            startActivityView()
            changeBackgroundColor()
            fetchData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        constraintsConfig()
        sideButtonConfig()
        league = PublicPropertyManager.shared.league
    }
    
    func viewConfig() {
        changeBackgroundColor()
        
        // gradient config
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0.7)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradient, at: 0)
        
        navAppearenceConfig()
    }
    
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { view.addSubview($0) }        
        activityView = activityIndicator()
    }
    
    func constraintsConfig() { }
    
    func sideButtonConfig() {
        let sideButton = UIBarButtonItem(title: "Premier League",
                                         style: .plain,
                                         target: self,
                                         action: #selector(sideButtonClicked))
        
        sideButton.tintColor = .link
        navigationItem.leftBarButtonItem = sideButton
    }
    
    func startActivityView() {
        activityView.backgroundColor = league.colors[0]
        activityView.startAnimating()
    }
    
    @objc func sideButtonClicked() {
        let sideVC = SideViewController()
        
        sideVC.selectedLeague = League(rawValue: navigationItem.leftBarButtonItem!.title!)!
        let sideNav = SideMenuNavigationController(rootViewController: sideVC)
        
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.presentingScaleFactor = 0.95
        presentationStyle.presentingEndAlpha = 0.35
        
        sideNav.leftSide = true
        sideNav.menuWidth = view.bounds.width * 0.6
        sideNav.presentationStyle = presentationStyle
        sideNav.delegate = self
        
        present(sideNav, animated: true, completion: nil)
    }
    
    // for sharing league value whole tab
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if league != PublicPropertyManager.shared.league {
            league = PublicPropertyManager.shared.league
        }
    }
    
    // for sharing league value whole tab
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem?.title = PublicPropertyManager.shared.league.rawValue
    }
    
    // change league
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        guard let sideVC = menu.topViewController as? SideViewController else { return }
        if league != sideVC.selectedLeague {
            if let fixtureVC = self as? FixturesViewController {
                fixtureVC.firstDay = Date().fixtureFirstDay
            }
            PublicPropertyManager.shared.league = sideVC.selectedLeague
            league = sideVC.selectedLeague
            navigationItem.leftBarButtonItem?.title = sideVC.selectedLeague.rawValue            
        }
    }
    
    // abstract method for fetching data
    func fetchData() { }
    
    func changeBackgroundColor() {
        let upperColor = league.colors[0]
        let bottomColor = league.colors[1]
        let colors = [upperColor.cgColor, bottomColor.cgColor]
        
        gradient.colors = colors
        navigationController?.navigationBar.standardAppearance.backgroundColor = upperColor        
    }
    
    func navAppearenceConfig() {
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let scrollEdgeAppearence = UINavigationBarAppearance()
        scrollEdgeAppearence.configureWithTransparentBackground()
        scrollEdgeAppearence.titleTextAttributes = [.foregroundColor : UIColor.white]
        scrollEdgeAppearence.largeTitleTextAttributes = [.foregroundColor : UIColor.white]
        navigationController?.navigationBar.scrollEdgeAppearance = scrollEdgeAppearence
        
        let standardAppearence = UINavigationBarAppearance()
        standardAppearence.configureWithOpaqueBackground()
        standardAppearence.backgroundColor = league.colors[0]
        standardAppearence.titleTextAttributes = [.foregroundColor : UIColor.white]
        navigationController?.navigationBar.standardAppearance = standardAppearence
    }
}
