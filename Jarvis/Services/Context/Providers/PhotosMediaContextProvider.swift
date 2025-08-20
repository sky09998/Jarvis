//
//  PhotosMediaContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import Photos
import MediaPlayer

final class PhotosMediaContextProvider: ContextProvider {
    let name: String = "media"

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        var mediaSummary: [String: Any] = [:]

        // Photos (count only, limited-friendly)
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                mediaSummary["photosCount"] = assets.count
            }

            // Apple Music library permission (count of songs)
            MPMediaLibrary.requestAuthorization { status in
                if status == .authorized {
                    let songsQuery = MPMediaQuery.songs()
                    mediaSummary["songsCount"] = songsQuery.items?.count ?? 0
                }
                completion(mediaSummary)
            }
        }
    }
}


