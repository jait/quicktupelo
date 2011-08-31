import QtQuick 1.0

Rectangle {
    id: gameAreaRect
    width: parent.width
    height: parent.height - 100
    property alias handModel: myHand.model
    property alias players: table.children

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Grid {
            id: table
            columns: 3
            spacing: 5
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
            Rectangle { color: gameAreaRect.color; id: table_2; width: 80; height: 80;
                property alias name: playerName2.text
                property int index: 2
                property string playerId
                Column {
                    anchors.fill: parent
                    Text { id: playerName2; anchors.horizontalCenter: parent.horizontalCenter }
                    Rectangle {
                        color: gameAreaRect.color
                        width: 30; height: 50
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
            Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
            Rectangle { color: gameAreaRect.color; id: table_1; width: 80; height: 80;
                property int index: 1
                property alias name: playerName1.text
                property string playerId
                Row {
                    anchors.fill: parent
                    Text { id: playerName1; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { color: gameAreaRect.color; width: 30; height: 50;
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
            Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
            Rectangle { color: gameAreaRect.color; id: table_3; width: 80; height: 80;
                property alias name: playerName3.text
                property int index: 3
                property string playerId
                Row {
                    anchors.fill: parent
                    Rectangle { color: gameAreaRect.color; width: 30; height: 50; anchors.verticalCenter: parent.verticalCenter }
                    Text { id: playerName3; anchors.verticalCenter: parent.verticalCenter }
                }
            }
            Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
            Rectangle { color: gameAreaRect.color; id: table_0; width: 80; height: 80;
                property alias name: playerName0.text
                property int index: 0
                property string playerId
                Column {
                    anchors.fill: parent
                    Rectangle {
                        color: gameAreaRect.color
                        width: 30; height: 50;
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text { id: playerName0;  anchors.horizontalCenter: parent.horizontalCenter }
                }
            }
            Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
        }
        Hand {
            id: myHand
            //width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            color: gameAreaRect.color
        }
    }
}
