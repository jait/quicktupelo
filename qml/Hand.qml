import QtQuick 1.0

Rectangle {
    width: 480
    height: 50 // Card.height
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
        property int minWidth: count * (30 + spacing) - spacing // 35 = delegateItem.width + handView.spacing
        width: (minWidth > parent.width) ? parent.width: minWidth
        anchors.horizontalCenter: parent.horizontalCenter
        model: handModel
        orientation: ListView.Horizontal
        delegate: handDelegate
        spacing: 5
        interactive: false
    }
}
