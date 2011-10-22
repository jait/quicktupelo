import QtQuick 1.1
import com.nokia.meego 1.0
import "uiconstants.js" as UI

Rectangle {
    height: UI.HEADER_HEIGHT
    property alias title: titleText.text
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    color: "gray"

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
