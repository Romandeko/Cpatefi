//
//  AlbumViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 9.01.23.
//

import UIKit

class AlbumViewController: UIViewController {
    
    // MARK: - Properties
    var isOwner = false
    
    // MARK: - Private properties
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider:
                                                                    { _, _ -> NSCollectionLayoutSection? in
            
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
    
    private let album : Album

    init(album : Album){
        self.album = album
        super.init(nibName : nil,bundle: nil)
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    private var viewModels = [AlbumCollectionViewCellViewViewModel]()
    private var tracks = [AudioTrack]()
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        title = album.name
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.register(AlbumTrackCollectionViewCell.self, forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
       fetchData()
        if !isOwner{ navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
        }
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
    
    @objc private func longPress(_ gesture : UILongPressGestureRecognizer){
        guard gesture.state == .began else { return }
        
        collectionView.isUserInteractionEnabled = true
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint)else { return }
        
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
    
    @objc private func didTapAction(){
        let actionSheet = UIAlertController(title: album.name, message: "Actions", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Save", style: .default){[weak self] _ in
            guard let strongSelf = self else  { return }
            APICaller.shared.saveAlbum(album: strongSelf.album){ success in
                if success{
                    HapticsManager.shared.vibrate(for: .success)
                    NotificationCenter.default.post(name: .albumSavedNotification, object: nil)
                } 
            }
        })
        
        present(actionSheet,animated: true)
    }
    
    private func fetchData(){
        APICaller.shared.getAlbumDetails(for: album){[weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let model):
                    self?.tracks = model.tracks.items
                   self?.viewModels = model.tracks.items.compactMap({
                       AlbumCollectionViewCellViewViewModel(name: $0.name,
                                                      artistName: $0.artists.first?.name ?? "-")
                      
                })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

// MARK: - Extensions
extension AlbumViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as?  AlbumTrackCollectionViewCell else { return UICollectionViewCell()}
        guard let url = URL(string: album.images.first?.url ?? "") else  { return UICollectionViewCell()}
        cell.configure(with: viewModels[indexPath.row],url: url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else  { return  UICollectionReusableView()}
        
        let headerViewModel = PlaylistHeaderViewModel(playlistName: album.name,
                                                      ownerName: album.artists.first?.name,
                                                      description: "Release Date : \(String.formattedDate(string: album.release_date))",
                                                      artworkURL: URL(string: album.images.first?.url ?? ""))
        header.configure(with: headerViewModel)
        
        header.delegate = self
       return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let tracksWithAlbum : [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = self.album
            
            return track
        })
        guard URL(string: tracks[indexPath.row].preview_url ?? "") != nil else {
            let alert = UIAlertController(title: "Sorry", message: "This song isn't available in your country", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert,animated : true)
            return
        }
        PlayerPresenter.shared.startPlayback(from: self,  tracks: tracksWithAlbum, index: indexPath.row)
    }
}

extension AlbumViewController : PlaylistHeaderCollectionReusableViewDelegate{
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(header: PlaylistHeaderCollectionReusableView) {
        let tracksWithAlbum : [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = self.album
            
            return track
        })
        for i in 0..<tracksWithAlbum.count{
            if tracksWithAlbum[i].preview_url != nil{
                PlayerPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum, index: i)
                break
            }
        }
    }
}
