import QtQuick 1.0

Rectangle {
    id: gameAreaRect
    width: parent.width
    height: parent.height - 100
    property alias handModel: myHand.model
    property alias players: table.children
    signal cardClicked(variant card)
    signal tableClicked

    function clearTable() {
        var i, card, j;
        for (i = 0; i < players.length; i++) {
            if (players[i].card !== undefined) {
                card = players[i].card.children;
                for (j = 0; j < card.length; j++) {
                    card[j].destroy();
                }
            }
        }
    }
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Item {
            width: 250 //80 * 3 + 2 * 5
            height: 250 //80 * 3 + 2 * 5
            anchors.horizontalCenter: parent.horizontalCenter
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
                    property alias card: card2
                    Column {
                        anchors.fill: parent
                        Text { id: playerName2; anchors.horizontalCenter: parent.horizontalCenter }
                        Rectangle {
                            id: card2
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
                    property alias card: card1
                    Row {
                        anchors.fill: parent
                        spacing: 5
                        Text {
                            id: playerName1
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - card1.width - parent.spacing
                        }
                        Rectangle {
                            id: card1
                            color: gameAreaRect.color
                            width: 30; height: 50
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }
                }
                Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
                Rectangle { color: gameAreaRect.color; id: table_3; width: 80; height: 80;
                    property alias name: playerName3.text
                    property int index: 3
                    property string playerId
                    property alias card: card3
                    Row {
                        anchors.fill: parent
                        spacing: 5
                        Rectangle {
                            id: card3
                            color: gameAreaRect.color
                            width: 30; height: 50
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text { id: playerName3; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
                Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
                Rectangle { color: gameAreaRect.color; id: table_0; width: 80; height: 80;
                    property alias name: playerName0.text
                    property int index: 0
                    property string playerId
                    property alias card: card0
                    Column {
                        anchors.fill: parent
                        Rectangle {
                            id: card0
                            color: gameAreaRect.color
                            width: 30; height: 50;
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text { id: playerName0;  anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }
                Rectangle { color: gameAreaRect.color; width: 1; height: 1 }
            }
            MouseArea { anchors.fill: parent; onClicked: gameAreaRect.tableClicked() }
        }
        Hand {
            id: myHand
            //width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            color: gameAreaRect.color
            Component.onCompleted: myHand.cardClicked.connect(gameAreaRect.cardClicked)
        }
    }
}
