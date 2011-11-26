import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI

Rectangle {
    height: UI.HEADER_HEIGHT
    property alias title: titleText.text
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    property bool pressed: false
    //color: "gray"
    property color accentColor: pressed ? "darkgray" : (theme.inverted ? UI.COLOR_INVERTED_BACKGROUND : "gray")

    gradient: Gradient {
        GradientStop { color: Qt.lighter(accentColor, 1.25); position: 0.0 }
        GradientStop { color: Qt.darker(accentColor, 1.5); position: 1.0 }
    }

    Text {
        id: titleText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: UI.DEFAULT_MARGIN
        font.pixelSize: UI.FONT_XLARGE
        font.weight: Font.Light
        color: "#FFFFFF"
    }
}
