import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI

Page {
    signal gameCreated
    signal gameJoined
    signal quickGame
    signal listGamesCompleted (variant message)
    property alias model: gameListModel

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: quitDialog.open()
        }

        ToolButton {
            text: qsTr("Quick game")
            onClicked: quickGame()
        }

        ToolIcon {
            platformIconId: "toolbar-add"
            onClicked: { console.log("create game clicked"); }
        }
    }

    Timer {
        id: gameListTimer
        interval: 4000; running: status === PageStatus.Active; repeat: true; triggeredOnStart: true
        onTriggered: { worker.sendMessage({action: "listGames", model: gameListModel}) }
    }

    onListGamesCompleted: {
        if (! message.success) {
            console.log("listGames failed!");
            gameListTimer.stop();
        } else {
            if (gameListModel.updated !== true) {
                gameListModel.updated = true;
            }
        }
    }

    onQuickGame: {
        worker.sendMessage({action: "quickStart"});
        state = "JOINING";
    }

    QueryDialog {
        id: quitDialog
        titleText: qsTr("Sign off?")
        message: qsTr("Sign off from the server?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: worker.sendMessage({action: "quit"})
    }

    QueryDialog {
        id: joinDialog
        titleText: qsTr("Join game?")
        //message: qsTr("Players: ")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: console.log("Not implemented!")
    }

    PageHeader {
        id: pageHeader
        title: "List of games"
        z: 1

        BusyIndicator {
            id: busyIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: UI.DEFAULT_MARGIN
            visible: running
            running: false
        }
    }

    ListModel {
        id: gameListModel
        property bool updated: false
//        ListElement {
//            gameId: "a"
//            players: "Esko, Arska, Jarska"
//            joinable: true
//        }
//        ListElement {
//            gameId: "b"
//            players: "Eski, Arski, Jarski"
//            joinable: true
//        }
    }

    // QTBUG-19763
    Connections {
        target: gameListModel
        onUpdatedChanged: if (gameListModel.updated) { busyIndicator.running = false; }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: UI.DEFAULT_MARGIN
        ListView {
            id: gameListView
            visible: gameListModel.count > 0
            anchors.fill: parent
            model: gameListModel
            property color listTitleColor: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
            delegate: Item {
                width: parent.width
                //height: gameLabel.paintedHeight + UI.DEFAULT_MARGIN
                height: gameLabel.paintedHeight + UI.DEFAULT_MARGIN > 64 ? gameLabel.paintedHeight + UI.DEFAULT_MARGIN: 64

                Label {
                    id: gameLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: model.players
                    font.pixelSize: UI.FONT_SLARGE
                    font.weight: Font.Bold
                    color: model.joinable ? gameListView.listTitleColor : "gray"
                }
                MouseArea {
                    anchors.fill: parent
                    visible: model.joinable
                    onClicked: {
                        console.log("game " + model.gameId + " clicked");
                        joinDialog.open();
                    }
                }
            }
        }
        ScrollDecorator {
            flickableItem: gameListView
        }
        Label {
            anchors.centerIn: parent
            text: qsTr("No games")
            // TODO: correct platform style?
            font.pixelSize: UI.FONT_XLARGE
            color: "gray"
            visible: gameListModel.updated && gameListModel.count === 0
        }
    }

    MouseArea {
        id: eventEater
        anchors.fill: parent
        visible: false
    }

    states: [
        State {
            name: "JOINING"
            PropertyChanges {
                target: busyIndicator
                running: true
            }
            PropertyChanges {
                target: eventEater
                visible: true
            }
        }
    ]

    Component.onCompleted: busyIndicator.running = (gameListModel.updated === false)
}
