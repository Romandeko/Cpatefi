//
//  CategoryViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 31.01.23.
//

import UIKit

class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    let category : Category
    
    // MARK: - Private properties
    private var playlists = [Playlist]()
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout:UICollectionViewCompositionalLayout(sectionProvider:
                                                                    { _, _ -> NSCollectionLayoutSection? in

            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(250)
                ),
                subitem: item,
                count: 2
            )
            
            group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            return NSCollectionLayoutSection(group: group)
        })
    )
    
    init(category:Category){
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder:NSCoder){
        fatalError()
    }
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        setUpCollectionView()
        title = category.name
        
        APICaller.shared.getCategoryPlaylists(category: category){[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func setUpCollectionView(){
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FeaturedPlaylistsCell.self, forCellWithReuseIdentifier: FeaturedPlaylistsCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
}

// MARK: - Extensions
extension CategoryViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistsCell.identifier, for: indexPath) as? FeaturedPlaylistsCell else { return UICollectionViewCell()}
        
        let playlist = playlists[indexPath.row]
        cell.configure(with: FeaturedPlaylistCellViewModel(
            name: playlist.name,
            artworkURL: URL(string: playlist.images.first?.url ?? ""),
            creatorName: playlist.owner.display_name))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = PlaylistViewController(playlist: playlists[indexPath.row])
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
