//
//  ViewController.swift
//  HomeKitParty
//
//  Created by Finn Gaida on 29.06.18.
//  Copyright © 2018 Finn Gaida. All rights reserved.
//

import UIKit
import HomeKit

class ViewController: UIViewController, HMHomeManagerDelegate {

    let manager: HMHomeManager = HMHomeManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
    }

    @IBAction func startParty() {
        let lights = getHueLights()
        var values = Array(repeating: 0, count: lights.count)
        for (i, light) in lights.enumerated() {
            _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                let newVal = (values[i] + 20) % 360
                light.writeValue(newVal, completionHandler: { error in if let e = error { print("Couldn't set value \(newVal) on \(light.localizedDescription): \(e)") } })
                values[i] = newVal
                self?.updateBackground(with: newVal)
            }
        }
    }

    func updateBackground(with hue: Int) {
        let color = UIColor(hue: CGFloat(hue + 10) / 360, saturation: 1, brightness: 1, alpha: 1)

        UIView.animate(withDuration: 1) {
            self.view.backgroundColor = color
        }
    }

    private func getHueLights() -> [HMCharacteristic] {
        // get home
        guard let home = manager.primaryHome else { return [] }

        // loop accessories home
        return Array(home.accessories.compactMap({ accessory -> [[HMCharacteristic]] in
            return accessory.services.compactMap { service in
                service.characteristics.filter { $0.characteristicType == HMCharacteristicTypeHue }
            }
        }).joined().joined())
    }

}

