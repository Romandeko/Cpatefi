//
//  HomeViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 15.12.22.
//

import UIKit

// MARK: - Enums
enum BrowseSectionType{
    case newReleases(viewModels: [NewReleasesCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
    
    var title : String{
        switch self{
        case .newReleases:
            return "New Releases"
        case .featuredPlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

class HomeViewController: UIViewController {
    
    lazy var collectionView : UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout{sectionIndex, _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: sectionIndex)
         }
    )
    
    // MARK: - Private properties
    private var newAlbums : [Album] = []
    private var playlists : [Playlist] = []
    private var tracks : [AudioTrack]  = []
    
    private let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(didTapSettings))
        configureCollectionView()
        view.addSubview(spinner)
        fetchData()
        addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - Private methods
    private func addLongTapGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }

    private func configureCollectionView(){
        view.addSubview(collectionView)
        collectionView.register(NewReleasesCell.self, forCellWithReuseIdentifier: NewReleasesCell.identifier)
        collectionView.register(FeaturedPlaylistsCell.self, forCellWithReuseIdentifier: FeaturedPlaylistsCell.identifier)
        collectionView.register(RecommendedTracksCell.self, forCellWithReuseIdentifier: RecommendedTracksCell.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
    }
  
    private func fetchData(){
        DispatchQueue.main.async {
            
            let group = DispatchGroup()
            
            group.enter()
            group.enter()
            group.enter()
            
            var newReleases : NewReleasesResponse?
            var featuredPlaylist : FeaturedPlaylistsResponse?
            var recommendations : RecommendationsResponse?
            
            APICaller.shared.getNewReleases{result in
                defer{
                    group.leave()
                }
                switch result{
                case .success(let model) :
                    newReleases = model
                case .failure(let error) :
                    print(error)
                }
                
            }
            
            APICaller.shared.getFeaturedPlayLists{result in
                defer{
                    group.leave()
                }
                switch result{
                case .success(let model) :
                    featuredPlaylist = model
                case .failure(let error) :
                    print(error)
                }
                
            }
            
            APICaller.shared.getRecommendedGenres{ result in
                switch result {
                case .success(let model) :
                    let genres = model.genres
                    var seeds = Set<String>()
                    while seeds.count < 5 {
                        if let random = genres.randomElement(){
                            seeds.insert(random)
                        }
                    }
                    APICaller.shared.gerRecommendations(genres: seeds){recommendedResults in
                        defer{
                            group.leave()
                        }
                        switch recommendedResults{
                        case .success(let model) :
                            recommendations = model
                        case .failure(let error) :
                            print(error)
                        }
                        
                    }
                case .failure(let error ) :
                    print(error)
                }
            }
            
            group.notify(queue: .main){
                guard let newAlbums = newReleases?.albums.items,
                      let playlists = featuredPlaylist?.playlists.items,
                      let tracks = recommendations?.tracks else  { return}
                
                self.configureModels(newAlbums: newAlbums, tracks: tracks, playlists: playlists)
            }
        }
    }

    private func configureModels(newAlbums: [Album],tracks : [AudioTrack],playlists : [Playlist]){
        
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        
        sections.append(.newReleases(viewModels: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name,
                                            artworkURL: URL(string: $0.images.first?.url ?? ""),
                                            numberOfTracks: $0.total_tracks,
                                            artistName: $0.artists.first?.name ?? "-")
        })))
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellViewModel(name: $0.name,
                                                 artworkURL: URL(string:$0.images.first?.url ?? ""),
                                                 creatorName: $0.owner.display_name)
        })))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return  RecommendedTrackCellViewModel(name:  $0.name,
                                                  artistName: $0.artists.first?.name ?? "-",
                                                  artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
        collectionView.reloadData()
    }
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func longPress(_ gesture : UILongPressGestureRecognizer){
        guard gesture.state == .began else { return }
        
        collectionView.isUserInteractionEnabled = true
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),indexPath.section == 2 else { return }
        
        let model = tracks[indexPath.row]
        let actionSheet = UIAlertController(title: model.name, message: "Would you like to add?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Add to playlist", style: .default){ [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist){ success in
                        
                    }
                }
                vc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: vc),animated: true)
            }
        })
        present(actionSheet,animated: true)
        
    }
    
}

// MARK: - Extensions
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       let type = sections[section]
        switch type {
        case .newReleases( let viewModels):
            return viewModels.count
            
        case .featuredPlaylists( let viewModels):
            return viewModels.count
            
        case.recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let type = sections[indexPath.section]
        
        switch type {
        case .newReleases( let viewModels):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleasesCell.identifier, for: indexPath) as? NewReleasesCell else {  return UICollectionViewCell()  }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
            
        case .featuredPlaylists( let viewModels):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistsCell.identifier, for: indexPath) as? FeaturedPlaylistsCell else {  return UICollectionViewCell()  }
            cell.configure(with: viewModels[indexPath.row])
            return cell
            
        case.recommendedTracks(let viewModels):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCell.identifier, for: indexPath) as? RecommendedTracksCell else {  return UICollectionViewCell()  }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section{
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
            
        case .recommendedTracks:
            PlayerPresenter.shared.startPlayback(from: self,tracks:tracks ,index: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView()}
        
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }
    
    static func createSectionLayout(section: Int) -> NSCollectionLayoutSection{
       let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)) , elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        switch section{
        case 0 :
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(360)
                ),
                subitem: item,
                count: 3
            )
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)
                ),
                subitem: verticalGroup,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 1 :
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: item,
                count: 2
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: verticalGroup,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        case 2:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(80)
                ),
                subitem: item,
                count: 1
            )
           
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
            
        default :
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(360)
                ),
                subitem: item,
                count: 1
            )
           
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
}
