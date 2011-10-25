import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI

Page {
    signal gameCreated
    signal gameJoined
    signal quickGame
    property alias model: gameListModel

    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: quitDialog.open()
        }

        ToolButton {
            text: qsTr("Quick")
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

        // TODO: make busyindicator run only on the first refresh
        BusyIndicator {
            id: busyIndicator
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: UI.DEFAULT_MARGIN
            visible: running
        }
    }

    ListModel {
        id: gameListModel

//        ListElement {
//            gameId: "a"
//            players: "Esko, Arska, Jarska"
//        }
//        ListElement {
//            gameId: "b"
//            players: "Eski, Arski, Jarski"
//        }

    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: pageHeader.bottom
        anchors.bottom: parent.bottom
        ListView {
            id: gameListView
            visible: gameListModel.count > 0
            anchors.fill: parent
            model: gameListModel
            delegate: Item {
                width: parent.width
                height: gameLabel.paintedHeight + UI.DEFAULT_MARGIN
                Label {
                    id: gameLabel
                    anchors.left: parent.left
                    text: model.players
                    font.pixelSize: UI.FONT_DEFAULT
                }
                MouseArea {
                    anchors.fill: parent
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
            visible: gameListModel.count === 0
        }
    }


}
