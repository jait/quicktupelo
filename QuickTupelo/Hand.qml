import QtQuick 1.0

Rectangle {
    width: 360
    property alias model: handView.model

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
            width: 30
            Card { suit: csuit; value: cvalue }
        }
    }

    ListView {
        width: parent.width
        id: handView
        model: handModel
        orientation: ListView.Horizontal
        delegate: handDelegate
        spacing: 5
    }
}
