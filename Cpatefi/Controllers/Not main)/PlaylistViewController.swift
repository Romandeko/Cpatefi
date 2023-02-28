//
//  PlaylistViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit

class PlaylistViewController: UIViewController {

    // MARK: - Public Properties
    public var isOwner = false
    
    // MARK: - Private Properties
    private let playlist : Playlist
    private var viewModels = [RecommendedTrackCellViewModel]()
    private var tracks = [AudioTrack]()
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                ),
                subitem: item,
                count: 1
            )
           
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)) , elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            ]
            return section
        })
    )
    
    init(playlist : Playlist){
        self.playlist = playlist
        super.init(nibName : nil,bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = .clear
        view.backgroundColor = .systemBackground
        setUpCollectionView()
        
        APICaller.shared.getPlaylistDetails(for: playlist){[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({$0.track})
                    self?.viewModels = model.tracks.items.compactMap({
                        RecommendedTrackCellViewModel(name: $0.track.name,
                                                      artistName: $0.track.artists.first?.name ?? "-", artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: - Private methods
    private func setUpCollectionView(){
        view.addSubview(collectionView)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.register(RecommendedTracksCell.self, forCellWithReuseIdentifier: RecommendedTracksCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func longPress(_ gesture : UILongPressGestureRecognizer){
        guard gesture.state == .began else { return }
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
        
        let trackToDelete = tracks[indexPath.row]
        if isOwner{
            print("OWNER")
            let actionSheet = UIAlertController(title: trackToDelete.name, message: "would you like to remove?", preferredStyle: .actionSheet)
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            actionSheet.addAction(UIAlertAction(title: "Remove", style: .default){[weak self] _ in
                guard let strongSelf = self else {return}
                APICaller.shared.removeTrackFromPlaylist(track: trackToDelete, playlist: strongSelf.playlist){ success in
                    if success{
                        DispatchQueue.main.async {
                            strongSelf.tracks.remove(at: indexPath.row)
                            strongSelf.viewModels.remove(at: indexPath.row)
                            strongSelf.collectionView.reloadData()
                        }
                    }
                    
                }
            })
            
            present(actionSheet,animated: true)
        } else{
                collectionView.isUserInteractionEnabled = true
                let touchPoint = gesture.location(in: collectionView)
                guard let indexPath = collectionView.indexPathForItem(at: touchPoint) else { return }
                
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
    
    @objc private func didTapShare(){
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc,animated: true)
    }
}


extension PlaylistViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCell.identifier, for: indexPath) as?  RecommendedTracksCell else { return UICollectionViewCell()}
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else  { return  UICollectionReusableView()}
        
        let headerViewModel = PlaylistHeaderViewModel(playlistName: playlist.name,
                                                      ownerName: playlist.owner.display_name,
                                                      description: playlist.description,
                                                      artworkURL: URL(string: playlist.images.first?.url ?? ""))
        header.configure(with: headerViewModel)
        
        header.delegate = self
       return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let index = indexPath.row
        PlayerPresenter.shared.startPlayback(from: self,tracks: tracks,index: index)
    }
}

extension PlaylistViewController : PlaylistHeaderCollectionReusableViewDelegate{
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(header: PlaylistHeaderCollectionReusableView) {
        PlayerPresenter.shared.startPlayback(from: self, tracks: tracks, index: 0)
        
    }
}
