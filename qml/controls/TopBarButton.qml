import QtQuick 2.15
import QtQuick.Templates as T
//import QtQuick.Controls 2.15

T.Button{
    id: btnTopBar

    property url btnIconSource: "../../images/svg_images/minimize_icon.svg"
    property color btnColorDefaul: "#1c1d20"
    property color btnColorMouseOver: "#23272E"
    property color btnColorClicked: "#00a1f1"
    property int radiousValue: 0

    QtObject{
        id: internal
        property var dynamicColor: if(btnTopBar.down){
                                       btnTopBar.down ? btnColorClicked : btnColorDefaul
                                   } else{
                                       btnTopBar.hovered ? btnColorMouseOver : btnColorDefaul
                                   }
    }

    width: 35
    height: 35
    enabled: true
    highlighted: false
    clip: false
    antialiasing: false
    focusPolicy: Qt.StrongFocus
    flat: true

    background: Rectangle{
        id: bgBtn
        color: internal.dynamicColor
        radius: radiousValue

        Image {
            id: iconBtn
            source: btnIconSource
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: 16
            width: 16
            //visible: false
            fillMode: Image.PreserveAspectFit
            antialiasing: false
        }
/*
        ColorOverlay{
            anchors.fill: iconBtn
            source: iconBtn
            color: "#ffffff"
            antialiasing: false
        }
        */
    }
}

/*##^##
Designer {
    D{i:0;height:35;width:35}
}
##^##*/
