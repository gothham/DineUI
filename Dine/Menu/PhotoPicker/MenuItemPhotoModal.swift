//
//  MenuItemPhotoModal.swift
//  Dine
//
//  Created by doss-zstch1212 on 28/06/24.
//

import SwiftUI
import PhotosUI
import CoreTransferable

@MainActor
class MenuItemPhotoModal: ObservableObject {
    enum ImageState {
        case empty
        case loading(Progress)
        case success(Image)
        case failure(Error)
    }

    enum TransferError: Error {
        case importFailed
    }
    
    struct ItemImage: Transferable {
        let image: Image
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                let image = Image(uiImage: uiImage)
                return ItemImage(image: image)
            }
        }
    }
    
    @Published private(set) var imageState: ImageState = .empty
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .empty
            }
        }
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ItemImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let itemImage?):
                    self.imageState = .success(itemImage.image)
                case .failure(let error):
                    self.imageState = .failure(error)
                case .success(nil):
                    self.imageState = .empty
                }
            }
        }
    }
}
