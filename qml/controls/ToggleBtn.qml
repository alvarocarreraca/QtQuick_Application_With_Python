import QtQuick 2.15
import QtQuick.Templates as T
//import QtQuick.Controls 2.15

T.Button{
    id: btnToggle

    property url btnIconSource: "../../images/svg_images/menu_icon.svg"
    property color btnColorDefaul: "#1c1d20"
    property color btnColorMouseOver: "#23272E"
    property color btnColorClicked: "#00a1f1"
    flat: true

    QtObject{
        id: internal
        property var dynamicColor: if(btnToggle.down){
                                       btnToggle.down ? btnColorClicked : btnColorDefaul
                                   } else{
                                       btnToggle.hovered ? btnColorMouseOver : btnColorDefaul
                                   }
    }

    implicitWidth: 70
    implicitHeight: 60

    background: Rectangle{
        id: bgBtn
        color: internal.dynamicColor

        Image {
            id: iconBtn
            source: btnIconSource
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: 25
            width: 25
            fillMode: Image.PreserveAspectFit
            //visible: false
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



