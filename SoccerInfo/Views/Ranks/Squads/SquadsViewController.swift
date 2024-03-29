//
//  SquadsViewController.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/18.
//

import UIKit
import SnapKit
import RealmSwift
import Charts

// current 15 match results collection view -> horizontal scroll
// curretn 15 match win rate Pie Chart

// Fixtures Data -> filtering completed match by score

final class SquadsViewController: UIViewController {
    
    deinit {
        print("SquadVC deinit")
    }
    
    private let dimView = UIView()
    private let scrollView = UIScrollView()
    private let winRateLabel = CategoryLabel()
    private let currentMatchLabel = CategoryLabel()
    private let winRatePieChartView = PieChartView()
    private let labelContainerView = CurrentMatchLabelContainerView()
    
    private let currentMatchCollectionView = UICollectionView(
        frame: .zero, collectionViewLayout: CurrentMatchCollectionViewFlowLayout())
    private lazy var dismissButton = UIBarButtonItem(
        barButtonSystemItem: .close, target: self, action: #selector(dismissButtonClicked)
    )

    var id: Int = 0    
    var currentRank: Int = 0
    var teamName: String = ""    
    
    // FixturesRealmData
    private var data: [FixturesRealmData] = [] {
        didSet {
            pieChartConfig()
            currentMatchCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfig()
        constraintsConfig()
        loadCurrentMatchData()
    }
    
    private func viewConfig() {
        navigationConfig()
        collectionViewConfig()
        labelContainerView.configure(teamName: teamName, rank: currentRank)
        view.backgroundColor = PublicPropertyManager.shared.league.colors[0]
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        [winRateLabel, winRatePieChartView,
         currentMatchLabel, currentMatchCollectionView]
            .forEach { scrollView.addSubview($0) }
        
        [dimView, labelContainerView, scrollView]
            .forEach { view.addSubview($0) }
    }
    
    private func constraintsConfig() {
        dimView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.2)
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        labelContainerView.snp.makeConstraints { make in
            make.height.equalTo(125)
            make.centerX.equalToSuperview()
            make.width.equalTo(dimView).multipliedBy(0.6)
            make.centerY.equalTo(dimView).multipliedBy(1.1)
        }
        
        scrollView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalTo(labelContainerView.snp.bottom).offset(20)
        }
        
        winRateLabel.snp.makeConstraints { make in
            make.width.equalTo(scrollView)
            make.leading.top.trailing.equalToSuperview()
        }
        
        winRatePieChartView.snp.makeConstraints { make in
            make.height.equalTo(300)
            make.width.equalTo(winRateLabel)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(winRateLabel.snp.bottom)
        }

        currentMatchLabel.snp.makeConstraints { make in
            make.width.equalTo(winRateLabel)
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(winRatePieChartView.snp.bottom).offset(10)
        }

