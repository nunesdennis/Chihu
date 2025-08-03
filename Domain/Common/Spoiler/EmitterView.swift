//
//  EmitterView.swift
//  Chihu
//
//  Created by Dennis Nunes on 19/03/25.
//

import UIKit

final class EmitterView: UIView {

    override class var layerClass: AnyClass {
        CAEmitterLayer.self
    }

    override var layer: CAEmitterLayer {
        super.layer as! CAEmitterLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = .init(x: bounds.size.width / 2,
                                      y: bounds.size.height / 2)
        layer.emitterSize = bounds.size
    }
}
