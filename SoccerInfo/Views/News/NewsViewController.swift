//
//  NewsViewController.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/18.
//

import UIKit
import SafariServices

final class NewsViewController: BasicTabViewController<NewsData> {
    typealias SearchResponse = Result<NewsResponse, APIErrorType>
    
    private var newsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .none
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.rowHeight = 175
        return tableView
    }()
    
    private var totalPage: Int = 0
    private var start: Int = 1
    
    override var data: [NewsData] {
        didSet {
            if activityView.isAnimating { activityView.stopAnimating() }
            newsTableView.reloadData()
        }
    }
    
    override func viewConfig() {
        super.viewConfig()        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        newsTableView.backgroundColor = .clear
        newsTableView.separatorInset.left = newsTableView.separatorInset.right
        addSubviews(newsTableView)
    }
    
    override func constraintsConfig() {
        super.constraintsConfig()
        newsTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func fetchData() {
        let group = DispatchGroup()
        // News Search
        fetchAPIData(of: .newsSearch(start: 1, display: 30, league: league)) { [weak self] (result: SearchResponse) in
            switch result {
            case .success(let newsResponse):
                var items = newsResponse.items
                if items.isEmpty { return }
                self?.totalPage = min(self!.totalPage, 100)
                
                var randomIndex: Set<Int> = [0]
                let minCount = min(items.count, 5)
                while randomIndex.count < minCount {
                    randomIndex.insert(Int.random(in: 0 ..< minCount))
                }
                
                // News Image Search by News title
                for i in randomIndex {
                    group.enter()
                    self?.fetchAPIData(of: .newsImage(sort: "sim", display: 1, query: items[i].title ?? "")) { (result: SearchResponse) in
                        switch result {
                        case .success(let newsResponse):
                            if newsResponse.items.isEmpty == false {
                                items[i].imageURL = newsResponse.items[0].link
                            }
                            group.leave()
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
                group.notify(queue: .main, execute: {
                    self?.data = items
                })
            case .failure(let erorr):
                print(erorr)
            }
        }
    }
}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier,
                                                 for: indexPath) as! NewsTableViewCell
        cell.backgroundColor = league.colors[2]
        cell.configure(with: data[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let newsLink = data[indexPath.section].link,
              let newsURL = URL(string: newsLink) else { return }
        // safari
        let safariVC = SFSafariViewController(url: newsURL)
        safariVC.modalPresentationStyle = .fullScreen
        present(safariVC, animated: true, completion: nil)
    }
}
