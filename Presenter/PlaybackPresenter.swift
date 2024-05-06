//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Hung Truong on 28/04/2024.
//
import AVFoundation
import UIKit

struct PlayingItem {
    let trackData: AudioTrack
    let avPlayerItem: AVPlayerItem
}

enum PlayerInputData {
    
    case searchTrackItem(viewController: UIViewController, data: [SearchTracksResponse])
    case audioTrack(viewController: UIViewController, data: [AudioTrack], albumImage: String)
    case playlistTrackItem(viewController: UIViewController, data: [PlaylistTracksResponse])
}

protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    
    private var isMultipleTrackPlayback = false
    
    private var playerVC: PlayerViewController?
    
    private var player: AVPlayer?
    
    private var currentPlayingTrack: AudioTrack?
    
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    private var currentPlayingItem: PlayingItem? {
        guard let index = currentTrackIndex else {
            return nil
        }
        return playingItems[index]
    }
    private var playingItems: [PlayingItem] = []
    
    private var numberOfTracks: Int { playingItems.count }
    private var currentTrackIndex: Int?
    
    private var playerIsPlaying: Bool {
        guard let trackPlayer = player else { return false}
        if trackPlayer.timeControlStatus == .playing { return true }
        else { return false }
    }
    
    func playTracks() { // func startPlayback cua track: AudioTrack
        guard let currentPlayingItem = currentPlayingItem else { return }
        player = AVPlayer(playerItem: currentPlayingItem.avPlayerItem)
        player?.volume = 1.0
        player?.play()
    }
    func prepareTracks(tracks: [AudioTrack]) -> Bool {
        if playerIsPlaying { player?.pause() }
        self.playingItems.removeAll()
        
        var playingItems: [PlayingItem] = []
        
        for track in tracks {
            guard let urlString = track.preview_url, let url = URL(string: urlString), urlString != "" else { continue }
            let avPlayerItem = AVPlayerItem(url: url)
            let playingItem = PlayingItem(trackData: track, avPlayerItem: avPlayerItem)
            playingItems.append(playingItem)
        }
        
        self.playingItems = playingItems
        if self.playingItems.isEmpty {
            currentTrackIndex = nil
            return false
        }
        else {
            currentTrackIndex = 0
            return true
        }
    }
    func playMultipleTracks(from viewController: UIViewController, tracks: [AudioTrack]) {
        if prepareTracks(tracks: tracks) {
            self.tracks = tracks
            self.track = nil
            playTracks()
            let vc = PlayerViewController()
            vc.dataSource = self
            vc.delegate = self
            vc.title = currentPlayingItem?.trackData.name
            viewController.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            self.playerVC = vc
        }
        else {
            
        }
    }
    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        guard let urlString = track.preview_url, let url = URL(string: urlString), urlString != "" else {
            return print("Bài hát \(track.name) không có url để phát")
        }
        player = AVPlayer(url: url)
        player?.volume = 1.0 // POINT
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC?.refreshUI()
        self.playerVC = vc
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    
    func didTapPlayPause() {
        guard let track = player else { return }
        if playerIsPlaying { track.pause() }
        else { track.play() }
    }
    
    func didTapForward() {
        if playerIsPlaying { player?.pause() }
        guard let index = currentTrackIndex else { return }
        if index > 0 {
            currentTrackIndex! -= 1
            player?.replaceCurrentItem(with: currentPlayingItem?.avPlayerItem)
            player?.play()
            playerVC?.refreshUI()
        }
        else { player?.play() }
    }
    
    func didTapBackward() {
        if playerIsPlaying { player?.pause() }
        guard let index = currentTrackIndex else {
            return
        }
        if index < numberOfTracks - 1 {
            currentTrackIndex! += 1
            player?.replaceCurrentItem(with: currentPlayingItem?.avPlayerItem)
            player?.play()
            playerVC?.refreshUI()
        }
        else { player?.play() }
    }
    
    func didSlideSlider(_ value: Float) {
        guard let track = player else { return }
        track.volume = value
    }
}

extension PlaybackPresenter: PlayerDataSource {
    var songName: String? {
        return currentPlayingItem?.trackData.name
    }
    
    var subtitle: String? {
        return currentPlayingItem?.trackData.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentPlayingItem?.trackData.album?.images.first?.url ?? "")
    }
}
