//
//  ViewController.swift
//  LN_FlipView
//
//  Created by mxc235 on 2019/9/18.
//  Copyright © 2019 Lncir. All rights reserved.
//

import UIKit

class ViewController: UIViewController,LN_FlipViewProtocol {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let firstVC = FirstViewController.init()
        let secondVC = SecondViewController.init()
        let thirdVC = ThirdViewController.init()
        let fourthVC = FourthViewController.init()
        let fifthVc = FifthViewController.init()
        
        let titles = ["firstVC","secondVC","thirdVC","fourthVC","fifthVC"]
        let vcs = [firstVC,secondVC,thirdVC,fourthVC,fifthVc]
        
        for i in 0..<vcs.count {
            let vc = vcs[i]
            let title = titles[i]
            
            let label = UILabel.init(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: 60))
            label.text = title
            label.textColor = .white
            label.textAlignment = .center
            vc.view.backgroundColor = .gray
            vc.view.addSubview(label)
        }
        
        let flipView = LN_FlipView.init(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height), viewControllers: vcs, titles: titles)
        flipView.delegate = self as LN_FlipViewProtocol
        self.view.addSubview(flipView)
        
    }
    func flipView(flipView: LN_FlipView, didSelectSegment index: Int) {
        print(index)
    }
}

