import QtQuick 1.0
import "game.js" as Game

Rectangle {
    width: 640
    height: 480
    color: "#edecec"
    id: mainRect

    /*
    function createCard(parent, suit, value) {
        var component = Qt.createComponent("Card.qml");
        var card = component.createObject(parent);
        if (card === null) {
            console.log("Error creating object");
            return undefined;
        }

        card.suit = suit;
        card.value = value;
        return card;
    }
    */

    WorkerScript {
        id: myWorker
        source: "workerscript.js"

        onMessage: {
            console.log("received something from worker");
            Game.handleMessage(messageObject);
        }
    }

    Timer {
        id: eventTimer
        interval: 2000; running: false; repeat: true
        onTriggered: {
            myWorker.sendMessage({action: "pollEvents"});
        }
    }

    Column {
        id: column1
        x: 0
        y: 0
        anchors.fill: parent
        spacing: 10
        Row {
            id: loginRow
            spacing: 10
            //anchors.centerIn: parent
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter
            /*
            Text {
                id: loginLabel
                anchors.centerIn: parent
                text: "Your name"
                font.pixelSize: 12
            }
            */
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                id: nameInputItem
                width: 80
                height: 25
                color: "#ffffff"
                border.color: "black"

                TextInput {
                    anchors.centerIn: parent
                    id: nameInput
                    width: 80
                    /*
                    height: 20
                    */
                    text: "Your name"
                    cursorVisible: true
                    font.family: "Lucida Grande"
                    font.pixelSize: 12
                    onFocusChanged: { if (focus) { text = "" } }
                }
            }
            Button {
                height: 25
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: nameInputItem.right
                text: "Sign on"
                onClicked: myWorker.sendMessage({action: "register", playerName: nameInput.text})
                // TODO: need a REGISTERING state to disable the UI fields and show a spinner/something
            }
        }
        Row {
            id: statusRow
            visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            height: 50
            Text {
                anchors.verticalCenter: parent.verticalCenter
                id: loggedLabel
                text: "<none>"
                font.pixelSize: 12
                opacity: 0
            }
            Button {
                anchors.verticalCenter: parent.verticalCenter
                text: "Sign off"
                onClicked: myWorker.sendMessage({action: "quit"})
            }
        }

        Rectangle {
            id: gameArea
            width: parent.width
            height: parent.height - 100
            color: mainRect.color
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                Grid {
                    id: table
                    columns: 3
                    spacing: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle { color: gameArea.color; width: 1; height: 1 }
                    Rectangle { color: gameArea.color; id: table_2; width: 50; height: 50;
                        Column {
                            Text { id: playerName2 }
                        }
                    }
                    Rectangle { color: gameArea.color; width: 1; height: 1 }
                    Rectangle { color: gameArea.color; id: table_1; width: 50; height: 50;
                        Row {
                            Text { id: playerName1 }
                        }
                    }
                    Rectangle { color: gameArea.color; width: 1; height: 1 }
                    Rectangle { color: gameArea.color; id: table_3; width: 50; height: 50;
                        Row {
                            Text { id: playerName3 }
                        }
                    }
                    Rectangle { color: gameArea.color; width: 1; height: 1 }
                    Rectangle { color: gameArea.color; id: table_0; width: 50; height: 50;
                        Column {
                            Text { id: playerName0 }
                        }
                    }
                    Rectangle { color: gameArea.color; width: 1; height: 1 }
                }
                Hand {
                    id: myHand
                    //width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: gameArea.color
                }
            }
        }

    }
    states: [
        State {
            name: "REGISTERED"

            PropertyChanges {
                target: statusRow
                visible: true
            }

            PropertyChanges {
                target: loginRow
                visible: false
            }

            PropertyChanges {
                target: loggedLabel
                text: "Signed on as " + nameInput.text
                opacity: 1
            }
        },
        State {
            name: "IN_GAME"

            PropertyChanges {
                target: eventTimer
                running: true
            }

            PropertyChanges {
                target: statusRow
                visible: true
            }

            PropertyChanges {
                target: loginRow
                visible: false
            }

            PropertyChanges {
                target: loggedLabel
                text: "Signed on as " + nameInput.text
                opacity: 1
            }
        }
    ]
}