        currentMatchCollectionView.snp.makeConstraints { make in
            make.height.equalTo(150)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(scrollView).offset(-20)
            make.top.equalTo(currentMatchLabel.snp.bottom).offset(10)
        }
    }
    
    private func collectionViewConfig() {
        currentMatchCollectionView.addShadow()
        currentMatchCollectionView.delegate = self
        currentMatchCollectionView.dataSource = self
        currentMatchCollectionView.backgroundColor = .clear
        currentMatchCollectionView.decelerationRate = .fast
        currentMatchCollectionView.showsVerticalScrollIndicator = false
        currentMatchCollectionView.showsHorizontalScrollIndicator = false
        
        currentMatchCollectionView.register(
            CurrentMatchCollectionViewCell.self,
            forCellWithReuseIdentifier: CurrentMatchCollectionViewCell.identifier
        )
    }
    
    private func navigationConfig() {
        navigationItem.leftBarButtonItem = dismissButton
        
        let appearnce = UINavigationBarAppearance()
        appearnce.configureWithOpaqueBackground()
        appearnce.titleTextAttributes = [.foregroundColor : UIColor.white]
        appearnce.backgroundColor = PublicPropertyManager.shared.league.colors[0]
        
        navigationController?.navigationBar.standardAppearance = appearnce
        navigationController?.navigationBar.scrollEdgeAppearance = appearnce
    }
    
    private func pieChartConfig() {
        var winValue = 0
        var loseValue = 0
        var drawValue = 0
        var totalGoal = 0
        var totalLoss = 0
        data.forEach {
            let homeGoal = $0.homeGoal!
            let awayGoal = $0.awayGoal!
            if $0.homeID == id {
                totalGoal += homeGoal
                totalLoss += awayGoal
                if homeGoal > awayGoal {
                    winValue += 1
                }
                else if homeGoal < awayGoal {
                    loseValue += 1
                }
                else {
                    drawValue += 1
                }
            }
            else {
                totalGoal += awayGoal
                totalLoss += homeGoal
                if awayGoal > homeGoal {
                    winValue += 1
                }
                else if awayGoal < homeGoal {
                    loseValue += 1
                }
                else {
                    drawValue += 1
                }
            }
        }
        let totalValue = winValue + loseValue + drawValue
        
        winRateLabel.text = "최근 \(totalValue)경기 \(winValue)승 \(drawValue)무 \(loseValue)패"
        currentMatchLabel.text = "최근 \(totalValue)경기 \(totalGoal)득점 \(totalLoss)실점"
        
        let entries = [
            PieChartDataEntry(value: Double(winValue) / Double(totalValue) * 100, label: "승"),
            PieChartDataEntry(value: Double(drawValue) / Double(totalValue) * 100, label: "무"),
            PieChartDataEntry(value: Double(loseValue) / Double(totalValue) * 100, label: "패")
        ]
        let dataSet = PieChartDataSet(entries: entries, label: "| 최근 경기 승률(%)")
        dataSet.sliceSpace = 3
        dataSet.valueTextColor = .white
        dataSet.entryLabelFont = .systemFont(ofSize: 0)
        dataSet.colors = [.systemIndigo, .systemGreen, .systemPink]
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .semibold)
        
        let data = PieChartData(dataSet: dataSet)
        
        data.setValueFont(.systemFont(ofSize: 12, weight: .medium))
        
        winRatePieChartView.data = data
        winRatePieChartView.holeColor = .clear
        winRatePieChartView.backgroundColor = .clear
        winRatePieChartView.legend.textColor = .white
        winRatePieChartView.legend.horizontalAlignment = .center
        winRatePieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutCirc)
    }
    
    private func loadCurrentMatchData() {
        let league = PublicPropertyManager.shared.league
        let season = PublicPropertyManager.shared.season
        
        let app = App(id: APIComponents.realmAppID)
        guard let user = app.currentUser else {
            alertWithCheckButton(title: "서버 접속에 실패했습니다",
                                 message: "네트워크 연결 상태를 확인하고 다시 시도해주세요.",
                                 completion: nil)
            return
        }
        let configuration = user.configuration(partitionValue: "\(league.leagueID)")
        do {
            // Local Realm Load
            let localRealm = try Realm(configuration: configuration)
            
            // check league, season, updateDate
            let objects = localRealm.objects(FixturesTable.self).where {
                $0._partition == "\(league.leagueID)" &&
                $0.season == season
            }
            
            let teamFixture = objects[0].content.where { [weak self] in
                ($0.homeID == self!.id || $0.awayID == self!.id) &&
                $0.homeGoal != nil }
                .sorted { $0.fixtureDate > $1.fixtureDate }
            
            let fixtureCount = min(8, teamFixture.count)
            data = Array(0 ..< fixtureCount).map { return teamFixture[$0] }
        }
        catch {
            alertWithCheckButton(title: "데이터를 불러오는데 실패했습니다.",
                                 message: "",
                                 completion: nil)
        }
    }
    
    @objc private func dismissButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
}

extension SquadsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurrentMatchCollectionViewCell.identifier, for: indexPath) as! CurrentMatchCollectionViewCell
        
        let fixture = data[indexPath.row]
        let isHome = fixture.homeID == id ? true : false
        
        cell.backgroundColor = PublicPropertyManager.shared.league.colors[2]
        cell.configure(with: data[indexPath.row], isHome: isHome)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let matchDetailVC = MatchDetailViewController()
        let selectedData = data[indexPath.item]
        matchDetailVC.fixtureID = selectedData.fixtureID
        matchDetailVC.homeTeamName = selectedData.homeName
        matchDetailVC.awayTeamName = selectedData.awayName
        matchDetailVC.homeScore = selectedData.homeGoal ?? 0
        matchDetailVC.awayScore = selectedData.awayGoal ?? 0
        navigationController?.pushViewController(matchDetailVC, animated: true)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let flowLayout = currentMatchCollectionView.collectionViewLayout as! CurrentMatchCollectionViewFlowLayout
        
        let offset: CGFloat = flowLayout.itemSize.width
        
        let estimatedIndex = scrollView.contentOffset.x / offset
        var index = 0
        
        if velocity.x > 0 {
            index = Int(ceil(estimatedIndex))
        }
        else if velocity.x < 0 {
            index = Int(floor(estimatedIndex))
        }
        else {
            index = Int(round(estimatedIndex))
        }
        
        let x = (CGFloat(index) * offset) + (CGFloat(index - 1) * flowLayout.sectionInset.left)
        targetContentOffset.pointee = CGPoint(x: x, y: 0)
    }
}

extension SquadsViewController {
    private final class CategoryLabel: UILabel {
        convenience init() {
            self.init(frame: .zero)
            viewConfig()
        }
        
        private func viewConfig() {
            textColor = .white
            textAlignment = .center
            font = .systemFont(ofSize: 16, weight: .semibold)
        }
    }
}
