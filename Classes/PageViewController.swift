//
//  PageViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 3/29/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit

class PageViewController : UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [PageViewController.self])

        pageControl.pageIndicatorTintColor = UIColor(red: 55.0/255.0, green: 255.0/255.0, blue: 119.0/255.0, alpha: 0.4)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 55.0/255.0, green: 255.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    }

}
