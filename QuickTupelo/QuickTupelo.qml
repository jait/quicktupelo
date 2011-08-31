import QtQuick 1.0

Rectangle {
    width: 480
    height: 360
    color: "#edecec"
    id: mainRect

    function updateHand(newHand) {
        myHand.model.clear();
        var i = 0;
        for (i = 0; i < newHand.length; i++) {
            myHand.model.append({"csuit": newHand[i].suit,
                                "cvalue": newHand[i].value});
        }
    }

    function handleMessage(message) {
        console.log("handling message");
        switch (message.action) {
        case "register":
            if (message.success) {
                mainRect.state = "REGISTERED";
                // go play straight away
                myWorker.sendMessage({action: "quickStart"});
            } else {
                console.log("Register failed!");
            }
            break;
        case "quit":
            if (! message.success) {
                console.log("Quit failed!");
            }
            mainRect.state = "";
            myHand.model.clear();
            eventTimer.running = false;
            break;
        case "startGame":
        case "startGameWithBots":
            if (! message.success) {
                console.log("startGame failed!");
                break;
            }
            mainRect.state = "IN_GAME";
            myWorker.sendMessage({action: "getGameState"});
            break;
        case "pollEvents":
            if (! message.success) {
                console.log("pollEvents failed!");
                break;
            }
            console.log(JSON.stringify(message.response));
            // TODO: add events to queue
            break;
        case "getGameState":
            if (! message.success) {
                console.log("getGameState failed!");

                break;
            }
            if (message.response.hand !== undefined) {
                updateHand(message.response.hand);
            }
            // TODO: update state
            break;
        default:
            console.log("Unsupported action " + message.action);
            break;
        }
    }

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

    WorkerScript {
        id: myWorker
        source: "workerscript.js"

        onMessage: {
            console.log("received something from worker");
            handleMessage(messageObject);
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
            height: 260
            color: mainRect.color
            Hand {
                id: myHand
                anchors.fill: parent
                color:  parent.color
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
