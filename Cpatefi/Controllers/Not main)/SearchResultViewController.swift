//
//  SearchResultViewController.swift
//  Cpatefi
//
//  Created by Роман Денисенко on 18.12.22.
//

import UIKit

struct SearchSection{
    let title : String
    let results : [SearchResult]
}

protocol SearchResultViewControllerDelegate : AnyObject {
    func didTapResult(_ result: SearchResult)
}

class SearchResultViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: - Weak Properties
    weak var delegate : SearchResultViewControllerDelegate?
    
    // MARK: - Private Properties
    private var sections: [SearchSection] = []
    
    private var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefauldTableViewCell.self, forCellReuseIdentifier: SearchResultDefauldTableViewCell.identitier)
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identitier)
        tableView.backgroundColor = .systemBackground
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Methods
    func update(with results: [SearchResult]){
        let artists = results.filter({
            switch $0 {
            case .artist : return true
            default : return false
        }
    })
        let albums = results.filter({
            switch $0 {
            case .album : return true
            default : return false
        }
    })
        let tracks = results.filter({
            switch $0 {
            case .track : return true
            default : return false
        }
    })
        let playlists = results.filter({
            switch $0 {
            case .playlist : return true
            default : return false
        }
    })
        self.sections =  [
            SearchSection(title: "Songs", results: tracks),
            SearchSection(title: "Artist", results: artists),
            SearchSection(title: "Playlists", results: playlists),
            SearchSection(title: "Albums", results: albums)
        ]
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
    }
    
    // MARK: - Estension Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        
        switch result{
        case .artist(let artist) :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefauldTableViewCell.identitier, for: indexPath) as? SearchResultDefauldTableViewCell else { return UITableViewCell()}
            let viewModel = SearchResultDefauldTableViewCellViewModel(title:artist.name , imageURL: URL(string : artist.images?.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .album(let album) :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identitier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell()}
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: album.name , subtitle: album.artists.first?.name ?? "-",imageURL: URL(string : album.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .track(let track) :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identitier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell()}
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: track.name , subtitle: track.artists.first?.name ?? "-",imageURL: URL(string : track.album?.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .playlist(let playlist) :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identitier, for: indexPath) as? SearchResultSubtitleTableViewCell else { return UITableViewCell()}
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: playlist.name , subtitle: playlist.owner.display_name ,imageURL: URL(string : playlist.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
