import QtQuick 1.0
import "uiconstants.js" as UI

Rectangle {
    width: UI.CARD_WIDTH
    height: UI.CARD_HEIGHT
    color: "white"
    property int suit
    property int value
    signal clicked (variant card)
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

    onSuitChanged: update()
    onValueChanged: update()

    Text {
        id: cardText
        anchors.centerIn: parent
        text: "" + suitToChar(parent.suit) + valueToChar(parent.value)
        color: (parent.suit % 2 === 0 ? "black" : "red")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: parent.clicked(parent)
    }
}
