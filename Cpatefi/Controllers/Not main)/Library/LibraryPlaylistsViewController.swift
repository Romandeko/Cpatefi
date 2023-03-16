//
//  LibraryPlaylistsViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 16.02.23.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {

    // MARK: - Properties
    var playlists = [Playlist]()
    public var selectionHandler : ((Playlist) -> Void)?
    private let noPlaylistsView = ActionLabelView()
    lazy var collectionView : UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout{sectionIndex, _ -> NSCollectionLayoutSection? in
            return LibraryPlaylistsViewController.createSectionLayout()
         }
    )
      
    // MARK: - Override Methods
    override func viewDidLoad() {
        overrideUserInterfaceStyle = .dark
        super.viewDidLoad()
        collectionView.register(LibraryPlaylistCollectionViewCell.self,forCellWithReuseIdentifier: LibraryPlaylistCollectionViewCell.identitier)
        collectionView.isHidden = true
        view.backgroundColor = .systemBackground
        setUpNoPlaylistsView()
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        fetchData()
        updateUI()
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistsView.center = view.center
        collectionView.frame = view.bounds
    }
    // MARK: - Private Methods
    @objc private func didTapClose(){
        dismiss(animated: true)
    }
    
    private func setUpNoPlaylistsView(){
        view.addSubview(noPlaylistsView)
        noPlaylistsView.delegeate = self
        noPlaylistsView.configure(with: ActionLabelViewModel(text: "You don't have any playlists yet", actionTitel: "Create"))
    }
    
    private func fetchData(){
        APICaller.shared.getCurrentUserPlaylists{ [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func updateUI(){
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
            collectionView.isHidden = true
        } else {
            noPlaylistsView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
        
    }
    // MARK: - Public Methods
    public func showCreatePlaylistAlert(){
        let alert = UIAlertController(title: "New playlist", message: "Enter playlist name", preferredStyle: .alert)
        alert.addTextField{ textfield in
            textfield.placeholder = "Playlist..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default){_ in
            guard let field = alert.textFields?.first, let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            
            APICaller.shared.createPlaylist(with: text){ [weak self] success in
                if success{
                    HapticsManager.shared.vibrate(for: .success)
                    self?.fetchData()
                } else {
                    HapticsManager.shared.vibrate(for: .error)
                }
            }
        })
        present(alert,animated:  true)
    }
}

// MARK: - Extensions
extension LibraryPlaylistsViewController : ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
       showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistsViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LibraryPlaylistCollectionViewCell.identitier,for: indexPath) as? LibraryPlaylistCollectionViewCell else { return UICollectionViewCell()}
          
          let playlist = playlists[indexPath.row]
          cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subtitle: playlist.owner.display_name, imageURL: URL(string: playlist.images.first?.url ?? "")))
          
          return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        let playlist = playlists[indexPath.row]
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
       
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isOwner = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    static func createSectionLayout() -> NSCollectionLayoutSection{
       let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(10)) , elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
     
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(
             layoutSize: NSCollectionLayoutSize(
                 widthDimension: .absolute(200),
                 heightDimension: .absolute(400)
             ),
             subitem: item,
             count: 1
         )
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                    heightDimension: .absolute(400)
                ),
                subitem: horizontalGroup, count: 2
              
            )
     
            let section = NSCollectionLayoutSection(group: verticalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }

