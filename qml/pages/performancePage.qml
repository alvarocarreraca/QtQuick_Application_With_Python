import QtQuick 2.0
import QtQuick.Controls 6.2
import "../controls"
import QtCharts 6.2

Item {

    property int maxRangePerformance: 0

    Rectangle {
        id: performanceContainer
        color: "#2c313c"
        anchors.fill: parent

        Rectangle {
            id: performanceHeader
            height: 80
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Label {
                id: performanceLabel
                x: 241
                y: 20
                color: "#ffffff"
                text: qsTr("Performance analysis")
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: true
                font.pointSize: 24
            }
        }

        Rectangle {
            id: performanceBody
            height: 180
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: performanceHeader.bottom
            anchors.topMargin: 0
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            Column {
                id: column
                anchors.fill: parent

                Label {
                    id: pathLabel
                    width: 95
                    color: "#ffffff"
                    text: qsTr("Path:")
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenterOffset: -220
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 5
                    font.pointSize: 12
                }

                Label {
                    id: subjectLabel
                    width: 95
                    color: "#ffffff"
                    text: qsTr("Subject:")
                    anchors.top: pathLabel.bottom
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenterOffset: -220
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 12
                    anchors.topMargin: 25
                }

                Label {
                    id: fromSessionLabel
                    color: "#ffffff"
                    text: qsTr("From session:")
                    anchors.top: subjectLabel.bottom
                    horizontalAlignment: Text.AlignLeft
                    anchors.horizontalCenterOffset: -220
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pointSize: 12
                    anchors.topMargin: 25
                }

                CustomButton {
                    id: showPerformanceBtn
                    width: 160
                    opacity: 0.5
                    text: qsTr("Show performance")
                    anchors.top: fromSessionLabel.bottom
                    anchors.bottom: parent.bottom
                    font.pointSize: 12
                    anchors.bottomMargin: 5
                    anchors.topMargin: 25
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: false
                    colorMouseOver: "#4891d9"
                    onClicked: {
                        performanceResults.visible = true
                        backendSerialPort.updatePerformanceGraph(fromComboBox.currentText, toComboBox.currentText)
                    }
                }

                Rectangle {
                    id: pathContainer
                    width: 400
                    height: 20
                    color: "#474891d9"
                    radius: 5
                    anchors.verticalCenter: pathLabel.verticalCenter
                    anchors.left: pathLabel.right
                    anchors.leftMargin: 15

                    Text {
                        id: pathText
                        color: "#ffffff"
                        text: qsTr("")
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        clip: true
                        anchors.leftMargin: 10
                        font.pointSize: 12
                    }
                }

                TopBarButton {
                    id: pathBtn
                    width: 25
                    height: 25
                    anchors.verticalCenter: pathLabel.verticalCenter
                    anchors.left: pathContainer.right
                    btnColorClicked: "#ffe872"
                    btnColorMouseOver: "#ffe9a2"
                    btnColorDefaul: "#f8d775"
                    anchors.leftMargin: 10
                    btnIconSource: "../../images/svg_images/open_icon.svg"
                    radiousValue: 5
                    onClicked: backendSerialPort.openDirectory("performance")
                }

                ComboBox {
                    id: subjectComboBox
                    width: 200
                    opacity: 0.5
                    anchors.verticalCenter: subjectLabel.verticalCenter
                    anchors.left: subjectLabel.right
                    enabled: false
                    anchors.leftMargin: 15
                    model: ListModel{
                        id: subjectList
                    }
                    onCurrentTextChanged: {
                        if (subjectComboBox.currentText != ""){
                            backendSerialPort.getPerformanceValues(subjectComboBox.currentText, pathText.text)
                        }
                    }
                }

                ComboBox {
                    id: fromComboBox
                    width: 60
                    opacity: 0.5
                    anchors.verticalCenter: fromSessionLabel.verticalCenter
                    anchors.left: fromSessionLabel.right
                    enabled: false
                    anchors.leftMargin: 15
                    model: ListModel{
                        id: fromList
                    }
                }

                Label {
                    id: toLabel
                    color: "#ffffff"
                    text: qsTr("to:")
                    anchors.verticalCenter: fromSessionLabel.verticalCenter
                    anchors.left: fromComboBox.right
                    font.pointSize: 12
                    anchors.verticalCenterOffset: 0
                    anchors.leftMargin: 15
                }

                ComboBox {
                    id: toComboBox
                    width: 60
                    opacity: 0.5
                    anchors.verticalCenter: fromSessionLabel.verticalCenter
                    anchors.left: toLabel.right
                    enabled: false
                    anchors.leftMargin: 10
                    model: ListModel{
                        id: toList
                    }
                }
            }
        }

        Rectangle {
            id: performanceResults
            visible: false
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: performanceBody.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.topMargin: 0
            anchors.rightMargin: 0
            anchors.leftMargin: 0

            ChartView {
                id: performanceChart
                visible: true
                anchors.fill: parent
                ValuesAxis {
                    id: axisYperformance
                    min: 0
                    max: 10
                }

                BarCategoryAxis {
                    id: performanceCategories
                    categories: ["Session 1", "Session 2"]
                }

                BarSeries {
                    id: performanceSeries
                    name: "BarSeries"
                    axisY: axisYperformance
                    axisX: performanceCategories
                    BarSet {
                        id: barSetPerformance
                        label: "EMG Threshold"
                        values: [24.6, 25.9]
                    }
                }
            }
        }
    }

    Connections{
        target: backendSerialPort

        function onSetPerformancePath(path, listDir){
            subjectComboBox.enabled = true
            subjectComboBox.opacity = 1
            for (var i = 0; i < listDir.length; i++)  {
                subjectList.append({text: listDir[i]})
            }
            pathText.text = path
        }

        function onSetPerformanceRange(maxVal, maxRange){
            //axisYperformance.max = maxRange
            maxRangePerformance = maxRange
            fromComboBox.enabled = true
            fromComboBox.opacity = 1
            toComboBox.enabled = true
            toComboBox.opacity = 1
            fromList.clear()
            toList.clear()
            for (var i = 0; i < maxVal; i++)  {
                fromList.append({text: i + 1})
                toList.append({text: i + 1})
            }
            fromComboBox.currentIndex = 0
            toComboBox.currentIndex = maxVal - 1
            showPerformanceBtn.enabled = true
            showPerformanceBtn.opacity = 1
            showPerformanceBtn.colorMouseOver = "#55AAFF"
        }

        function onSetPerformanceGraph(valList, categoriesVal){
            console.log(valList)
            console.log(categoriesVal)
            axisYperformance.max = maxRangePerformance
            performanceCategories.categories = categoriesVal
            barSetPerformance.values = valList
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:800}
}
##^##*/
