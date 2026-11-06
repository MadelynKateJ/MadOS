import QtQuick 2.15

Rectangle {
    id: root
    property int stage: 0
    color: "#fdeef5"

    Image {
        anchors.fill: parent
        source: "wallpaper.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.centerIn: parent
        width: 430
        height: 240
        radius: 28
        color: "#fff8fb"
        opacity: 0.88

        Column {
            anchors.centerIn: parent
            spacing: 10

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "MadOS"
                color: "#93325f"
                font.pixelSize: 52
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "SURPRISINGLY FUNCTIONAL"
                color: "#c2437f"
                font.pixelSize: 15
                font.letterSpacing: 3
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                topPadding: 12
                Repeater {
                    model: 3
                    Rectangle {
                        width: 13
                        height: 13
                        radius: 6.5
                        color: "#f472b6"
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            PauseAnimation { duration: index * 220 }
                            NumberAnimation { from: 1.0; to: 0.25; duration: 420 }
                            NumberAnimation { from: 0.25; to: 1.0; duration: 420 }
                            PauseAnimation { duration: (2 - index) * 220 }
                        }
                    }
                }
            }
        }
    }
}
