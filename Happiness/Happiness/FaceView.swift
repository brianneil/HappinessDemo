//
//  FaceView.swift
//  Happiness
//
//  Created by Brian Neil on 1/25/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView {
    
    @IBInspectable
    var scale:CGFloat = 0.90 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var lineWidth:CGFloat = 3 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color:UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    
    weak var dataSource: FaceViewDataSource?
    
    var faceCenter: CGPoint {
        return convertPoint(center, fromCoordinateSpace: superview!)
    }
    
    var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    private struct scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 10
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        static let FaceRadiusToMouthWidthRatio: CGFloat = 1
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1       //This will update scale every time it moves
        }
    }
    
    private enum Eye {case Left, Right}
    
    private func bezierPathForEye (whichEye: Eye) -> UIBezierPath
    {
        let eyeRadius = faceRadius / scaling.FaceRadiusToEyeRadiusRatio
        let eyeVericalOffset = faceRadius / scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalSeparation = faceRadius / scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter          // start at the middle
        eyeCenter.y -= eyeVericalOffset     //move up the offset amount
        switch whichEye {                   //Depending on the eye, move right or left
        case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath
    {
        let mouthWidth = faceRadius / scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticalOffset = faceRadius / scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHeight = CGFloat(max(min(fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth / 3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth / 3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        return path
    }

    
    override func drawRect(rect: CGRect) {
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(Eye.Left).stroke()
        bezierPathForEye(Eye.Right).stroke()
        
        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0
        let smilePath = bezierPathForSmile(smiliness)
        smilePath.stroke()
    }
    

}
