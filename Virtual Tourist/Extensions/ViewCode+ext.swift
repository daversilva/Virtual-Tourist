//
//  ViewCode+ext.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 24/03/19.
//  Copyright © 2019 David Rodrigues. All rights reserved.
//

import Foundation

protocol CodeView {
    func buildViewHierachy()
    func setupConstraints()
    func setupAdditionalConfiguration()
    func setupCodeView()
}

extension CodeView {
    func setupCodeView() {
        buildViewHierachy()
        setupConstraints()
        setupAdditionalConfiguration()
    }
}
