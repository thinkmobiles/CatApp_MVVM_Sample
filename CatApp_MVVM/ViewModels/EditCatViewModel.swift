//
//  EditCatViewModel.swift
//
//  Created by R. Fogash, V. Ahosta
//  Copyright (c) 2017 Thinkmobiles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import Bond
import Photos

final class EditCatViewModel: EditCatViewModelProtocol {

    private(set) var image: Observable<UIImage?>
    private(set) var isProcessing: Observable<Bool> = Observable(false)

    var numberOfFilterSamples: Int {
        return filterSamples.count
    }

    var onUpdateFilterSample: ((_ index: Int) -> Void)?
    var onDismiss: (() -> Void)?
    var onShowMessage: ((_ title: String?, _ message: String?, _ completion: (() -> Void)?) -> Void)?

    private let cat: Cat
    private lazy var filterSamples: [UIImage] = {
        let image = UIImage(named: Constants.sampleImageName)!
        return Array(repeating: image, count: Constants.filterNames.count)
    }()
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = Constants.maxConcurentOperationsCount
        return queue
    }()
    private var currentOperation: FilterOperation?
    private lazy var appName: String? = {
        Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }()

    init(cat: Cat) {
        self.cat = cat
        if let imageData = cat.imageData {
            image = Observable(UIImage(data: imageData))
        } else {
            image = Observable(nil)
        }
    }

    func filterSample(at index: Int) -> UIImage {
        return filterSamples[index]
    }

    func applyFilter(at index: Int) {
        guard let imageData = cat.imageData else { return }
        guard let filter = CIFilter(name: Constants.filterNames[index]) else { return }
        if let currentOperation = currentOperation {
            currentOperation.cancel()
        }
        isProcessing.value = true
        let operation = FilterOperation(filter: filter, inputImageData: imageData)
        operation.completionBlock = { [weak self, weak operation] in
            guard let strongSelf = self, let outputImage = operation?.outputImage else { return }
            DispatchQueue.main.async {
                strongSelf.image.value = outputImage
                strongSelf.isProcessing.value = false
            }
        }
        operationQueue.addOperation(operation)
        currentOperation = operation
    }

    func save() {
        guard let image = image.value else { return }
        hasAccessToPhotoLibrary { [weak self] (hasAccess, error) in
            guard let strongSelf = self else { return }
            if hasAccess {
                strongSelf.saveToPhotoLibrary(image: image) { success in
                    if success {
                        strongSelf.onShowMessage?(strongSelf.appName, Constants.saveImageSuccessMessage) {
                            strongSelf.onDismiss?()
                        }
                    } else {
                        strongSelf.onShowMessage?(strongSelf.appName, Error.failedToSaveImage.description, nil)
                    }
                }
            } else if let error = error {
                strongSelf.onShowMessage?(strongSelf.appName, error.description, nil)
            }
        }
    }

    func cancel() {
        operationQueue.cancelAllOperations()
        onDismiss?()
    }

    func createFilterSamples() {
        for (index, name) in Constants.filterNames.enumerated() {
            guard let filter = CIFilter(name: name), let imageData = UIImagePNGRepresentation(filterSamples[index]) else { break }
            let operation = FilterOperation(filter: filter, inputImageData: imageData)
            operation.completionBlock = { [weak self, weak operation] in
                guard let stronSelf = self, let outputImage = operation?.outputImage else { return }
                DispatchQueue.main.async {
                    stronSelf.filterSamples[index] = outputImage
                    stronSelf.onUpdateFilterSample?(index)
                }
            }
            operationQueue.addOperation(operation)
        }
    }

    private func hasAccessToPhotoLibrary(completion: @escaping (_ hasAccess: Bool, _ error: Error?) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true, nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] _ in
                self?.hasAccessToPhotoLibrary(completion: completion)
            }
        case .denied:
            completion(false, .photoLibraryAccessDenied)
        case .restricted:
            completion(false, .photoLibraryAccessRestricted)
        }
    }

    private func saveToPhotoLibrary(image: UIImage, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCreationRequest.creationRequestForAsset(from: image)
        }) { (success, error) in
            completion(success)
        }
    }

}

extension EditCatViewModel {

    enum Error {
        case photoLibraryAccessRestricted
        case photoLibraryAccessDenied
        case failedToSaveImage
    }

    enum Constants {
        static let filterNames = ["CIPhotoEffectMono", "CISepiaTone", "CIColorInvert", "CIPhotoEffectChrome",
                                  "CIPhotoEffectTransfer", "CIPhotoEffectProcess", "CIPhotoEffectNoir",
                                  "CIPhotoEffectInstant", "CIPhotoEffectFade"]
        static let maxConcurentOperationsCount = 5
        static let sampleImageName = "CatFace"
        static let saveImageSuccessMessage = "The image was saved successfully"
    }

}

extension EditCatViewModel.Error: CustomStringConvertible {

    var description: String {
        switch self {
        case .photoLibraryAccessRestricted: return "Access to the photos library is restricted"
        case .photoLibraryAccessDenied: return "Access to the photos library is denied"
        case .failedToSaveImage: return "Failed to save the image"
        }
    }
}
