import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import QtCharts 2.0
import "../controls"

Item {

    property color colorDefaultBlueButton: "#4891d9"
    property color colorMouseOverBlueButton: "#55AAFF"
    property color colorDefaultGreenButton: "#48d982"
    property color colorMouseOverGreenButton: "#55ff94"
    property color colorDefaultRedButton: "#d94848"
    property color colorMouseOverRedButton: "#ff5555"
    property int actionSelected: 0
    property int secondsTimer1: 0
    property int secondsTimer2: 0
    property int minutesTimer: 0
    property bool isEmgCalibrationDone: false
    property double thresholdEMG: 1.0
    visible: true


    Timer{
        id: actionTimer
        interval: actionDurationSlider.value * 1000 + 500
        running: false
        repeat: false
        onTriggered: {
            showTimer.running = false
            graphTimer.running = false
            backendSerialPort.runAction(5, 0, 0, 0, 0, 0)
            actionTimer.activateActions()
            actionTimer.restartCounter()
        }

        function restartCounter(){
            secondsTimer1 = 0
            secondsTimer2 = 0
            minutesTimer = 0
        }

        function activateActions(){
            actionTimer.enableParam(true)
            durationRow.visible = true
            actionTimer.updateStopbtn(false)
            actionTimer.updateStartbtn(true)
            switch (actionSelected){
                case 1:
                    actionTimer.updateEMGbtn(true)
                    break
                case 2:
                    actionTimer.updateAnglebtn(true)
                    break
                case 3:
                    actionTimer.updateFESbtn(true)
                    stimulationRow.visible = true
                    break
                case 4:
                    actionTimer.updateTherapybtn(true)
                    stimulationRow.visible = true
                    therapyRow.visible = true
                    break
            }
        }

        function enableParam(isEnabled){
            durationRow.enabled = isEnabled
            stimulationRow.enabled = isEnabled
            therapyRow.enabled = isEnabled
        }

        function updateEMGbtn(isEnabled){
            if (!isEnabled){
                emgCalibrationBtn.enabled = false
                emgCalibrationBtn.opacity = 0.5
                emgCalibrationBtn.colorMouseOver = colorDefaultBlueButton
            }else{
                emgCalibrationBtn.enabled = true
                emgCalibrationBtn.opacity = 1
                emgCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
            }
        }

        function updateAnglebtn(isEnabled){
            if (!isEnabled){
                angleCalibrationBtn.enabled = false
                angleCalibrationBtn.opacity = 0.5
                angleCalibrationBtn.colorMouseOver = colorDefaultBlueButton
            }else{
                angleCalibrationBtn.enabled = true
                angleCalibrationBtn.opacity = 1
                angleCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
            }
        }

        function updateFESbtn(isEnabled){
            if (!isEnabled){
                fesCalibrationBtn.enabled = false
                fesCalibrationBtn.opacity = 0.5
                fesCalibrationBtn.colorMouseOver = colorDefaultBlueButton
            }else{
                fesCalibrationBtn.enabled = true
                fesCalibrationBtn.opacity = 1
                fesCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
            }
        }

        function updateTherapybtn(isEnabled){
            if (!isEnabled){
                therapyBtn.enabled = false
                therapyBtn.opacity = 0.5
                therapyBtn.colorMouseOver = colorDefaultGreenButton
            }else{
                therapyBtn.enabled = true
                therapyBtn.opacity = 1
                therapyBtn.colorMouseOver = colorMouseOverGreenButton
            }
        }

        function updateStopbtn(isEnabled){
            if (!isEnabled){
                stopBtn.enabled = false
                stopBtn.opacity = 0.5
                stopBtn.colorMouseOver = colorDefaultRedButton
            }else{
                stopBtn.enabled = true
                stopBtn.opacity = 1
                stopBtn.colorMouseOver = colorMouseOverRedButton
            }
        }

        function updateStartbtn(isEnabled){
            if (!isEnabled){
                startBtn.enabled = false
                startBtn.opacity = 0.5
                startBtn.colorMouseOver = colorDefaultGreenButton
            }else{
                startBtn.enabled = true
                startBtn.opacity = 1
                startBtn.colorMouseOver = colorMouseOverGreenButton
            }
        }
    }



    Timer{
        id: showTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            if (secondsTimer1 == 5 && secondsTimer2 == 9){
                minutesTimer++
                secondsTimer1 = 0
                secondsTimer2 = 0
            } else if(secondsTimer2 == 9){
                secondsTimer1++
                secondsTimer2 = 0
            } else{
                secondsTimer2++
            }
            showTimer.controlGraphs()
        }

        function controlGraphs(){
            if (secondsTimer1 >= 1 || minutesTimer >= 1){
                axisXemg.min++
                axisXemg.max++
                axisXangle.min++
                axisXangle.max++
                axisXfes.min++
                axisXfes.max++
            }
        }
    }

    Timer{
        id: graphTimer
        interval: 250
        running: false
        repeat: true
        onTriggered: {
            backendSerialPort.getEMGValues(chartEMG.series("EMG"))
            backendSerialPort.getAngleValues(chartAngle.series("Angle"))
            backendSerialPort.getFESValues(chartFES.series("FES"))
        }
    }


    Rectangle {
        id: mainContainer
        color: "#2c313c"
        anchors.fill: parent

        Rectangle {
            id: graphsContainer
            color: "#00000000"
            anchors.left: scopeContainer.right
            anchors.right: parent.right
            anchors.top: actionsContainer.bottom
            anchors.bottom: parent.bottom
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.rightMargin: 0


            ChartView{
                id: chartEMG
                height: graphsContainer.height/3
                visible: true
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                legend.alignment: Qt.AlignLeft
                margins.bottom: 2
                margins.top: 2
                margins.right: 2
                margins.left: 2
                antialiasing: true

                ValuesAxis{
                    id: axisXemg
                    min: 10 - xAxisSliderEMG.value
                    max: 10
                }

                ValuesAxis{
                    id: axisYemg
                    min: yValueMinLabelEMG.text
                    max: yValueMaxLabelEMG.text
                }

                LineSeries{
                    id: lineSeriesEMG
                    name: "EMG"
                    axisX: axisXemg
                    axisY: axisYemg
                }

                LineSeries{
                    id: lineSeriesEMGThreshold
                    name: "EMG_threshold"
                    axisX: axisXemg
                    axisY: axisYemg
                }
            }

            ChartView {
                id: chartAngle
                height: graphsContainer.height/3
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: chartEMG.bottom
                anchors.topMargin: 0
                legend.alignment: Qt.AlignLeft
                margins.bottom: 2
                margins.top: 2
                margins.right: 2
                margins.left: 2
                antialiasing: true
                ValuesAxis {
                    id: axisXangle
                    min: 10 - xAxisSliderAngle.value
                    max: 10
                }

                ValuesAxis {
                    id: axisYangle
                    min: yValueMinLabelAngle.text
                    max: yValueMaxLabelAngle.text
                }

                LineSeries {
                    id: lineSeriesAngle
                    name: "Angle"
                    axisY: axisYangle
                    axisX: axisXangle
                }
                anchors.rightMargin: 0
            }

            ChartView {
                id: chartFES
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: chartAngle.bottom
                anchors.bottom: parent.bottom
                anchors.topMargin: 0
                legend.alignment: Qt.AlignLeft
                margins.bottom: 2
                margins.top: 2
                margins.right: 2
                margins.left: 2
                antialiasing: true
                ValuesAxis {
                    id: axisXfes
                    min: 10 - xAxisSliderFES.value
                    max: 10
                }

                ValuesAxis {
                    id: axisYfes
                    min: yValueMinLabelFES.text
                    max: yValueMaxLabelFES.text
                }

                LineSeries {
                    id: lineSeriesFES
                    name: "FES"
                    axisY: axisYfes
                    axisX: axisXfes
                }
                anchors.rightMargin: 0
            }

            Component.onCompleted: {
                backendSerialPort.getEMGValues(chartEMG.series("EMG"))
                backendSerialPort.getAngleValues(chartAngle.series("Angle"))
                backendSerialPort.getFESValues(chartFES.series("FES"))
            }
        }

        Rectangle {
            id: scopeContainer
            width: 200
            color: "#00000000"
            anchors.left: parent.left
            anchors.top: actionsContainer.bottom
            anchors.bottom: parent.bottom
            clip: true
            anchors.leftMargin: 0
            anchors.topMargin: 0
            anchors.bottomMargin: 0

            Column {
                id: column
                anchors.fill: parent

                Label {
                    id: graphsLabel
                    color: "#ffffff"
                    text: qsTr("Graph Scope")
                    anchors.left: parent.left
                    anchors.top: parent.top
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.leftMargin: 20
                    font.bold: true
                    font.pointSize: 20
                    anchors.topMargin: 10
                }



                function resizeGraphView(){
                    if (chartAngle.visible && chartEMG.visible && chartFES.visible){
                        chartAngle.height = graphsContainer.height/3
                        chartEMG.height = graphsContainer.height/3
                        chartFES.height = graphsContainer.height/3
                    } else if (chartAngle.visible && chartEMG.visible){
                        chartAngle.height = graphsContainer.height/2
                        chartEMG.height = graphsContainer.height/2
                        chartFES.height = 0
                    } else if (chartEMG.visible && chartFES.visible){
                        chartEMG.height = graphsContainer.height/2
                        chartFES.height = graphsContainer.height/2
                        chartAngle.height = 0
                    } else if (chartAngle.visible && chartFES.visible){
                        chartAngle.height = graphsContainer.height/2
                        chartFES.height = graphsContainer.height/2
                        chartEMG.height = 0
                    } else if (chartAngle.visible){
                        chartAngle.height = graphsContainer.height
                        chartFES.height = 0
                        chartEMG.height = 0
                    } else if (chartEMG.visible){
                        chartEMG.height = graphsContainer.height
                        chartFES.height = 0
                        chartAngle.height = 0
                    } else if (chartFES.visible){
                        chartFES.height = graphsContainer.height
                        chartAngle.height = 0
                        chartEMG.height = 0
                    }
                }

                TabBar {
                    id: tabBar
                    visible: true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: graphsLabel.bottom
                    currentIndex: 0
                    anchors.topMargin: 20
                    anchors.rightMargin: 5
                    anchors.leftMargin: 5
                    TabButton {
                        id: emgTab
                        text: "EMG"
                        width: tabBar.width / 3
                        visible: true
                    }
                    TabButton {
                        id: angleTab
                        text: "Angle"
                        width: tabBar.width / 3
                    }
                    TabButton {
                        id: fesTab
                        text: "FES"
                        width: tabBar.width / 3
                    }
                }

                StackLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: tabBar.bottom
                    anchors.rightMargin: 5
                    anchors.leftMargin: 5
                    anchors.topMargin: 20
                    currentIndex: tabBar.currentIndex
                    Item {
                        id: emgStackLayout

                        Rectangle {
                            id: emgGraphScopeContainer
                            x: 0
                            height: 300
                            color: "#00000000"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.rightMargin: 0
                            anchors.leftMargin: 0

                            Slider {
                                id: xAxisSliderEMG
                                x: 20
                                width: 120
                                anchors.top: xAxisEMGLabel.bottom
                                anchors.horizontalCenterOffset: -20
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.topMargin: 15
                                stepSize: 1
                                snapMode: RangeSlider.SnapAlways
                                layer.enabled: false
                                to: 10
                                from: 1
                                value: 10
                            }

                            Label {
                                id: xValueLabelEMG
                                x: 149
                                y: 80
                                color: "#ffffff"
                                text: xAxisSliderEMG.value + qsTr(" sec")
                                anchors.verticalCenter: xAxisSliderEMG.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignTop
                                anchors.rightMargin: 10
                                anchors.verticalCenterOffset: -2
                                font.pointSize: 11
                            }

                            Label {
                                id: yValueMaxLabelEMG
                                x: 164
                                y: 174
                                opacity: 1
                                color: "#ffffff"
                                text: yAxisRangeSliderEMG.second.value.toFixed(0)
                                anchors.verticalCenter: yAxisRangeSliderEMG.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignTop
                                anchors.verticalCenterOffset: -15
                                font.pointSize: 11
                                anchors.rightMargin: 20
                            }

                            RangeSlider {
                                id: yAxisRangeSliderEMG
                                x: 20
                                width: 160
                                opacity: 1
                                visible: true
                                anchors.top: yAxisEMGLabel.bottom
                                snapMode: RangeSlider.SnapOnRelease
                                stepSize: 1
                                to: 1100
                                from: -100
                                orientation: Qt.Horizontal
                                anchors.topMargin: 20
                                anchors.horizontalCenterOffset: 0
                                anchors.horizontalCenter: parent.horizontalCenter
                                second.value: 50
                                first.value: 0
                            }

                            Label {
                                id: yValueMinLabelEMG
                                x: 20
                                y: 174
                                opacity: 1
                                color: "#ffffff"
                                text: yAxisRangeSliderEMG.first.value.toFixed(0)
                                anchors.verticalCenter: yAxisRangeSliderEMG.verticalCenter
                                anchors.left: parent.left
                                verticalAlignment: Text.AlignTop
                                anchors.leftMargin: 20
                                anchors.verticalCenterOffset: -15
                                font.pointSize: 11
                            }

                            CheckBox {
                                id: showGraphEMGCheckBox
                                anchors.verticalCenter: showGraphEMGLabel.verticalCenter
                                anchors.left: showGraphEMGLabel.right
                                checked: true
                                anchors.verticalCenterOffset: 2
                                anchors.leftMargin: 20
                                onCheckStateChanged: {
                                    if(checked){
                                        chartEMG.visible = true
                                        column.resizeGraphView()
                                    }else{
                                        chartEMG.visible = false
                                        column.resizeGraphView()
                                    }
                                }
                            }

                            CheckBox {
                                id: autoAdjustEMGCheckBox
                                anchors.verticalCenter: autoAdjustEMGLabel.verticalCenter
                                anchors.left: autoAdjustEMGLabel.right
                                checked: false
                                anchors.verticalCenterOffset: 2
                                anchors.leftMargin: 21
                                onCheckStateChanged: {
                                    if(checked){
                                        yAxisRangeSliderEMG.enabled = false
                                        yAxisRangeSliderEMG.opacity = 0.2
                                        yValueMaxLabelEMG.opacity = 0.2
                                        yValueMinLabelEMG.opacity = 0.2
                                        backendSerialPort.getPickValues(1)
                                    }else{
                                        yAxisRangeSliderEMG.enabled = true
                                        yAxisRangeSliderEMG.opacity = 1
                                        yValueMaxLabelEMG.opacity = 1
                                        yValueMinLabelEMG.opacity = 1
                                        backendSerialPort.setNotAdjusted(1)
                                    }
                                }
                            }

                            Label {
                                id: xAxisEMGLabel
                                color: "#ffffff"
                                text: qsTr("X axis range (seconds):")
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.topMargin: 5
                                anchors.leftMargin: 5
                                font.pointSize: 12
                            }

                            Label {
                                id: yAxisEMGLabel
                                color: "#ffffff"
                                text: qsTr("Y axis range:")
                                anchors.left: parent.left
                                anchors.top: xAxisSliderEMG.bottom
                                anchors.leftMargin: 5
                                font.pointSize: 12
                                anchors.topMargin: 15
                            }

                            Label {
                                id: autoAdjustEMGLabel
                                color: "#ffffff"
                                text: qsTr("Auto-adjust")
                                anchors.left: parent.left
                                anchors.top: yAxisRangeSliderEMG.bottom
                                anchors.topMargin: 15
                                anchors.leftMargin: 5
                                font.pointSize: 12
                            }

                            Label {
                                id: showGraphEMGLabel
                                color: "#ffffff"
                                text: qsTr("Show graph")
                                anchors.left: parent.left
                                anchors.top: autoAdjustEMGLabel.bottom
                                anchors.topMargin: 15
                                anchors.leftMargin: 5
                                font.pointSize: 12
                            }
                        }
                    }
                    Item {
                        id: angleStackLayout

                        Rectangle {
                            id: angleGraphScopeContainer
                            x: 0
                            height: 300
                            color: "#00000000"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.rightMargin: 0
                            anchors.leftMargin: 0

                            CheckBox {
                                id: showGraphAngleCheckBox
                                visible: true
                                anchors.verticalCenter: showGraphAngleLabel.verticalCenter
                                anchors.left: showGraphAngleLabel.right
                                anchors.leftMargin: 20
                                anchors.verticalCenterOffset: 2
                                checked: true
                                onCheckStateChanged: {
                                    if(checked){
                                        chartAngle.visible = true
                                        column.resizeGraphView()
                                    }else{
                                        chartAngle.visible = false
                                        column.resizeGraphView()
                                    }
                                }
                            }

                            RangeSlider {
                                id: yAxisRangeSliderAngle
                                x: 20
                                width: 160
                                opacity: 1
                                visible: true
                                anchors.top: yAxisAngleLabel.bottom
                                second.value: 90
                                orientation: Qt.Horizontal
                                first.value: 0
                                anchors.horizontalCenterOffset: 0
                                snapMode: RangeSlider.SnapOnRelease
                                stepSize: 1
                                anchors.topMargin: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                to: 1150
                                from: 0
                            }

                            Slider {
                                id: xAxisSliderAngle
                                x: 20
                                width: 120
                                visible: true
                                anchors.top: xAxisAngleLabel.bottom
                                layer.enabled: false
                                anchors.horizontalCenterOffset: -20
                                snapMode: RangeSlider.SnapAlways
                                stepSize: 1
                                value: 10
                                anchors.topMargin: 15
                                anchors.horizontalCenter: parent.horizontalCenter
                                to: 10
                                from: 1
                            }

                            Label {
                                id: xValueLabelAngle
                                x: 149
                                y: 80
                                visible: true
                                color: "#ffffff"
                                text: xAxisSliderAngle.value + qsTr(" sec")
                                anchors.verticalCenter: xAxisSliderAngle.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignTop
                                anchors.rightMargin: 10
                                font.pointSize: 11
                                anchors.verticalCenterOffset: -2
                            }

                            Label {
                                id: yValueMaxLabelAngle
                                x: 164
                                opacity: 1
                                visible: true
                                color: "#ffffff"
                                text: yAxisRangeSliderAngle.second.value.toFixed(0)
                                anchors.verticalCenter: yAxisRangeSliderAngle.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignTop
                                font.pointSize: 11
                                anchors.rightMargin: 20
                                anchors.verticalCenterOffset: -15
                            }

                            Label {
                                id: yValueMinLabelAngle
                                x: 20
                                opacity: 1
                                visible: true
                                color: "#ffffff"
                                text: yAxisRangeSliderAngle.first.value.toFixed(0)
                                anchors.verticalCenter: yAxisRangeSliderAngle.verticalCenter
                                anchors.left: parent.left
                                verticalAlignment: Text.AlignTop
                                font.pointSize: 11
                                anchors.leftMargin: 20
                                anchors.verticalCenterOffset: -15
                            }

                            CheckBox {
                                id: autoAdjustAngleCheckBox
                                visible: true
                                anchors.verticalCenter: autoAdjustAngleLabel.verticalCenter
                                anchors.left: autoAdjustAngleLabel.right
                                enabled: false
                                checked: false
                                anchors.leftMargin: 21
                                anchors.verticalCenterOffset: 2
                                onCheckStateChanged: {
                                    if(checked){
                                        yAxisRangeSliderAngle.enabled = false
                                        yAxisRangeSliderAngle.opacity = 0.2
                                        yValueMaxLabelAngle.opacity = 0.2
                                        yValueMinLabelAngle.opacity = 0.2
                                        backendSerialPort.getPickValues(2)
                                    }else{
                                        yAxisRangeSliderAngle.enabled = true
                                        yAxisRangeSliderAngle.opacity = 1
                                        yValueMaxLabelAngle.opacity = 1
                                        yValueMinLabelAngle.opacity = 1
                                        backendSerialPort.setNotAdjusted(2)
                                    }
                                }
                            }

                            Label {
                                id: xAxisAngleLabel
                                color: "#ffffff"
                                text: qsTr("X axis range (seconds):")
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.topMargin: 5
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }

                            Label {
                                id: yAxisAngleLabel
                                color: "#ffffff"
                                text: qsTr("Y axis range:")
                                anchors.left: parent.left
                                anchors.top: xAxisSliderAngle.bottom
                                anchors.topMargin: 15
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }

                            Label {
                                id: autoAdjustAngleLabel
                                color: "#ffffff"
                                text: qsTr("Auto-adjust")
                                anchors.left: parent.left
                                anchors.top: yAxisRangeSliderAngle.bottom
                                anchors.topMargin: 15
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }

                            Label {
                                id: showGraphAngleLabel
                                color: "#ffffff"
                                text: qsTr("Show graph")
                                anchors.left: parent.left
                                anchors.top: autoAdjustAngleLabel.bottom
                                anchors.topMargin: 15
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }
                        }
                    }
                    Item {
                        id: fesStackLayout

                        Rectangle {
                            id: fesGraphScopeContainer
                            x: 0
                            height: 300
                            color: "#00000000"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            anchors.rightMargin: 0
                            anchors.leftMargin: 0

                            CheckBox {
                                id: showGraphFESCheckBox
                                visible: true
                                anchors.verticalCenter: showGraphFESLabel.verticalCenter
                                anchors.left: showGraphFESLabel.right
                                anchors.leftMargin: 20
                                anchors.verticalCenterOffset: 2
                                checked: true
                                onCheckStateChanged: {
                                    if(checked){
                                        chartFES.visible = true
                                        column.resizeGraphView()
                                    }else{
                                        chartFES.visible = false
                                        column.resizeGraphView()
                                    }
                                }
                            }

                            RangeSlider {
                                id: yAxisRangeSliderFES
                                x: 20
                                width: 160
                                opacity: 1
                                visible: true
                                anchors.top: yAxisFESLabel.bottom
                                second.value: 50
                                orientation: Qt.Horizontal
                                first.value: 0
                                anchors.horizontalCenterOffset: 0
                                snapMode: RangeSlider.SnapOnRelease
                                stepSize: 1
                                anchors.topMargin: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                to: 1000
                                from: -100
                            }

                            Slider {
                                id: xAxisSliderFES
                                x: 20
                                width: 120
                                visible: true
                                anchors.top: xAxisFESLabel.bottom
                                layer.enabled: false
                                anchors.horizontalCenterOffset: -20
                                snapMode: RangeSlider.SnapAlways
                                stepSize: 1
                                value: 10
                                anchors.topMargin: 15
                                anchors.horizontalCenter: parent.horizontalCenter
                                to: 10
                                from: 1
                            }

                            Label {
                                id: xValueLabelFES
                                x: 149
                                y: 80
                                visible: true
                                color: "#ffffff"
                                text: xAxisSliderFES.value + qsTr(" sec")
                                anchors.verticalCenter: xAxisSliderFES.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignTop
                                anchors.rightMargin: 10
                                font.pointSize: 11
                                anchors.verticalCenterOffset: -2
                            }

                            Label {
                                id: yValueMaxLabelFES
                                x: 164
                                opacity: 1
                                visible: true
                                color: "#ffffff"
                                text: yAxisRangeSliderFES.second.value.toFixed(0)
                                anchors.verticalCenter: yAxisRangeSliderFES.verticalCenter
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignTop
                                anchors.rightMargin: 20
                                font.pointSize: 11
                                anchors.verticalCenterOffset: -15
                            }

                            Label {
                                id: yValueMinLabelFES
                                x: 20
                                opacity: 1
                                visible: true
                                color: "#ffffff"
                                text: yAxisRangeSliderFES.first.value.toFixed(0)
                                anchors.verticalCenter: yAxisRangeSliderFES.verticalCenter
                                anchors.left: parent.left
                                verticalAlignment: Text.AlignTop
                                font.pointSize: 11
                                anchors.leftMargin: 20
                                anchors.verticalCenterOffset: -15
                            }

                            CheckBox {
                                id: autoAdjustFESCheckBox
                                visible: true
                                anchors.verticalCenter: autoAdjustFESLabel.verticalCenter
                                anchors.left: autoAdjustFESLabel.right
                                checked: false
                                anchors.leftMargin: 21
                                anchors.verticalCenterOffset: 2
                                onCheckStateChanged: {
                                    if(checked){
                                        yAxisRangeSliderFES.enabled = false
                                        yAxisRangeSliderFES.opacity = 0.2
                                        yValueMaxLabelFES.opacity = 0.2
                                        yValueMinLabelFES.opacity = 0.2
                                        backendSerialPort.getPickValues(3)
                                    }else{
                                        yAxisRangeSliderFES.enabled = true
                                        yAxisRangeSliderFES.opacity = 1
                                        yValueMaxLabelFES.opacity = 1
                                        yValueMinLabelFES.opacity = 1
                                        backendSerialPort.setNotAdjusted(3)
                                    }
                                }
                            }

                            Label {
                                id: xAxisFESLabel
                                visible: true
                                color: "#ffffff"
                                text: qsTr("X axis range (seconds):")
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.topMargin: 5
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }

                            Label {
                                id: yAxisFESLabel
                                color: "#ffffff"
                                text: qsTr("Y axis range:")
                                anchors.left: parent.left
                                anchors.top: xAxisSliderFES.bottom
                                anchors.topMargin: 15
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }

                            Label {
                                id: autoAdjustFESLabel
                                color: "#ffffff"
                                text: qsTr("Auto-adjust")
                                anchors.left: parent.left
                                anchors.top: yAxisRangeSliderFES.bottom
                                anchors.topMargin: 15
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }

                            Label {
                                id: showGraphFESLabel
                                color: "#ffffff"
                                text: qsTr("Show graph")
                                anchors.left: parent.left
                                anchors.top: autoAdjustFESLabel.bottom
                                anchors.topMargin: 15
                                font.pointSize: 12
                                anchors.leftMargin: 5
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: actionsContainer
            height: 80
            color: "#00000000"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 0

            PropertyAnimation{
                id: animationDurationActions
                target: actionsContainer
                property: "height"
                to: if(actionsContainer.height == 80) return 130; else return 80
                duration: 50
                easing.type: Easing.InOutQuint
                onStopped: column.resizeGraphView()
            }

            PropertyAnimation{
                id: animationStimulationActions
                target: actionsContainer
                property: "height"
                to: if(actionsContainer.height == 80) return 180; else return 80
                duration: 50
                easing.type: Easing.InOutQuint
                onStopped: column.resizeGraphView()
            }

            PropertyAnimation{
                id: animationTherapyActions
                target: actionsContainer
                property: "height"
                to: if(actionsContainer.height == 80) return 230; else return 80
                duration: 50
                easing.type: Easing.InOutQuint
                onStopped: column.resizeGraphView()
            }

            PropertyAnimation{
                id: animationOriginalState
                target: actionsContainer
                property: "height"
                to: 80
                duration: 50
                easing.type: Easing.InOutQuint
                onStopped: column.resizeGraphView()
            }

            Row {
                id: row
                width: 640
                height: 80
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter

                function disableButtons(idx){
                    if (idx != 1){
                        if (emgCalibrationBtn.enabled == true){
                            emgCalibrationBtn.enabled = false
                            emgCalibrationBtn.opacity = 0.5
                            emgCalibrationBtn.colorMouseOver = colorDefaultBlueButton
                        }else{
                            emgCalibrationBtn.enabled = true
                            emgCalibrationBtn.opacity = 1
                            emgCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
                        }
                    }
                    if (idx != 2){
                        if (angleCalibrationBtn.enabled == true){
                            angleCalibrationBtn.enabled = false
                            angleCalibrationBtn.opacity = 0.5
                            angleCalibrationBtn.colorMouseOver = colorDefaultBlueButton
                        }else{
                            angleCalibrationBtn.enabled = true
                            angleCalibrationBtn.opacity = 1
                            angleCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
                        }
                    }
                    if (idx != 3){
                        if (fesCalibrationBtn.enabled == true){
                            fesCalibrationBtn.enabled = false
                            fesCalibrationBtn.opacity = 0.5
                            fesCalibrationBtn.colorMouseOver = colorDefaultBlueButton
                        }else{
                            fesCalibrationBtn.enabled = true
                            fesCalibrationBtn.opacity = 1
                            fesCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
                        }
                    }
                    if (idx != 4 && isEmgCalibrationDone){
                        if (therapyBtn.enabled == true){
                            therapyBtn.enabled = false
                            therapyBtn.opacity = 0.5
                            therapyBtn.colorMouseOver = colorDefaultGreenButton
                        }else{
                            therapyBtn.enabled = true
                            therapyBtn.opacity = 1
                            therapyBtn.colorMouseOver = colorMouseOverGreenButton
                        }
                    }
                }

                function enableButtons(){
                    emgCalibrationBtn.enabled = true
                    angleCalibrationBtn.enabled = true
                    fesCalibrationBtn.enabled = true
                    emgCalibrationBtn.opacity = 1
                    angleCalibrationBtn.opacity = 1
                    fesCalibrationBtn.opacity = 1
                    emgCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
                    angleCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
                    fesCalibrationBtn.colorMouseOver = colorMouseOverBlueButton
                }

                CustomButton {
                    id: emgCalibrationBtn
                    width: 105
                    opacity: 0.5
                    text: qsTr("EMG Calibration")
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    enabled: false
                    colorMouseOver: "#4891d9"
                    anchors.bottomMargin: 20
                    anchors.topMargin: 20
                    anchors.leftMargin: 20
                    onPressed: {
                        if (durationRow.visible == true) durationRow.visible = false; else durationRow.visible = true
                        animationDurationActions.running = true
                        row.disableButtons(1)
                        actionSelected = 1
                    }
                }

                CustomButton {
                    id: angleCalibrationBtn
                    width: 105
                    opacity: 0.5
                    text: qsTr("Angle Calibration")
                    anchors.left: emgCalibrationBtn.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    enabled: false
                    colorMouseOver: "#4891d9"
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 20
                    onPressed: {
                        if (durationRow.visible == true) durationRow.visible = false; else durationRow.visible = true
                        animationDurationActions.running = true
                        row.disableButtons(2)
                        actionSelected = 2
                    }
                }

                CustomButton {
                    id: fesCalibrationBtn
                    width: 105
                    opacity: 0.5
                    text: qsTr("FES Calibration")
                    anchors.left: angleCalibrationBtn.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    colorMouseOver: "#4891d9"
                    enabled: false
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 20
                    onPressed: {
                        if (durationRow.visible == true) durationRow.visible = false; else durationRow.visible = true
                        if (stimulationRow.visible == true) stimulationRow.visible = false; else stimulationRow.visible = true
                        animationStimulationActions.running = true
                        row.disableButtons(3)
                        actionSelected = 3
                    }
                }

                CustomButton {
                    id: therapyBtn
                    width: 105
                    opacity: 0.5
                    text: qsTr("Run Therapy")
                    anchors.left: fesCalibrationBtn.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    enabled: false
                    colorPressed: "#3fbd5a"
                    colorMouseOver: "#48d982"
                    colorDefault: "#48d982"
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    anchors.leftMargin: 20
                    onPressed: {
                        if (durationRow.visible == true) durationRow.visible = false; else durationRow.visible = true
                        if (stimulationRow.visible == true) stimulationRow.visible = false; else stimulationRow.visible = true
                        if (therapyRow.visible == true) therapyRow.visible = false; else therapyRow.visible = true
                        animationTherapyActions.running = true
                        row.disableButtons(4)
                        actionSelected = 4
                    }
                }

                CustomButton {
                    id: stopBtn
                    opacity: 0.5
                    text: qsTr("Stop")
                    anchors.left: therapyBtn.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    hoverEnabled: true
                    enabled: false
                    colorPressed: "#bd3f3f"
                    colorMouseOver: "#d94848"
                    colorDefault: "#d94848"
                    anchors.bottomMargin: 20
                    anchors.rightMargin: 20
                    anchors.leftMargin: 20
                    anchors.topMargin: 20
                    onPressed: {
                        actionTimer.running = false
                        showTimer.running = false
                        graphTimer.running = false
                        backendSerialPort.runAction(5, 0, 0, 0, 0, 0)
                        actionTimer.activateActions()
                        actionTimer.restartCounter()
                    }
                }
            }

            Rectangle {
                id: configActionsContainer
                width: 640
                color: "#311c5b97"
                border.color: "#00000000"
                border.width: 3
                anchors.top: row.bottom
                anchors.bottom: parent.bottom
                clip: false
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 0

                Column {
                    id: configActionsColumn
                    anchors.fill: parent

                    Row {
                        id: durationRow
                        height: 50
                        visible: false
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top

                        Label {
                            id: durationLabel
                            width: 120
                            color: "#ffffff"
                            text: qsTr("Duration:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            anchors.verticalCenterOffset: 0
                            anchors.leftMargin: 20
                            font.bold: false
                            font.pointSize: 16
                        }

                        Slider {
                            id: actionDurationSlider
                            width: 100
                            visible: true
                            anchors.verticalCenter: useStopLabel.verticalCenter
                            anchors.left: useStopLabel.right
                            stepSize: 1
                            to: 300
                            from: 1
                            anchors.leftMargin: 20
                            value: 5
                        }

                        Label {
                            id: actionDurationLabel
                            color: "#ffffff"
                            text: actionDurationSlider.value + qsTr(" sec")
                            anchors.verticalCenter: actionDurationSlider.verticalCenter
                            anchors.left: actionDurationSlider.right
                            font.pointSize: 11
                            anchors.leftMargin: 10
                        }

                        CheckBox {
                            id: useStopCheckBox
                            visible: true
                            text: qsTr("")
                            anchors.verticalCenter: durationLabel.verticalCenter
                            anchors.left: durationLabel.right
                            anchors.verticalCenterOffset: 2
                            anchors.leftMargin: 5
                        }

                        Label {
                            id: useStopLabel
                            width: 105
                            color: "#ffffff"
                            text: qsTr("Use 'Stop' button")
                            anchors.verticalCenter: useStopCheckBox.verticalCenter
                            anchors.left: useStopCheckBox.right
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 10
                            anchors.leftMargin: 5
                        }

                        CustomButton {
                            id: startBtn
                            width: 100
                            opacity: 1
                            visible: true
                            text: qsTr("Start")
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            font.pointSize: 10
                            font.bold: true
                            colorMouseOver: "#55ff94"
                            colorPressed: "#3fbd5a"
                            colorDefault: "#48d982"
                            anchors.rightMargin: 20
                            anchors.bottomMargin: 10
                            anchors.topMargin: 10
                            enabled: true
                            hoverEnabled: true
                            onPressed: {
                                durationRow.initializeGraphs()
                                durationRow.prepareAction()
                                actionTimer.running = true
                                showTimer.running = true
                                graphTimer.running = true
                            }
                        }

                        function initializeGraphs(){
                            backendSerialPort.cleanGraphs()
                            axisXemg.min = 0
                            axisXemg.max = 10
                            axisXangle.min = 0
                            axisXangle.max = 10
                            axisXfes.min = 0
                            axisXfes.max = 10
                            backendSerialPort.getEMGThreshold(chartEMG.series("EMG_threshold"), actionSelected)
                        }

                        function prepareAction(){
                            if (useStopCheckBox.checked){
                                stopBtn.enabled = true
                                stopBtn.opacity = 1
                                stopBtn.colorMouseOver = colorMouseOverRedButton
                            }
                            switch (actionSelected){
                            case 1:
                                emgCalibrationBtn.enabled = false
                                emgCalibrationBtn.opacity = 0.5
                                emgCalibrationBtn.colorMouseOver = colorDefaultBlueButton
                                isEmgCalibrationDone = true
                                break
                            case 2:
                                angleCalibrationBtn.enabled = false
                                angleCalibrationBtn.opacity = 0.5
                                angleCalibrationBtn.colorMouseOver = colorDefaultBlueButton
                                break
                            case 3:
                                fesCalibrationBtn.enabled = false
                                fesCalibrationBtn.opacity = 0.5
                                fesCalibrationBtn.colorMouseOver = colorDefaultBlueButton
                                break
                            case 4:
                                therapyBtn.enabled = false
                                therapyBtn.opacity = 0.5
                                therapyBtn.colorMouseOver = colorDefaultGreenButton
                                break
                            }
                            startBtn.enabled = false
                            startBtn.opacity = 0.5
                            startBtn.colorMouseOver = colorDefaultGreenButton
                            durationRow.disableConfigVariables()
                            backendSerialPort.runAction(actionSelected, onStimulationDurationSlider.value, freqStimulationDurationSlider.value, maxFlexAngleSlider.value, maxbuckSlider.value, emgThresholdSlider.value)
                        }

                        function disableConfigVariables(){
                            durationRow.enabled = false
                            stimulationRow.enabled = false
                            therapyRow.enabled = false
                        }
                    }

                    Row {
                        id: stimulationRow
                        height: 50
                        visible: false
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: durationRow.bottom
                        anchors.topMargin: 0

                        Label {
                            id: stimulationLabel
                            width: 120
                            color: "#ffffff"
                            text: qsTr("Stimulation:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            anchors.leftMargin: 20
                            font.pointSize: 16
                        }

                        Slider {
                            id: onStimulationDurationSlider
                            width: 100
                            visible: true
                            anchors.verticalCenter: stimulationLabel.verticalCenter
                            anchors.left: stimulationLabel.right
                            value: 300
                            anchors.leftMargin: 5
                            stepSize: 1
                            anchors.verticalCenterOffset: 10
                            to: 750
                            from: 1
                        }

                        Label {
                            id: onStimulationDurationLabel
                            color: "#ffffff"
                            text: onStimulationDurationSlider.value + qsTr(" us")
                            anchors.verticalCenter: onStimulationDurationSlider.verticalCenter
                            anchors.left: onStimulationDurationSlider.right
                            font.pointSize: 11
                            anchors.leftMargin: 10
                        }

                        Label {
                            id: onStateLabel
                            width: 60
                            color: "#ffffff"
                            text: qsTr("On State")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -9
                            font.bold: true
                            anchors.horizontalCenterOffset: 0
                            anchors.horizontalCenter: onStimulationDurationSlider.horizontalCenter
                            font.pointSize: 11
                        }

                        Slider {
                            id: freqStimulationDurationSlider
                            width: 100
                            visible: true
                            anchors.verticalCenter: stimulationLabel.verticalCenter
                            anchors.left: onStimulationDurationSlider.right
                            value: 50
                            anchors.leftMargin: 68
                            stepSize: 1
                            anchors.verticalCenterOffset: 10
                            to: 120
                            from: 1
                        }

                        Label {
                            id: freqStimulationDurationLabel
                            color: "#ffffff"
                            text: freqStimulationDurationSlider.value + qsTr(" Hz")
                            anchors.verticalCenter: freqStimulationDurationSlider.verticalCenter
                            anchors.left: freqStimulationDurationSlider.right
                            font.pointSize: 11
                            anchors.leftMargin: 10
                        }

                        Label {
                            id: frequencyLabel
                            width: 72
                            color: "#ffffff"
                            text: qsTr("Frequency")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -9
                            font.bold: true
                            font.pointSize: 11
                            anchors.horizontalCenter: freqStimulationDurationSlider.horizontalCenter
                            anchors.horizontalCenterOffset: 0
                        }

                        Slider {
                            id: maxFlexAngleSlider
                            width: 100
                            visible: true
                            anchors.verticalCenter: stimulationLabel.verticalCenter
                            anchors.left: freqStimulationDurationSlider.right
                            value: 75
                            anchors.leftMargin: 68
                            stepSize: 1
                            anchors.verticalCenterOffset: 10
                            to: 90
                            from: 1
                        }

                        Label {
                            id: maxFlexAngleValueLabel
                            color: "#ffffff"
                            text: maxFlexAngleSlider.value + qsTr(" º")
                            anchors.verticalCenter: maxFlexAngleSlider.verticalCenter
                            anchors.left: maxFlexAngleSlider.right
                            font.pointSize: 11
                            anchors.leftMargin: 10
                        }

                        Label {
                            id: maxFlexAngleLabel
                            width: 100
                            color: "#ffffff"
                            text: qsTr("maxFlexAngle")
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignLeft
                            anchors.verticalCenterOffset: -9
                            font.bold: true
                            font.pointSize: 11
                            anchors.horizontalCenter: maxFlexAngleSlider.horizontalCenter
                            anchors.horizontalCenterOffset: 0
                        }
                    }

                    Row {
                        id: therapyRow
                        height: 50
                        visible: false
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: stimulationRow.bottom
                        anchors.topMargin: 0

                        Label {
                            id: therapyLabel
                            width: 120
                            color: "#ffffff"
                            text: qsTr("Therapy:")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            font.bold: false
                            anchors.leftMargin: 20
                            font.pointSize: 16
                        }

                        Slider {
                            id: maxbuckSlider
                            width: 100
                            visible: true
                            anchors.verticalCenter: therapyLabel.verticalCenter
                            anchors.left: therapyLabel.right
                            value: 20
                            anchors.leftMargin: 5
                            stepSize: 1
                            anchors.verticalCenterOffset: 10
                            to: 32
                            from: 1
                        }

                        Label {
                            id: maxBuckValueLabel
                            color: "#ffffff"
                            text: maxbuckSlider.value + qsTr(" V")
                            anchors.verticalCenter: maxbuckSlider.verticalCenter
                            anchors.left: maxbuckSlider.right
                            font.pointSize: 11
                            anchors.leftMargin: 10
                        }

                        Label {
                            id: maxBuckLabel
                            width: 64
                            color: "#ffffff"
                            text: qsTr("maxBuck")
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -9
                            font.bold: true
                            font.pointSize: 11
                            anchors.horizontalCenter: maxbuckSlider.horizontalCenter
                            anchors.horizontalCenterOffset: 0
                        }

                        Slider {
                            id: emgThresholdSlider
                            width: 100
                            visible: true
                            anchors.verticalCenter: therapyLabel.verticalCenter
                            anchors.left: maxbuckSlider.right
                            enabled: false
                            value: 512
                            anchors.leftMargin: 68
                            stepSize: 1
                            anchors.verticalCenterOffset: 10
                            to: 1024
                            from: 1
                        }

                        Label {
                            id: emgThresholdValueLabel
                            color: "#ffffff"
                            text: emgThresholdSlider.value
                            anchors.verticalCenter: emgThresholdSlider.verticalCenter
                            anchors.left: emgThresholdSlider.right
                            font.pointSize: 11
                            anchors.leftMargin: 10
                        }

                        Label {
                            id: emgThresholdLabel
                            width: 190
                            color: "#ffffff"
                            text: qsTr("emgThreshold (calibrated)")
                            anchors.verticalCenter: parent.verticalCenter
                            enabled: true
                            anchors.verticalCenterOffset: -9
                            font.bold: true
                            font.pointSize: 11
                            anchors.horizontalCenter: emgThresholdSlider.horizontalCenter
                            anchors.horizontalCenterOffset: 25
                        }

                        CheckBox {
                            id: maxFlexCheckBox
                            width: 19
                            text: qsTr("")
                            anchors.verticalCenter: emgThresholdSlider.verticalCenter
                            anchors.left: emgThresholdValueLabel.right
                            anchors.verticalCenterOffset: -10
                            font.pointSize: 9
                            anchors.leftMargin: 40
                            onCheckStateChanged: backendSerialPort.updateEndFlexAngle(maxFlexCheckBox.checked)
                        }

                        Label {
                            id: flexAngleLabel
                            width: 104
                            color: "#ffffff"
                            text: qsTr("End with\nmaxFlexAngle")
                            anchors.verticalCenter: maxFlexCheckBox.verticalCenter
                            anchors.left: maxFlexCheckBox.right
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignTop
                            anchors.leftMargin: 2
                            anchors.verticalCenterOffset: 0
                            enabled: true
                            font.bold: true
                            font.pointSize: 11
                        }
                    }
                }
            }

            Label {
                id: timeLabel
                x: 815
                width: 60
                color: "#ffffff"
                text: qsTr(minutesTimer + " : " + secondsTimer1 + secondsTimer2)
                anchors.verticalCenter: row.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 10
                font.pointSize: 14
                font.bold: true
            }
        }
    }

    Connections{
        target: backendSerialPort

        function onSetGraphValues(isInfoReady){
            if (isInfoReady) {
                if (chartEMG.series("EMG")){
                    backendSerialPort.getEMGValues(chartEMG.series("EMG"))
                }
                if (chartAngle.series("Angle")){
                    backendSerialPort.getAngleValues(chartAngle.series("Angle"))
                }
                if (chartFES.series("FES")){
                    backendSerialPort.getFESValues(chartFES.series("FES"))
                }
                //axisX.min = axisX.min + 10
                //axisX.max = axisX.max + 10
                //axisXemg.max = axisXemg.max + 10/12
            }
        }

        function onSetSizeGraphs(isResize){
            if (isResize){
                column.resizeGraphView()
            }
        }

        function onSetPickValues(pkg){
            if (pkg[0] === 1){
                yAxisRangeSliderEMG.first.value = pkg[1] - 0.5
                yAxisRangeSliderEMG.second.value = pkg[2] + 0.5
            } else if (pkg[0] === 2){
                yAxisRangeSliderAngle.first.value = pkg[1] - 0.5
                yAxisRangeSliderAngle.second.value = pkg[2] + 0.5
            } else{
                yAxisRangeSliderFES.first.value = pkg[1] - 0.5
                yAxisRangeSliderFES.second.value = pkg[2] + 0.5
            }
        }

        function onSetXAxisValues(val){
            axisXemg.max = val
            axisXemg.min = val - xAxisSliderEMG.value
            axisXangle.max = val
            axisXangle.min = val - xAxisSliderAngle.value
            axisXfes.max = val
            axisXfes.min = val - xAxisSliderFES.value
        }

        function onSetActionButtons(isSet){
            if (isSet){
                row.enableButtons()
            } else {
                row.disableButtons()
            }
        }

        function onGetParameters(){
            backendSerialPort.updateParam(actionDurationSlider.value, useStopCheckBox.checked, onStimulationDurationSlider.value, freqStimulationDurationSlider.value, maxFlexAngleSlider.value, maxbuckSlider.value, emgThresholdSlider.value)
        }

        function onLoadData(data){
            var JsonObject= JSON.parse(data)
            actionDurationSlider.value = JsonObject.Therapy_duration
            useStopCheckBox.checked = JsonObject.Therapy_useStop
            onStimulationDurationSlider.value = JsonObject.Therapy_onState
            freqStimulationDurationSlider.value = JsonObject.Therapy_frequency
            maxFlexAngleSlider.value = JsonObject.Therapy_maxFlexAngle
            maxbuckSlider.value = JsonObject.Therapy_maxBuck
            emgThresholdSlider.value = JsonObject.Therapy_EMGThreshold
        }

        function onUpdateEmgThreshold(emg_threshold){
            emgThresholdSlider.value = emg_threshold
        }

        function onFinishNow(){
            console.log("In finishe now")
            actionTimer.running = false
            showTimer.running = false
            graphTimer.running = false
            backendSerialPort.runAction(5, 0, 0, 0, 0, 0)
            actionTimer.activateActions()
            actionTimer.restartCounter()
        }


    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.75;height:673;width:1108}
}
##^##*/
