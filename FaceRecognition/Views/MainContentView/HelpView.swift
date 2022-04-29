//
//  HelpView.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 4/29/22.
//

import SwiftUI

struct HelpView: View {
    @Binding var isShowingPopover: Bool
    var body: some View {
        Button("?") {
            self.isShowingPopover = true
        }
        .popover(isPresented: $isShowingPopover) {
            ScrollView {
                VStack {
                    Text(helpText)
                        .lineLimit(nil)
                }.frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView(isShowingPopover: .constant(true))
    }
}

extension HelpView {
    var helpText:String {
"""
HELP

This is a 3D face recognition app demo.
The circle on top uses ARKit in order to recognize your face, your face posses, \
and your face expression.
When you face is too close or too far from the camer the app will show a blinking \
ring on the circle border, other wise we will be able to see a ring of white rims \
and one in orange showing where we need to look.
The goal is to complete four poses of looking at our left, right, top, and bottom and \
two poses of tilt our head to the left and to the right.

This app also shows us the six stronger face expressions recognized by ARKit. The \
list of Face Expressions shows each one its name and its value.

The slider Mask F.Expressions defines what is the minimum value filter in the list.
And the slider Mask Transparency set how transparent is the 3D Face Mesh of our \
face. This 3D Face Mesh can be sent as a JSON file attached to an email. This file \
will include those facial expressions. And the way to trigger this email is by clicking\
on the button "Send Mesh" at the bottom-right corner of the top circle.

And at the left side of the button "Send Mesh" there is another button called "Reset"\
, this button will reset the green rims in case we have one.

NOTE: This app, unfortunately, is not free of bugs, so don't much worry about bugs if\
you find any. But also feel free to tell me about them in slack if you want.


NOTE 2: Enjoy the App!!

"""
    }
}
