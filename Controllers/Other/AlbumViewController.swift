//
//  AlbumViewController.swift
//  Spotify
//
//  Created by Hung Truong on 21/04/2024.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let colletionView = UICollectionView(
         frame: .zero,
         collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
             let item = NSCollectionLayoutItem(
                 layoutSize: NSCollectionLayoutSize(
                     widthDimension: .fractionalWidth(1.0),
                     heightDimension: .fractionalHeight(1.0)
                 )
             )
             
             item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
             
             let group = NSCollectionLayoutGroup.vertical(
                 layoutSize: NSCollectionLayoutSize(
                     widthDimension: .fractionalWidth(1),
                     heightDimension: .absolute(60)
                 ),
                 subitem: item,
                 count: 1
             )
             let section = NSCollectionLayoutSection(group: group)
             section.boundarySupplementaryItems = [
                 NSCollectionLayoutBoundarySupplementaryItem(
                     layoutSize: NSCollectionLayoutSize(
                         widthDimension: .fractionalWidth(1),
                         heightDimension: .fractionalWidth(1)
                     ),
                     elementKind: UICollectionView.elementKindSectionHeader,
                     alignment: .top)
             ]
             return section
         })
     )
     
    private var viewModels = [AlbumCollectionViewCellViewModel]()
    
    private var tracks = [AudioTrack]()
    
    private let album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        view.addSubview(colletionView)
        colletionView.register(
            PlaylistHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier
        )
        colletionView.register(
            AlbumTrackColletionViewCell.self,
            forCellWithReuseIdentifier: AlbumTrackColletionViewCell.identifier
        )
        colletionView.backgroundColor = .systemBackground
        colletionView.delegate = self
        colletionView.dataSource = self
        
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case.success(let model):
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap({
                        AlbumCollectionViewCellViewModel(
                            name: $0.name,
                            artistName: $0.artists.first?.name ?? "-",
                            artworkURL: URL(string: self?.album.images.first?.url ?? "")
                        )
                    })
                    self?.colletionView.reloadData()
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        colletionView.frame = view.bounds
    }
}

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AlbumTrackColletionViewCell.identifier,
            for: indexPath
        ) as? AlbumTrackColletionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier,
            for: indexPath
        ) as? PlaylistHeaderCollectionReusableView,
          kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewViewModel(
            name: album.name,
            ownerName: album.artists.first?.name,
            description: "Ngày phát hành: \(String.formatteDate(string: album.release_date))",
            artworkURL: URL(string: album.images.first?.url ?? "")
        )
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        var track = tracks[indexPath.row]
        track.album = self.album
        PlaybackPresenter.shared.startPlayback(from: self, track: track)
    }
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let trackWithAlbum: [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = self.album
            return track
        })
        PlaybackPresenter.shared.playMultipleTracks(from: self, tracks: trackWithAlbum)
    }
}
