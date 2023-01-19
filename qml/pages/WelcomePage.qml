import QtQuick 2.0
import QtQuick.Controls 6.2
import "../controls"

Item {
    Rectangle {
        id: welcomeContainer
        color: "#2c313c"
        anchors.fill: parent

        PropertyAnimation{
            id: animationInfo
            target: mainDescriptionContainer
            property: "width"
            to: if(mainDescriptionContainer.width == 0) return 450
            duration: 1500
            easing.type: Easing.InOutQuint
        }

        Rectangle {
            id: welcomeHeaderContainer
            height: 110
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Label {
                id: welcomeLabel
                color: "#ffffff"
                text: "Welcome to TransRehab"
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pointSize: 30
            }
        }

        Rectangle {
            id: welcomeBodyContainer
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: welcomeHeaderContainer.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.bottomMargin: 0
            anchors.topMargin: 0

            Rectangle {
                id: infoContainer
                color: "#00000000"
                width: parent.width / 2
                border.color: "#00000000"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Rectangle {
                    id: infoWrappingContainer
                    width: 450
                    height: 430
                    color: "#00000000"
                    border.color: "#547cf3"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenterOffset: -20

                    Column {
                        id: column
                        spacing: 20

                        Text {
                            id: mainText
                            text: 'Here by using the application you can control \nyour FES device by:'
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 24
                            anchors.leftMargin: 10
                            font.pointSize: 14
                            color: "#ffffff"
                        }

                        Text {
                            id: perfromingCalibrationLabel
                            color: "#ffffff"
                            text: qsTr("    1) Performing calibrations")
                            anchors.left: parent.left
                            anchors.top: mainText.bottom
                            font.bold: true
                            font.pointSize: 14
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                        }

                        Text {
                            id: emgCalibLabel
                            width: 159
                            color: "#ffffff"
                            text: qsTr("            - EMG")
                            anchors.left: parent.left
                            anchors.top: perfromingCalibrationLabel.bottom
                            font.pointSize: 14
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                        }

                        Text {
                            id: angleCalibLabel
                            color: "#ffffff"
                            text: qsTr("            - Flex angle")
                            anchors.left: parent.left
                            anchors.top: emgCalibLabel.bottom
                            font.pointSize: 14
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                        }

                        Text {
                            id: fesCalibLabel
                            width: 159
                            color: "#ffffff"
                            text: qsTr("            - FES")
                            anchors.left: parent.left
                            anchors.top: angleCalibLabel.bottom
                            font.pointSize: 14
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                        }

                        Text {
                            id: applyingTheoryLabel
                            color: "#ffffff"
                            text: qsTr("    2) Applying theory")
                            anchors.left: parent.left
                            anchors.top: fesCalibLabel.bottom
                            font.bold: true
                            font.pointSize: 14
                            anchors.leftMargin: 10
                            anchors.topMargin: 15
                        }

                        CustomButton {
                            id: emgDetailsBtn
                            width: 105
                            height: 25
                            opacity: 1
                            text: "Details >"
                            anchors.verticalCenter: emgCalibLabel.verticalCenter
                            anchors.left: emgCalibLabel.right
                            anchors.leftMargin: 20
                            colorMouseOver: "#55aaff"
                            anchors.bottomMargin: 20
                            enabled: true
                            anchors.topMargin: 20
                            onClicked: {
                                emgDescriptionContainer.visible = true
                                angleDescriptionContainer.visible = false
                                fesDescriptionContainer.visible = false
                                animationInfo.running = true
                            }
                        }

                        CustomButton {
                            id: angleDetailsBtn
                            width: 105
                            height: 25
                            opacity: 1
                            text: "Details >"
                            anchors.verticalCenter: angleCalibLabel.verticalCenter
                            anchors.left: angleCalibLabel.right
                            colorMouseOver: "#55aaff"
                            anchors.bottomMargin: 20
                            anchors.leftMargin: 20
                            enabled: true
                            anchors.topMargin: 20
                            onClicked: {
                                emgDescriptionContainer.visible = false
                                angleDescriptionContainer.visible = true
                                fesDescriptionContainer.visible = false
                                animationInfo.running = true
                            }
                        }

                        CustomButton {
                            id: fesDetailsBtn
                            width: 105
                            height: 25
                            opacity: 1
                            text: "Details >"
                            anchors.verticalCenter: fesCalibLabel.verticalCenter
                            anchors.left: fesCalibLabel.right
                            anchors.leftMargin: 20
                            anchors.bottomMargin: 20
                            colorMouseOver: "#55aaff"
                            enabled: true
                            anchors.topMargin: 20
                            onClicked: {
                                emgDescriptionContainer.visible = false
                                angleDescriptionContainer.visible = false
                                fesDescriptionContainer.visible = true
                                animationInfo.running = true
                            }
                        }

                        Text {
                            id: connectWithLabel
                            color: "#ffffff"
                            text: qsTr("    3) Connect with device")
                            anchors.left: parent.left
                            anchors.top: applyingTheoryLabel.bottom
                            font.pointSize: 14
                            font.bold: true
                            anchors.topMargin: 70
                            anchors.leftMargin: 10
                        }
                    }

                    CustomButton {
                        id: letsStartBtn
                        x: -53
                        y: 0
                        width: 120
                        height: 30
                        opacity: 1
                        text: "Let's Start >"
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        colorMouseOver: "#55aaff"
                        anchors.bottomMargin: 120
                        enabled: true
                        anchors.topMargin: 20
                        onClicked: {
                            backendSerialPort.changeToMainWindow()
                        }
                    }

                    CustomButton {
                        id: goToSettingsBtn
                        x: -60
                        y: -25
                        width: 120
                        height: 30
                        opacity: 1
                        text: "Go to Settings >"
                        anchors.bottom: parent.bottom
                        enabled: true
                        anchors.topMargin: 20
                        anchors.bottomMargin: 25
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            backendSerialPort.changeToSettingsWindow()
                        }
                        colorMouseOver: "#55aaff"
                    }
                }
            }

            Rectangle {
                id: descriptionContainer
                width: parent.width / 2
                color: "#00000000"
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                Rectangle {
                    id: mainDescriptionContainer
                    width: 0
                    height: 500
                    color: "#00000000"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        id: emgDescriptionContainer
                        x: 0
                        y: 0
                        width: 450
                        height: 500
                        visible: false
                        color: "#374162c3"
                        radius: 10
                        border.color: "#547cf3"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter

                        Text {
                            id: emgDescriptionText
                            color: "#ffffff"
                            text: qsTr("EMG Calibration description:")
                            anchors.fill: parent
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            font.bold: true
                            anchors.rightMargin: 20
                            anchors.leftMargin: 20
                            anchors.bottomMargin: 25
                            anchors.topMargin: 25
                        }
                    }

                    Rectangle {
                        id: fesDescriptionContainer
                        x: 0
                        y: 0
                        width: 450
                        height: 500
                        visible: false
                        color: "#374162c3"
                        radius: 10
                        border.color: "#547cf3"
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            id: fesDescriptionText
                            color: "#ffffff"
                            text: qsTr("FES Calibration description:")
                            anchors.fill: parent
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            anchors.bottomMargin: 25
                            anchors.leftMargin: 20
                            font.bold: true
                            anchors.topMargin: 25
                            anchors.rightMargin: 20
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Rectangle {
                        id: angleDescriptionContainer
                        x: 0
                        y: 0
                        width: 450
                        height: 500
                        visible: false
                        color: "#374162c3"
                        radius: 10
                        border.color: "#547cf3"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 0
                        Text {
                            id: angleDescriptionText
                            color: "#ffffff"
                            text: qsTr("Flex anlge Calibration description:")
                            anchors.fill: parent
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            anchors.bottomMargin: 25
                            anchors.leftMargin: 20
                            font.bold: true
                            anchors.topMargin: 25
                            anchors.rightMargin: 20
                        }
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    Connections{
        target: backendSerialPort
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.75;height:673;width:1108}
}
##^##*/
