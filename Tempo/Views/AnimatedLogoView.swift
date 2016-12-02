//
//  AnimatedLogoView.swift
//  AnimatedLogo
//
//  Created by Dennis Fedorko on 11/18/16.
//  Copyright © 2016 org.cuappdev. All rights reserved.
//

import UIKit

enum LogoStyle {
    case dark, light, refresh
}

class AnimatedLogoView: UIView {
    
    var backgroundView: UIView!
    var foregroundView: UIView!

    var circleView: UIView!
    var bars = [UIView]()

    var foregroundGradientColors = [UIColor]()
    var backgroundGradientColors = [UIColor]()
    
    var shouldStopAnimating = false
    var isAnimating = false
    
    init(frame: CGRect, style: LogoStyle, showsCircle: Bool, showsBackground: Bool) {
        super.init(frame: frame)
        
        switch style {
            case .light:
                foregroundGradientColors = [UIColor(red: 15/255.0, green: 23/255.0, blue: 42/255.0, alpha: 1.0),
                                            UIColor(red: 52/255.0, green: 33/255.0, blue: 50/255.0, alpha: 1.0)]
                backgroundGradientColors = [UIColor(red: 176/255.0, green: 75/255.0, blue: 64/255.0, alpha: 1.0),
                                            UIColor(red: 141/255.0, green: 31/255.0, blue: 65/255.0, alpha: 1.0)]
            case .dark:
                foregroundGradientColors = [UIColor(red: 176/255.0, green: 75/255.0, blue: 64/255.0, alpha: 1.0),
                                            UIColor(red: 141/255.0, green: 31/255.0, blue: 65/255.0, alpha: 1.0)]
                backgroundGradientColors = [UIColor(red: 41/255.0, green: 36/255.0, blue: 36/255.0, alpha: 1.0),
                                            UIColor(red: 41/255.0, green: 36/255.0, blue: 36/255.0, alpha: 1.0)]
			
			case .refresh:
				foregroundGradientColors = [UIColor.tempoLightRed, UIColor.tempoLightRed]
				backgroundGradientColors = [UIColor(red: 41/255.0, green: 36/255.0, blue: 36/255.0, alpha: 1.0),
			                            UIColor(red: 41/255.0, green: 36/255.0, blue: 36/255.0, alpha: 1.0)]
        }
		
        clipsToBounds = true
        layer.cornerRadius = 0.1953125 * frame.width
        
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = backgroundView.frame
        backgroundGradient.colors = [backgroundGradientColors[0].cgColor,
                                     backgroundGradientColors[1].cgColor]
        backgroundView.layer.insertSublayer(backgroundGradient, at: 0)
        
        if showsBackground {
            addSubview(backgroundView)
        }
        
        foregroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        foregroundView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        let foregroundGradient = CAGradientLayer()
        foregroundGradient.frame = foregroundView.frame
        foregroundGradient.colors = [foregroundGradientColors[0].cgColor,
                                     foregroundGradientColors[1].cgColor]
        foregroundView.layer.insertSublayer(foregroundGradient, at: 0)
        addSubview(foregroundView)
        
        let foregroundMaskView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))

        circleView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width * 0.625, height: frame.width * 0.625))
        circleView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        circleView.layer.cornerRadius = circleView.frame.width / 2.0
        circleView.layer.borderWidth = frame.width * 0.046875
        circleView.layer.borderColor = UIColor.black.cgColor
        if showsCircle {
            foregroundMaskView.addSubview(circleView)
        }
        
        let barWidth = 0.04408203125 * frame.width
        let barRadius = 0.017578125 * frame.width
        let barSpacing = 0.023515625 * frame.width
        
        let bar1 = UIView(frame: CGRect(x: 0, y: 0, width: barWidth, height: 0.06724609375 * frame.width))
        let bar2 = UIView(frame: CGRect(x: 0, y: 0, width: barWidth, height: 0.1425585938 * frame.width))
        let bar3 = UIView(frame: CGRect(x: 0, y: 0, width: barWidth, height: 0.271484375 * frame.width))
        let bar4 = UIView(frame: CGRect(x: 0, y: 0, width: barWidth, height: 0.113203125 * frame.width))
        let bar5 = UIView(frame: CGRect(x: 0, y: 0, width: barWidth, height: 0.05501953125 * frame.width))
        
        bar3.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
        bar2.center = CGPoint(x: bar3.center.x - barWidth - barSpacing, y: frame.height / 2.0 + -0.02043945313 * frame.width)
        bar1.center = CGPoint(x: bar2.center.x - barWidth - barSpacing, y: frame.height / 2.0 + 0.005029296875 * frame.width)
        bar4.center = CGPoint(x: bar3.center.x + barWidth + barSpacing, y: frame.height / 2.0 + 0.01771484375 * frame.width)
        bar5.center = CGPoint(x: bar4.center.x + barWidth + barSpacing, y: frame.height / 2.0 + 0.01502929688 * frame.width)
        
        bars = [bar1, bar2, bar3, bar4, bar5]
        
        for bar in bars {
            bar.layer.cornerRadius = CGFloat(barRadius)
            bar.clipsToBounds = true
            bar.backgroundColor = UIColor.black
            foregroundMaskView.addSubview(bar)
        }
        
        foregroundView.mask = foregroundMaskView
    }
    
    func animateBar(index: Int, withDelay delay: Double, completion: (() -> ())?) {
        let bar = bars[index]
        let originalBarCenter = bar.center
        UIView.animate(withDuration: 0.30, delay: delay, options: .curveEaseIn, animations: {
            bar.center = CGPoint(x: bar.center.x, y: originalBarCenter.y - self.frame.height * 0.04)
        }, completion: { _ in
            UIView.animate(withDuration: 0.50, delay: 0.0, options: .curveEaseIn, animations: {
                bar.center = CGPoint(x: bar.center.x, y: originalBarCenter.y + self.frame.height * 0.04)
            }, completion: { _ in
                UIView.animate(withDuration: 0.30, delay: 0.0, options: .curveEaseIn, animations: {
                    bar.center = originalBarCenter
                }, completion: { _ in completion?() })
            })
        })
    }
    
    func stopAnimating() {
        shouldStopAnimating = true
    }
    
	func animate(withDelay delay: Double, completion: (() -> ())?) {
		if isAnimating {
			return
		}
        isAnimating = true
        animateBar(index: 0, withDelay: 0.1 + delay, completion: nil)
        animateBar(index: 1, withDelay: 0.2 + delay, completion: nil)
        animateBar(index: 2, withDelay: 0.3 + delay, completion: nil)
        animateBar(index: 3, withDelay: 0.4 + delay, completion: nil)
        animateBar(index: 4, withDelay: 0.5 + delay, completion: {
			
			self.isAnimating = false
            if self.shouldStopAnimating {
                self.isAnimating = false
                self.shouldStopAnimating = false
            } else {
                completion?()
            }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
