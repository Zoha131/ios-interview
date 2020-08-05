//
//  ViewController.swift
//  RW Take Home
//
//  Created by Zoha on 7/15/20.
//  Copyright © 2020 Zoha. All rights reserved.
//

import UIKit
import Combine
import Kingfisher

class ViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  var dataSource: UICollectionViewDiffableDataSource<String, Tutorial>?
  let viewModel = TutorialViewModel()
  var cancellables: Set<AnyCancellable> = []

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.register(TutorialViewCell.self, forCellWithReuseIdentifier: TutorialViewCell.reuseIdentifier)
    collectionView.collectionViewLayout = createCompositionalLayout()
    collectionView.contentInset.bottom = 120
    collectionView.contentInset.top = 20
    createDataSource()

    viewModel.$tutorials.sink { tutorialResult in
      switch tutorialResult {
      case .unInitialized:
        self.viewModel.fetchTutorial()

      case .loading:
        self.activityIndicator.isHidden = false

      case .success(let tutorials):
        self.reloadData(tutorials)
        self.activityIndicator.isHidden = true

      case .failure(let error):
        self.activityIndicator.isHidden = true
        self.showErrorAlert(for: error) { _ in
          self.viewModel.fetchTutorial()
        }
      }
    }
    .store(in: &cancellables)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    switch viewModel.selectedTutorialType {
    case .article:
      segmentedControl.selectedSegmentIndex = 0
    case .video:
      segmentedControl.selectedSegmentIndex = 1
    case .both:
      segmentedControl.selectedSegmentIndex = 2
    }
  }

  @IBAction func onTutorialTypeChange(_ sender: Any) {
    let index = segmentedControl.selectedSegmentIndex

    switch index {
    case 0:
      viewModel.selectedTutorialType = .article
    case 1:
      viewModel.selectedTutorialType = .video
    default:
      viewModel.selectedTutorialType = .both
    }
  }

  func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
    let layout = UICollectionViewCompositionalLayout {  _, _ in
      let cellSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(205)
      )

      let layoutItem = NSCollectionLayoutItem(layoutSize: cellSize)

      let isWidthRegular = self.traitCollection.horizontalSizeClass  == .regular
      let isLargeTextOn = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      let itemCount = (isWidthRegular && !isLargeTextOn) ? 2: 1

      let layoutGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: cellSize,
        subitem: layoutItem,
        count: itemCount
      )
      layoutGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
      layoutGroup.interItemSpacing = .fixed(20)

      let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
      layoutSection.interGroupSpacing = 20

      return layoutSection
    }

    return layout
  }

  func createDataSource() {
    dataSource = UICollectionViewDiffableDataSource<String, Tutorial>(
      collectionView: collectionView
    ) { collectionView, indexPath, tutorial in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: TutorialViewCell.reuseIdentifier, for: indexPath
        ) as? TutorialViewCell else {
          fatalError("Unable to dequeue")
      }

      cell.updateCellData(
        release: tutorial.attributes.releaseTxt,
        title: tutorial.attributes.name,
        details: tutorial.attributes.descriptionPlainText,
        tutorialType: tutorial.attributes.contentType == "article" ? .article : .video,
        durationTxt: tutorial.attributes.durationTxt
      )

      let url = URL(string: tutorial.attributes.cardArtworkURL)
      cell.artWorkImage.kf.indicatorType = .activity
      cell.artWorkImage.kf.setImage(with: url, options: [.transition(.fade(0.4))])

      return cell
    }
  }

  func reloadData(_ tutorials: [Tutorial]) {
    let section = "sections"

    var snapshot = NSDiffableDataSourceSnapshot<String, Tutorial>()
    snapshot.appendSections([section])
    snapshot.appendItems(tutorials, toSection: section)

    dataSource?.apply(snapshot)
  }

  private func showErrorAlert(for error: Error, callback: ((UIAlertAction) -> Void )?) {
    let alert = UIAlertController(
      title: "Opps!!",
      message: "Something went wrong: \(error.localizedDescription)",
      preferredStyle: .alert
    )
    let action = UIAlertAction(title: "Try Agin", style: UIAlertAction.Style.default, handler: callback)
    alert.addAction(action)

    self.present(alert, animated: true, completion: nil)
  }
}
