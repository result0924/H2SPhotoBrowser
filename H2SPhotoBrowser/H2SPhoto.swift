//
//  H2SPhoto.swift
//  H2SPhotoBrowser
//
//  Created by Justin Lai on 2023/11/27.
//

import Foundation
import SDWebImage

open class H2SPhoto: NSObject {
    
    // Progress download block, used to update the circularView
    public typealias H2SPhotoProgressUpdateBlock = (CGFloat) -> Void

    // Properties
    open var progressUpdateBlock: H2SPhotoProgressUpdateBlock?
    private var caption: String?
    private var photoURL: URL?
    private var photoPath: String?
    private var placeholderImage: UIImage?
    private var loadingInProgress = false
    
    // Class
    open class func photo(with image: UIImage?) -> H2SPhoto {
        return H2SPhoto(image: image)
    }

    open class func photo(withFilePath path: String) -> H2SPhoto {
        return H2SPhoto(filePath: path)
    }

    open class func photo(withURL url: URL) -> H2SPhoto {
        return H2SPhoto(url: url)
    }

    open class func photos(with imagesArray: [UIImage]) -> [H2SPhoto] {
        return imagesArray.map { H2SPhoto.photo(with: $0) }
    }

    open class func photos(withFilePaths pathsArray: [String]) -> [H2SPhoto] {
        return pathsArray.map { H2SPhoto.photo(withFilePath: $0) }
    }

    open class func photos(withURLs urlsArray: [URL]) -> [H2SPhoto] {
        return urlsArray.map { H2SPhoto.photo(withURL: $0) }
    }

    // Init
    init(image: UIImage?) {
        self.underlyingImage = image
        super.init()
    }

    init(filePath path: String) {
        self.photoPath = path
        super.init()
    }

    init(url: URL) {
        self.photoURL = url
        super.init()
    }
    
    var underlyingImage: UIImage?

    func loadUnderlyingImageAndNotify() {
        
        loadingInProgress = true
        
        if underlyingImage != nil {
            // Image already loaded
            imageLoadingComplete()
        } else {
            if let photoPath = self.photoPath {
                underlyingImage = UIImage(contentsOfFile: photoPath)
                imageLoadingComplete()
            } else if let photoURL = self.photoURL {
                SDWebImageManager.shared()?.downloadImage(with: photoURL, options: [.retryFailed, .handleCookies], progress: { [weak self] receivedSize, expectedSize in
                    guard let self = self else { return }
                    let progress = CGFloat(receivedSize) / CGFloat(expectedSize)
                    self.progressUpdateBlock?(progress)
                }) { [weak self] image, _, _, _, _ in
                    guard let self = self else { return }
                    if let image = image {
                        self.underlyingImage = image
                        self.imageLoadingComplete()
                    }
                }
            } else {
                underlyingImage = nil
                imageLoadingComplete()
            }
        }
    }

    // Called on main
    private func imageLoadingComplete() {
        // Complete so notify
        loadingInProgress = false
        // TODO: need notify image load complete
    }
}
