//
//  SettingVC.swift
//  Kerdy
//
//  Created by JEONGEUN KIM on 10/31/23.
//

import UIKit

import RxSwift
import RxDataSources

final class SettingVC: BaseVC {
    
    // MARK: - Property
    
    typealias DataSource = RxCollectionViewSectionedReloadDataSource<SettingSectionItem.Model>
    
    private var dataSource: DataSource!
    private let viewModel: SettingViewModel
    
    // MARK: - UI Components
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout())
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - Init
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    // MAKR: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRegisteration()
        setLayout()
        setDataSource()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting

extension SettingVC {
    
    private func setRegisteration() {
        
        collectionView.register(SettingProfileCell.self, forCellWithReuseIdentifier: SettingProfileCell.identifier)
        collectionView.register(SettingBasicCell.self, forCellWithReuseIdentifier: SettingBasicCell.identifier)
    }
    
    private func setLayout() {
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(safeArea)
        }
    }
    
    private func bind() {
        
        let input = SettingViewModel.Input(viewWillAppear: rx.viewWillAppear.asDriver())
        let output = viewModel.transform(input: input)
        
        output.settingList
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .filter { $0.section == 1 }
            .bind { indexpath in
                let viewControllers: [UIViewController.Type] = [NotificationVC.self,
                                                                BlockListVC.self,
                                                                TermsOfUseVC.self]
                
                guard indexpath.item < viewControllers.count else { return }
                let vc = viewControllers[indexpath.item].init()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - DataSource

extension SettingVC {
    
    func setDataSource() {
        
        dataSource = DataSource { [weak self] _, collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case let .profile(item):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SettingProfileCell.identifier,
                    for: indexPath
                ) as? SettingProfileCell else { return UICollectionViewCell() }
                cell.configureData(to: item)
                self.configureButton(cell: cell)
                return cell
                
            case let .basic(item):
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SettingBasicCell.identifier,
                    for: indexPath
                ) as? SettingBasicCell else { return UICollectionViewCell() }
                cell.configureData(with: item, at: indexPath.item)
                return cell
            }
        }
    }
    
    func layout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            guard self != nil else { return nil }
            guard let section = SettingSectionItem.Section(rawValue: sectionIndex) else { return nil }
            switch section {
            case .profile:
                let itemGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(195))
                let item = NSCollectionLayoutItem(layoutSize: itemGroupSize)
                
                let group = NSCollectionLayoutGroup.vertical(layoutSize: itemGroupSize,
                                                             subitem: item,
                                                             count: 1)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 0, bottom: 14, trailing: 0)
                return section
                
            case .basic:
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                config.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: config,
                                                             layoutEnvironment: layoutEnvironment)
                return section
                
            }
        }
    }
}

extension SettingVC {
    
    func configureButton(cell: SettingProfileCell) {
        cell.rx.article
            .asDriver()
            .drive(with: self) { owner, _ in
                let nextVC = SettingWrittenVC(type: .article)
                owner.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: cell.disposeBag)
        
        cell.rx.comment
            .asDriver()
            .drive(with: self) { owner, _ in
                let nextVC = SettingWrittenVC(type: .comment)
                owner.navigationController?.pushViewController(nextVC, animated: true)
            }
            .disposed(by: cell.disposeBag)
    }
}
