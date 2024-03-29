import QtQuick 1.0
import "uiconstants.js" as UI

Item {
    id: gameAreaContainer
    width: parent.width
    property alias hand: myHand
    property alias players: table.children
    signal cardClicked(variant card)
    signal tableClicked

    function clearAll() {
        var i;
        myHand.clear();
        clearTable();
        // clear player names
        for (i = 0; i < players.length; i++) {
            if (players[i].name !== undefined) {
                players[i].name = "";
            }
        }
    }

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
        spacing: UI.DEFAULT_MARGIN
        width: parent.width
        Item {
            width: 250 //80 * 3 + 2 * 5
            height: 250 //80 * 3 + 2 * 5
            anchors.horizontalCenter: parent.horizontalCenter
            Grid {
                id: table
                columns: 3
                spacing: 5
                anchors.horizontalCenter: parent.horizontalCenter
                Item { width: 1; height: 1 }
                Item { id: table_2; width: 80; height: 80;
                    property alias name: playerName2.text
                    property int index: 2
                    property string playerId
                    property alias card: card2
                    Column {
                        anchors.fill: parent
                        PlayerLabel {
                            id: playerName2
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Item {
                            id: card2
                            width: UI.CARD_WIDTH; height: UI.CARD_HEIGHT
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                Item { width: 1; height: 1 }
                Item { id: table_1; width: 80; height: 80;
                    property int index: 1
                    property alias name: playerName1.text
                    property string playerId
                    property alias card: card1
                    Row {
                        anchors.fill: parent
                        spacing: 5
                        PlayerLabel {
                            id: playerName1
                            // Qt Quick 1.1 would have layoutDirection...
                            width: parent.width - card1.width - parent.spacing
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignRight
                        }
                        Item {
                            id: card1
                            width: UI.CARD_WIDTH; height: UI.CARD_HEIGHT
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Item { width: 1; height: 1 }
                Item { id: table_3; width: 80; height: 80;
                    property alias name: playerName3.text
                    property int index: 3
                    property string playerId
                    property alias card: card3
                    Row {
                        anchors.fill: parent
                        spacing: 5
                        Item {
                            id: card3
                            width: UI.CARD_WIDTH; height: UI.CARD_HEIGHT
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        PlayerLabel {
                            id: playerName3
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
                Item { width: 1; height: 1 }
                Item { id: table_0; width: 80; height: 80;
                    property alias name: playerName0.text
                    property int index: 0
                    property string playerId
                    property alias card: card0
                    Column {
                        anchors.fill: parent
                        Item {
                            id: card0
                            width: UI.CARD_WIDTH; height: UI.CARD_HEIGHT;
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        PlayerLabel {
                            id: playerName0
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
                Item { width: 1; height: 1 }
            }
            MouseArea { anchors.fill: parent; onClicked: gameAreaContainer.tableClicked() }
        }

        Hand {
            id: myHand
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Component.onCompleted: myHand.cardClicked.connect(gameAreaContainer.cardClicked)
        }
    }
}
