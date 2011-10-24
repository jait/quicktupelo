import QtQuick 1.0
import "uiconstants.js" as UI

Rectangle {
    id: thisCard
    width: UI.CARD_WIDTH
    height: UI.CARD_HEIGHT
    color: "white"
    property int suit
    property int value
    property real targetY
    property real magnifyFactor: 2.0
    signal clicked (variant card)
    signal pressAndHold (variant card)
    signal released (variant card)
    border.width: 1
    border.color: "#3f000000"
    radius: 5

    function suitToChar(suit) {
        var suits = [{name: "spades", char: "\u2660"},
                     {name: "diamonds", char: "\u2666"},
                     {name: "clubs", char: "\u2663"},
                     {name: "hearts", char: "\u2665"}];
        if (suits[suit] !== undefined) {
            return suits[suit].char;
        }
        return "";
    }

    function valueToChar(value) {
        switch (value) {
        case 11:
            return "J";
        case 12:
            return "Q";
        case 13:
            return "K";
        case 1: // fall through
        case 14:
            return "A";
        default:
            return (value + "");
        }
    }

    function update() {
        cardText.text = "" + suitToChar(suit) + valueToChar(value);
        cardText.color = (suit % 2 === 0 ? "black" : "red");
    }

    function magnify(mode) {
        if (mode === UI.MAGNIFY_KEEP_VCENTER) {
            targetY = y - height / 2 / magnifyFactor;
        } else if (mode === UI.MAGNIFY_KEEP_BOTTOM) {
            targetY = y - height / magnifyFactor;
        }
        state = "MAGNIFIED";
    }

    function stopMagnify() {
        state = "";
    }

    onSuitChanged: update()
    onValueChanged: update()

    Text {
        id: cardText
        anchors.centerIn: parent
        text: "" + suitToChar(parent.suit) + valueToChar(parent.value)
        color: (parent.suit % 2 === 0 ? "black" : "red")
        font.pixelSize: UI.CARD_FONTSIZE
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(parent)
        onPressAndHold: parent.pressAndHold(parent)
        onReleased: {
            //console.log("onReleased");
            if (mouse.wasHeld) {
                parent.released(parent);
                // interpret press&hold&release as a click
                // if the mouse is released
                if (containsMouse) {
                    parent.clicked(parent);
                }
            }
        }
    }

    states: [
        State {
            name: "MAGNIFIED"
            PropertyChanges {
                target: thisCard
                explicit: true // copy, do not bind
                y: targetY
                z: z + 1 // increase z so that the magnified card is not covered by the next
                scale: scale * magnifyFactor
            }
        }
    ]

    transitions: [
        Transition {
            from: "MAGNIFIED"; to: ""
            SequentialAnimation {
                NumberAnimation { properties: "scale,y"; easing.type: Easing.InQuart; duration: 200 }
                PropertyAction { target: thisCard; property: "z" } // set z back to original after animation
            }
        },
        Transition {
            to: "MAGNIFIED"
            SequentialAnimation {
                PropertyAction { target: thisCard; property: "z" }
                NumberAnimation { properties: "scale,y"; easing.type: Easing.InQuart; duration: 200 }
            }
        }
    ]
}
