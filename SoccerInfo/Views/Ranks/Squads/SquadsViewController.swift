//
//  SquadsViewController.swift
//  SoccerInfo
//
//  Created by JD_MacMini on 2021/11/18.
//

import UIKit
import RealmSwift
import Charts

// current 15 match results collection view -> horizontal scroll
// curretn 15 match win rate Pie Chart

// Fixtures Data -> filtering completed match by score

final class SquadsViewController: UIViewController {
    
    deinit {
        print("SquadVC deinit")
    }
    
    @IBOutlet weak var labelContainerView: UIView!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var currentRankLabel: UILabel!
    @IBOutlet weak var rankDescriptionLabel: UILabel!
    
    @IBOutlet weak var winRateLabel: UILabel!
    @IBOutlet weak var goalDiffLabel: UILabel!
    @IBOutlet weak var winRatePieChartView: PieChartView!
    @IBOutlet weak var currentMatchCollectionView: UICollectionView!

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
        loadCurrentMatchData()
    }
    
    private func viewConfig() {
        view.backgroundColor = PublicPropertyManager.shared.league.colors[0]
        
        // label container view shadow
        labelContainerView.addCorner(rad: 10)
        labelContainerView.addShadow()
        
        // labels config
        teamNameLabel.adjustsFontSizeToFitWidth = true
        
        teamNameLabel.textAlignment = .center
        currentRankLabel.textAlignment = .center
        rankDescriptionLabel.textAlignment = .center
        
        teamNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        currentRankLabel.font = .systemFont(ofSize: 19, weight: .medium)
        rankDescriptionLabel.font = .systemFont(ofSize: 15, weight: .medium)
        
        teamNameLabel.text = teamName
        currentRankLabel.text = "\(currentRank)???"
        winRateLabel.textColor = .white
        goalDiffLabel.textColor = .white
        
        // collection view config
        currentMatchCollectionView.delegate = self
        currentMatchCollectionView.dataSource = self
        currentMatchCollectionView.showsVerticalScrollIndicator = false
        currentMatchCollectionView.showsHorizontalScrollIndicator = false
        currentMatchCollectionView.collectionViewLayout = CurrentMatchCollectionViewFlowLayout()
        currentMatchCollectionView.register(UINib(nibName: "CurrentMatchCollectionViewCell", bundle: nil),
                                            forCellWithReuseIdentifier: CurrentMatchCollectionViewCell.identifier)
        
        currentMatchCollectionView.decelerationRate = .fast
        currentMatchCollectionView.backgroundColor = .clear
        currentMatchCollectionView.addShadow()
        
        // Dismiss Button Config
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .close,
                                            target: self,
                                            action: #selector(dismissButtonClicked))
        navigationItem.leftBarButtonItem = dismissButton
        
        // navigation appearance config
        let appearnce = UINavigationBarAppearance()
        appearnce.configureWithOpaqueBackground()
        appearnce.backgroundColor = PublicPropertyManager.shared.league.colors[0]
        appearnce.titleTextAttributes = [.foregroundColor : UIColor.white]
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
        
        winRateLabel.text = "?????? \(totalValue)?????? \(winValue)??? \(drawValue)??? \(loseValue)???"
        goalDiffLabel.text = "?????? \(totalValue)?????? \(totalGoal)?????? \(totalLoss)??????"
        
        let entries = [
            PieChartDataEntry(value: Double(winValue) / Double(totalValue) * 100, label: "???"),
            PieChartDataEntry(value: Double(drawValue) / Double(totalValue) * 100, label: "???"),
            PieChartDataEntry(value: Double(loseValue) / Double(totalValue) * 100, label: "???")
        ]
        let dataSet = PieChartDataSet(entries: entries, label: "| ?????? ?????? ??????(%)")
        dataSet.sliceSpace = 3
        dataSet.colors = [.systemIndigo, .systemGreen, .systemPink]
        dataSet.valueTextColor = .white
        dataSet.valueFont = .systemFont(ofSize: 12, weight: .semibold)
        dataSet.entryLabelFont = .systemFont(ofSize: 0)
        
        let data = PieChartData(dataSet: dataSet)
        
        data.setValueFont(.systemFont(ofSize: 12, weight: .medium))
        
        winRatePieChartView.data = data
        winRatePieChartView.backgroundColor = .clear
        winRatePieChartView.holeColor = .clear
        winRatePieChartView.legend.horizontalAlignment = .center
        winRatePieChartView.legend.textColor = .white
        winRatePieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutCirc)
    }
    
    private func loadCurrentMatchData() {
        let league = PublicPropertyManager.shared.league
        let season = PublicPropertyManager.shared.season
        
        let app = App(id: APIComponents.realmAppID)
        guard let user = app.currentUser else {
            alertWithCheckButton(title: "?????? ????????? ??????????????????",
                                 message: "???????????? ?????? ????????? ???????????? ?????? ??????????????????.",
                                 completion: nil)
            return
        }
        print("FetchRealmData", user)
        let configuration = user.configuration(partitionValue: "\(league.leagueID)")
        do {
            // Local Realm Load
            print("Local Realm Load")
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
            alertWithCheckButton(title: "???????????? ??????????????? ??????????????????.",
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
        let storyboard = UIStoryboard(name: "MatchDetail", bundle: nil)
        let matchDetailVC = storyboard.instantiateViewController(withIdentifier: "MatchDetailViewController") as! MatchDetailViewController
        let selectedData = data[indexPath.item]
        matchDetailVC.fixtureID = selectedData.fixtureID
        matchDetailVC.homeScore = selectedData.homeGoal ?? 0
        matchDetailVC.awayScore = selectedData.awayGoal ?? 0
        matchDetailVC.homeTeamName = selectedData.homeName
        matchDetailVC.awayTeamName = selectedData.awayName
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
