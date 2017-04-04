//
//  LoadCatViewModel.swift
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

final class LoadCatViewModel: LoadCatViewModelProtocol {

    private(set) var isLoading: Observable<Bool> = Observable(false)
    private(set) var isEditable: Observable<Bool> = Observable(false)
    private(set) var title: Observable<String?> = Observable(nil)
    private(set) var imageData: Observable<Data?> = Observable(nil)

    var editCatViewModel: EditCatViewModelProtocol? {
        guard let cat = cat else { return nil }
        return EditCatViewModel(cat: cat)
    }

    private var error: CatLoadingError? {
        didSet {
            guard let error = error else { return }
            title.value = error == .cancelled ? ErrorMessages.cancelled : ErrorMessages.loadingError
        }
    }
    private var catProvider: CatProvider
    private var cat: Cat?

    init(catProvider: CatProvider) {
        self.catProvider = catProvider
    }

    func loadNextCat() {
        isLoading.value = true
        isEditable.value = false
        title.value = nil
        imageData.value = nil
        error = nil
        catProvider.createNewCat { [weak self] (cat, success, error) in
            guard let strongSelf = self else { return }
            if let cat = cat {
                strongSelf.cat = cat
                strongSelf.title.value = cat.imageURL.absoluteString
                cat.loadImage(complation: { (image, success, error) in
                    strongSelf.imageData.value = image
                    strongSelf.error = error
                    strongSelf.isLoading.value = false
                    strongSelf.isEditable.value = success
                })
            } else {
                strongSelf.error = error
                strongSelf.isLoading.value = false
            }
        }
    }

    func cancelCurrentDownloading() {
        if catProvider.isLoading {
            catProvider.cancel()
        } else {
            cat?.cancel()
        }
    }

}

extension LoadCatViewModel {

    enum ErrorMessages {
        static let loadingError = "LoadingError"
        static let cancelled = "Cancelled"
    }

}
