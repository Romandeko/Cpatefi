//
//  LibraryAlbumViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 16.02.23.
//

import UIKit

class LibraryAlbumViewController: UIViewController {
    
    // MARK: - Properties
    var albums = [Album]()
    lazy var collectionView : UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout{sectionIndex, _ -> NSCollectionLayoutSection? in
            return LibraryPlaylistsViewController.createSectionLayout()
        }
    )
    
    // MARK: - Private Properties
    private let noAlbumsView = ActionLabelView()
    
    private var observer : NSObjectProtocol?
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .systemBackground
        setUpNoAlbumsView()
        setUpCollectionView()
        fetchData()
        updateUI()
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification, object: nil, queue: nil){[weak self] _ in
            self?.fetchData()
            
        }
        addLongTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width-150)/2, y: (view.height-150)/2, width: 150, height: 150)
        collectionView.frame = view.bounds
    }
    
    // MARK: - Private Methods
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
    private func setUpNoAlbumsView(){
        view.addSubview(noAlbumsView)
        noAlbumsView.delegeate = self
        noAlbumsView.configure(with: ActionLabelViewModel(text: "You don't have any albums yet", actionTitel: "Browse"))
    }
    
    private func setUpCollectionView(){
        collectionView.register(LibraryAlbumCollectionViewCell.self,forCellWithReuseIdentifier: LibraryAlbumCollectionViewCell.identitier)
        collectionView.isHidden = true
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
    }
    
    private func addLongTapGesture(){
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func longPress(_ gesture : UILongPressGestureRecognizer){
        guard gesture.state == .began else { return }
        
        collectionView.isUserInteractionEnabled = true
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint)else { return }
        
        let model = albums[indexPath.row]
        let actionSheet = UIAlertController(title: model.name, message: "Would you like to remove?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .default){[weak self] _ in
            guard let strongSelf = self else {return}
            APICaller.shared.deleteAlbum(album: model){ success in
                if success{
                    DispatchQueue.main.async {
                        strongSelf.albums.remove(at: indexPath.row)
                        strongSelf.collectionView.reloadData()
                    }
                }
                
            }
        })
        present(actionSheet,animated: true)
    }
    
    private func fetchData(){
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums{ [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let albums):
                    self?.albums = albums
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func updateUI(){
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            collectionView.isHidden = true
        } else {
            collectionView.reloadData()
            noAlbumsView.isHidden = true
            collectionView.isHidden = false
        }
    }
}

// MARK: - Extensions
extension LibraryAlbumViewController : ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryAlbumCollectionViewCell.identitier,for: indexPath) as? LibraryAlbumCollectionViewCell else { return UICollectionViewCell()}
        
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name, subtitle: album.artists.first?.name ?? "-", imageURL: URL(string: album.images.first?.url ?? "")))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        let album = albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        vc.isOwner = true
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
