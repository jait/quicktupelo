import QtQuick 1.1
import "uiconstants.js" as UI

Rectangle {
    //width: 480 > parent.width ? parent.width : 480
    height: UI.CARD_HEIGHT
    property alias model: handView.model
    signal cardClicked(variant card)
    id: handRect

    ListModel {
        id: handModel

//        ListElement {
//            csuit: 1
//            cvalue: 5
//        }
//        ListElement {
//            csuit: 2
//            cvalue: 6
//        }
//        ListElement {
//            csuit: 3
//            cvalue: 7
//        }

    }

    Component {
        id: handDelegate
        Item {
            id: delegateItem
            width: delegateCard.width // 30
            Card {
                id: delegateCard
                suit: csuit; value: cvalue
                onClicked: handRect.cardClicked(delegateCard)
            }
        }
    }

    ListView {
        id: handView
        property int minWidth: count * (UI.CARD_WIDTH + spacing) - spacing // 35 = delegateItem.width + handView.spacing
        width: (minWidth > parent.width) ? parent.width: minWidth
        //width: parent.width
        height: UI.CARD_HEIGHT
        anchors.horizontalCenter: parent.horizontalCenter
        model: handModel
        orientation: ListView.Horizontal
        delegate: handDelegate
        spacing: UI.HAND_SPACING
        interactive: true //minWidth > parent.width // allow flicking
        clip: true // interactive
    }
}
