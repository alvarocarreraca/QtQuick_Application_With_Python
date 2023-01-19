import QtQuick 2.0
import QtQuick.Controls 6.2
import "../controls"

Item {

    property color colorDefaultBlueButton: "#4891d9"
    property color colorMouseOverBlueButton: "#55AAFF"

    Rectangle {
        id: rectangle
        color: "#2c313c"
        anchors.fill: parent
        layer.wrapMode: ShaderEffectSource.ClampToEdge

        Rectangle {
            id: rectangleTop
            x: 217
            y: 60
            height: 60
            color: "#5c667d"
            radius: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 50
            anchors.leftMargin: 50
            anchors.topMargin: 50

            Row {
                id: topComponents
                anchors.fill: parent

                Label {
                    id: topLabel
                    width: 350
                    height: 30
                    color: "#ffffff"
                    text: qsTr("Look for serial port connection:")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    anchors.leftMargin: 40
                    font.pointSize: 16
                }

                Switch {
                    id: switchSerialPort
                    text: qsTr("")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    display: AbstractButton.IconOnly
                    anchors.rightMargin: 40
                    enabled: true
                    onToggled: {
                        backendSerialPort.lookForPorts(switchSerialPort.checked)
                        backendSerialPort.showPortInfo(0)
                        rectangleButtom.visible = switchSerialPort.checked
                        serialBottoms.visible = switchSerialPort.checked
                    }
                }
            }
        }

        Rectangle {
            id: rectangleButtom
            x: 214
            y: 69
            color: "#5c667d"
            radius: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: rectangleTop.bottom
            anchors.bottom: serialBottoms.top
            anchors.bottomMargin: 20
            anchors.leftMargin: 50
            anchors.topMargin: 20
            anchors.rightMargin: 50
            visible: false

            Row {
                id: serialPortInfo
                anchors.fill: parent

                Rectangle {
                    id: serialPortSelect
                    color: "#00000000"
                    radius: 10
                    border.color: "#55aaff"
                    border.width: 1
                    anchors.left: parent.left
                    anchors.right: serialPortParameters.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 10
                    anchors.rightMargin: 15
                    anchors.bottomMargin: 10
                    anchors.leftMargin: 15

                    Column {
                        id: serialPortContainer
                        anchors.fill: parent

                        ComboBox {
                            id: serialPortComboBox
                            width: 80
                            anchors.top: label.bottom
                            displayText: ""
                            textRole: ""
                            anchors.horizontalCenter: parent.horizontalCenter
                            leftPadding: 2
                            anchors.topMargin: 10
                            enabled: true
                            onActivated: {
                                serialPortComboBox.displayText = serialPortComboBox.currentText
                                backendSerialPort.showPortInfo(serialPortComboBox.currentIndex)
                            }
                        }

                        Label {
                            id: descriptionLabel
                            height: 20
                            color: "#ffffff"
                            text: qsTr("Description:")
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: serialPortComboBox.bottom
                            font.letterSpacing: 0
                            verticalAlignment: Text.AlignVCenter
                            clip: true
                            leftPadding: 10
                            font.pointSize: 10
                            anchors.rightMargin: 15
                            anchors.leftMargin: 10
                            anchors.topMargin: 15
                        }

                        Label {
                            id: manufacturerLabel
                            height: 20
                            color: "#ffffff"
                            text: qsTr("Manufacturer:")
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: descriptionLabel.bottom
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            font.pointSize: 10
                            anchors.rightMargin: 15
                            anchors.topMargin: 10
                            anchors.leftMargin: 10
                        }

                        Label {
                            id: serialNumberLabel
                            height: 20
                            color: "#ffffff"
                            text: qsTr("Serial Number:")
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: manufacturerLabel.bottom
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            leftInset: 0
                            font.pointSize: 10
                            anchors.rightMargin: 15
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                        }

                        Label {
                            id: locationLabel
                            height: 20
                            color: "#ffffff"
                            text: qsTr("Location:")
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: serialNumberLabel.bottom
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 10
                            font.pointSize: 10
                            anchors.rightMargin: 15
                            anchors.leftMargin: 10
                            anchors.topMargin: 10
                        }

                        Label {
                            id: label
                            text: qsTr("Select Serial Port")
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: 10
                            font.bold: true
                            font.pointSize: 12
                        }
                    }
                }

                Rectangle {
                    id: serialPortParameters
                    width: 200
                    color: "#00000000"
                    radius: 10
                    border.color: "#55aaff"
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    anchors.rightMargin: 15
                }
            }
        }

        Rectangle {
            id: serialBottoms
            x: 50
            y: 375
            height: 50
            color: "#5c667d"
            radius: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: 50
            anchors.leftMargin: 50
            anchors.bottomMargin: 50
            visible: false

            Row {
                id: bottomsConnection
                anchors.fill: parent

                CustomButton {
                    id: refreshBtn
                    width: 135
                    text: qsTr("Refresh")
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    font.pointSize: 10
                    z: 0
                    flat: false
                    highlighted: false
                    anchors.leftMargin: 20
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                    enabled: true
                    onClicked: {
                        backendSerialPort.lookForPorts(true)
                        backendSerialPort.showPortInfo(0)
                    }
                }

                CustomButton {
                    id: connectBtn
                    width: 135
                    text: qsTr("Connect")
                    anchors.right: disconnectBtn.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 20
                    font.pointSize: 10
                    z: 0
                    flat: false
                    highlighted: false
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                    enabled: True
                    onClicked: {
                        backendSerialPort.openSerialPort(serialPortComboBox.currentIndex)
                        connectBtn.enabled = false
                        connectBtn.opacity = 0.5
                        connectBtn.colorMouseOver = colorDefaultBlueButton
                        refreshBtn.enabled = false
                        refreshBtn.opacity = 0.5
                        refreshBtn.colorMouseOver = colorDefaultBlueButton
                        disconnectBtn.enabled = true
                        disconnectBtn.opacity = 1
                        disconnectBtn.colorMouseOver = colorMouseOverBlueButton
                    }
                }

                CustomButton {
                    id: disconnectBtn
                    width: 135
                    opacity: 0.5
                    text: qsTr("Disconnect")
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    enabled: false
                    colorMouseOver: "#4891d9"
                    anchors.rightMargin: 20
                    font.pointSize: 10
                    z: 0
                    flat: false
                    highlighted: false
                    anchors.topMargin: 5
                    anchors.bottomMargin: 5
                    onClicked: {
                        backendSerialPort.closeSerialPort()
                        connectBtn.enabled = true
                        connectBtn.opacity = 1
                        connectBtn.colorMouseOver = colorMouseOverBlueButton
                        refreshBtn.enabled = true
                        refreshBtn.opacity = 1
                        refreshBtn.colorMouseOver = colorMouseOverBlueButton
                        disconnectBtn.enabled = false
                        disconnectBtn.opacity = 0.5
                        disconnectBtn.colorMouseOver = colorDefaultBlueButton
                    }
                }
            }
        }
    }

    Connections{
        target: backendSerialPort

        function onIsPortReady(portList){
            serialPortComboBox.model = portList
            serialPortComboBox.displayText = portList[0]
        }

        function onIsInfoList(info){
            descriptionLabel.text = info[0]
            manufacturerLabel.text = info[1]
            serialNumberLabel.text = info[2]
            locationLabel.text = info[3]
        }

        function onIsConnected(isConnected){
            if (isConnected){
                connectBtn.enabled = false
                disconnectBtn.enabled = true
                refreshBtn.enabled = false
                serialPortComboBox.enabled = false
                switchSerialPort.enabled = false
            }else{
                connectBtn.enabled = true
                disconnectBtn.enabled = false
                refreshBtn.enabled = true
                serialPortComboBox.enabled = true
                switchSerialPort.enabled = true
            }
        }
    }

}
/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:800}
}
##^##*/
