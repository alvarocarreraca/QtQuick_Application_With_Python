import QtQuick
import QtQuick.Window
import QtQuick.Controls 2.15
//import QtGraphicalEffects 1.15
import "controls"

Window {
    id: mainWindow
    width: 1200
    height: 780
    minimumWidth: 1200
    minimumHeight: 780
    visible: true
    color: "#00000000"
    title: "Transrehab"

    // Remove title bar
    flags: Qt.Window | Qt.FramelessWindowHint

    // Properties
    property int windowStatus: 0
    property int windowMargin: 10
    property color btnDefaultColor: "#1c1d20"
    property color btnMouseOverColor: "#23272e"

    // Internal functions
    QtObject{
        id: internal

        function resetResizeBorders(){
            resizeLeft.visible = true
            resizeRight.visible = true
            resizeBottom.visible = true
            resizeWindow.visible = true
        }

        function maximizeRestore(){
            if(windowStatus == 0){
                mainWindow.showMaximized()
                windowStatus = 1
                windowMargin = 0
                // Resize visibility
                resizeLeft.visible = false
                resizeRight.visible = false
                resizeBottom.visible = false
                resizeWindow.visible = false
                btnMaximize.btnIconSource = "../../images/svg_images/restore_icon.svg"
            } else{
                mainWindow.showNormal()
                windowStatus = 0
                windowMargin = 10
                // Resize visibility
                internal.resetResizeBorders()
                btnMaximize.btnIconSource = "../../images/svg_images/maximize_icon.svg"
            }
        }

        function ifMaximizedWindowRestore(){
            if(windowStatus == 1){
                mainWindow.showNormal()
                windowStatus = 0
                windowMargin = 10
                // Resize visibility
                internal.resetResizeBorders()
                btnMaximize.btnIconSource = "../../images/svg_images/maximize_icon.svg"
            }
        }

        function restoreMargins(){
            windowStatus = 0
            windowMargin = 10
            // Resize visibility
            internal.resetResizeBorders()
            btnMaximize.btnIconSource = "../../images/svg_images/maximize_icon.svg"
        }
    }

    Rectangle {
        id: bg
        color: "#2c313c"
        border.color: "#383e4c"
        border.width: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10
        anchors.leftMargin: 10
        anchors.topMargin: 10
        //z: 1

        Rectangle {
            id: appContainer
            color: "#00000000"
            anchors.fill: parent
            anchors.rightMargin: 1
            anchors.leftMargin: 1
            anchors.bottomMargin: 1
            anchors.topMargin: 1

            Rectangle {
                id: topBar
                height: 60
                color: "#1c1d20"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0

                ToggleBtn {
                    onClicked: {
                        animationMenu.running = true
                        if (leftMenu.width == 70 && btnSave.isActiveMenu){
                            saveContainer.visible = true
                        } else{
                            saveContainer.visible = false
                        }
                    }
                }

                Rectangle {
                    id: topBarDescription
                    y: 13
                    height: 25
                    color: "#282c34"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 0
                    anchors.leftMargin: 70
                    anchors.bottomMargin: 0

                    Label {
                        id: labelTopInfo
                        color: "#5f6a82"
                        text: qsTr("Application to control and customize Myo-FES device on real-time")
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        verticalAlignment: Text.AlignVCenter
                        anchors.bottomMargin: 0
                        anchors.rightMargin: 300
                        anchors.leftMargin: 10
                        anchors.topMargin: 0
                    }

                    Label {
                        id: labelRightInfo
                        color: "#5f6a82"
                        text: qsTr("| WELCOME")
                        anchors.left: labelTopInfo.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        anchors.bottomMargin: 0
                        anchors.rightMargin: 10
                        anchors.leftMargin: 0
                        anchors.topMargin: 0
                    }
                }

                Rectangle {
                    id: titleBar
                    height: 35
                    color: "#00000000"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: 105
                    anchors.leftMargin: 70
                    anchors.topMargin: 0

                    DragHandler{
                        onActiveChanged: if(active){
                                             mainWindow.startSystemMove()
                                             internal.ifMaximizedWindowRestore()
                                         }
                    }

                    Image {
                        id: iconApp
                        width: 22
                        height: 22
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        source: "../images/svg_images/icon_app_top.svg"
                        anchors.leftMargin: 5
                        anchors.bottomMargin: 0
                        anchors.topMargin: 0
                        fillMode: Image.PreserveAspectFit
                    }

                    Label {
                        id: labelAppTittle
                        color: "#c3cbdd"
                        text: qsTr("TransRehab")
                        anchors.left: iconApp.right
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        verticalAlignment: Text.AlignVCenter
                        font.bold: true
                        font.pointSize: 10
                        anchors.leftMargin: 5
                    }
                }

                Row {
                    id: rowBtons
                    width: 105
                    height: 35
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 0
                    anchors.rightMargin: 0

                    TopBarButton{
                        id: btnMinimize
                        onClicked: {
                            mainWindow.showMinimized()
                            internal.restoreMargins()
                        }
                    }

                    TopBarButton {
                        id: btnMaximize
                        btnIconSource: "../../images/svg_images/maximize_icon.svg"
                        onClicked: {
                            internal.maximizeRestore()
                            backendSerialPort.resizeGraphs()
                        }
                    }

                    TopBarButton {
                        id: btnClose
                        btnColorMouseOver: "#8b230e"
                        btnColorDefaul: "#201c1c"
                        btnColorClicked: "#ff007f"
                        btnIconSource: "../../images/svg_images/close_icon.svg"
                        onClicked: {
                            backendSerialPort.checkIfTherapyIsSaved()
                            //mainWindow.close()
                        }
                    }
                }
            }

            Rectangle {
                id: content
                color: "#00000000"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: topBar.bottom
                anchors.bottom: parent.bottom
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0

                Rectangle {
                    id: leftMenu
                    width: 70
                    color: "#1c1d20"
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true
                    anchors.topMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0

                    function enableOpenSaveOptions(isEnabled){
                        enableSaveOptions(isEnabled)
                        enableOpenOptions(isEnabled)
                    }

                    function enableSaveOptions(isEnabled){
                        btnSave.enabled = isEnabled
                        if (isEnabled){
                            btnSave.btnColorMouseOver = btnMouseOverColor
                        }else{
                            btnSave.btnColorMouseOver = btnDefaultColor
                        }
                    }

                    function enableOpenOptions(isEnabled){
                        btnOpen.enabled = isEnabled
                        if (isEnabled){
                            btnOpen.btnColorMouseOver = btnMouseOverColor
                        }else{
                            btnOpen.btnColorMouseOver = btnDefaultColor
                        }
                    }

                    PropertyAnimation{
                        id: animationMenu
                        target: leftMenu
                        property: "width"
                        to: if(leftMenu.width == 70) return 250; else return 70
                        duration: 500
                        easing.type: Easing.InOutQuint
                    }

                    PropertyAnimation{
                        id: animationSave
                        target: leftMenu
                        property: "width"
                        to: if(leftMenu.width == 70) return 250; else return 70
                        duration: 500
                        easing.type: Easing.InOutQuint
                        onFinished: if (saveContainer.visible == true) saveContainer.visible = false; else saveContainer.visible = true
                    }

                    Column {
                        id: columnMenus
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: 0
                        anchors.leftMargin: 0
                        anchors.bottomMargin: 90
                        anchors.topMargin: 0

                        LeftMenuBtn {
                            id: btnHome
                            width: leftMenu.width
                            text: qsTr("Home")
                            anchors.top: btnWelcome.bottom
                            font.pointSize: 12
                            anchors.topMargin: 0
                            flat: true
                            isActiveMenu: false
                            onClicked: {
                                labelRightInfo.text = "| HOME"
                                btnHome.isActiveMenu = true
                                btnSettings.isActiveMenu = false
                                btnOpen.isActiveMenu = false
                                btnSave.isActiveMenu = false
                                pagesSettings.visible = false
                                btnWelcome.isActiveMenu = false
                                btnPerformance.isActiveMenu = false
                                pagesHome.visible = true
                                pagesWelcome.visible = false
                                pagesPerformance.visible = false
                                pagesHome.enabled = true
                                saveContainer.visible = false
                                leftMenu.enableOpenSaveOptions(true)
                            }
                        }

                        LeftMenuBtn {
                            id: btnOpen
                            width: leftMenu.width
                            text: qsTr("Open")
                            anchors.top: btnPerformance.bottom
                            enabled: false
                            font.pointSize: 12
                            anchors.topMargin: 0
                            btnColorMouseOver: btnDefaultColor
                            btnIconSource: "../../images/svg_images/openOn_icon.svg"
                            onClicked: {
                                labelRightInfo.text = "| OPEN"
                                btnHome.isActiveMenu = false
                                btnSettings.isActiveMenu = false
                                btnOpen.isActiveMenu = true
                                btnSave.isActiveMenu = false
                                btnWelcome.isActiveMenu = false
                                btnPerformance.isActiveMenu = false
                                saveContainer.visible = false
                                pagesHome.enabled = false
                                leftMenu.enableSaveOptions(false)
                                backendSerialPort.openFile()
                            }
                        }

                        LeftMenuBtn {
                            id: btnSave
                            width: leftMenu.width
                            text: qsTr("Save")
                            anchors.top: btnOpen.bottom
                            font.pointSize: 12
                            anchors.topMargin: 0
                            enabled: false
                            btnColorMouseOver: btnDefaultColor
                            btnIconSource: "../../images/svg_images/saveON_icon.svg"
                            onClicked: {
                                labelRightInfo.text = "| SAVE"
                                pathBtn.enabled = true
                                pathBtn.opacity = 1
                                pathBtn.btnColorMouseOver = "#ffe9a2"
                                folderNameTextEdit.enabled = true
                                saveCheckFig.visible = false
                                saveFailedFig.visible = false
                                btnHome.isActiveMenu = false
                                btnSettings.isActiveMenu = false
                                btnOpen.isActiveMenu = false
                                btnSave.isActiveMenu = true
                                btnWelcome.isActiveMenu = false
                                btnPerformance.isActiveMenu = false
                                pagesHome.enabled = false
                                leftMenu.enableOpenOptions(false)
                                if(leftMenu.width == 70){
                                    animationSave.running = true
                                }else if (leftMenu.width == 250 && saveContainer.visible == false){
                                    saveContainer.visible = true
                                }else{
                                    saveContainer.visible = false
                                    animationMenu.running = true
                                }
                            }
                        }

                        Rectangle {
                            id: saveContainer
                            height: 150
                            visible: false
                            color: "#ababab"
                            radius: 0
                            border.color: "#00000000"
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: btnSave.bottom
                            anchors.rightMargin: 0
                            anchors.leftMargin: 0
                            anchors.topMargin: 4

                            Column {
                                id: column
                                anchors.fill: parent

                                Label {
                                    id: pathLabel
                                    color: "#000000"
                                    text: qsTr("Path:")
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                    anchors.topMargin: 20
                                    anchors.leftMargin: 10
                                    font.pointSize: 12
                                }

                                Label {
                                    id: nameLabel
                                    color: "#000000"
                                    text: qsTr("Subject name:")
                                    anchors.left: parent.left
                                    anchors.top: pathLabel.bottom
                                    anchors.topMargin: 15
                                    anchors.leftMargin: 10
                                    font.pointSize: 12
                                }

                                CustomButton {
                                    id: saveDataBtn
                                    height: 35
                                    opacity: 0.5
                                    text: qsTr("Save")
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: nameLabel.bottom
                                    font.bold: true
                                    font.pointSize: 12
                                    anchors.topMargin: 25
                                    anchors.rightMargin: 50
                                    anchors.leftMargin: 50
                                    enabled: false
                                    colorMouseOver: "#4891d9"
                                    onClicked: {
                                        saveCheckFig.visible = false
                                        saveFailedFig.visible = false
                                        saveDataBtn.colorMouseOver = "#4891d9"
                                        saveDataBtn.opacity = 0.5
                                        saveDataBtn.enabled = false
                                        backendSerialPort.saveInfo(pathText.text, folderNameTextEdit.text)
                                    }
                                }

                                Rectangle {
                                    id: pathTextContainer
                                    width: 140
                                    height: 25
                                    color: "#c41c1d20"
                                    radius: 5
                                    anchors.verticalCenter: pathLabel.verticalCenter
                                    anchors.left: pathLabel.right
                                    clip: true
                                    anchors.leftMargin: 10


                                    Text {
                                        id: pathText
                                        color: "#ffffff"
                                        text: qsTr("")
                                        anchors.fill: parent
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 5
                                        onTextChanged: {
                                            if (pathText.text != "" && folderNameTextEdit.text != ""){
                                                saveDataBtn.colorMouseOver = "#55AAFF"
                                                saveDataBtn.enabled = true
                                                saveDataBtn.opacity = 1
                                            }
                                            else{
                                                saveDataBtn.colorMouseOver = "#4891d9"
                                                saveDataBtn.opacity = 0.5
                                                saveDataBtn.enabled = false
                                            }
                                        }
                                    }

                                    ScrollBar {
                                        id: hbar
                                        height: 5
                                        hoverEnabled: true
                                        active: hovered || pressed
                                        orientation: Qt.Horizontal
                                        size: frame.width / content.width
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                    }

                                }

                                TopBarButton {
                                    id: pathBtn
                                    width: 25
                                    height: 25
                                    anchors.verticalCenter: pathTextContainer.verticalCenter
                                    anchors.left: pathTextContainer.right
                                    btnColorClicked: "#ffe872"
                                    btnColorMouseOver: "#ffe9a2"
                                    btnColorDefaul: "#f8d775"
                                    anchors.leftMargin: 10
                                    btnIconSource: "../../images/svg_images/open_icon.svg"
                                    radiousValue: 5
                                    onClicked: backendSerialPort.openDirectory("save")
                                }

                                Rectangle {
                                    id: fileNameContainer
                                    width: 130
                                    height: 25
                                    color: "#c41c1d20"
                                    radius: 5
                                    anchors.verticalCenter: nameLabel.verticalCenter
                                    anchors.left: nameLabel.right
                                    anchors.leftMargin: 10

                                    TextEdit {
                                        id: folderNameTextEdit
                                        color: "#ffffff"
                                        anchors.fill: parent
                                        font.pixelSize: 12
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 5
                                        onTextChanged: {
                                            if (pathText.text != "" && folderNameTextEdit.text != ""){
                                                saveDataBtn.colorMouseOver = "#55AAFF"
                                                saveDataBtn.enabled = true
                                                saveDataBtn.opacity = 1
                                            }
                                            else{
                                                saveDataBtn.colorMouseOver = "#4891d9"
                                                saveDataBtn.opacity = 0.5
                                                saveDataBtn.enabled = false
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: pathBtnContainer
                                    width: 25
                                    height: 25
                                    color: "#00000000"
                                    radius: 5
                                    border.color: "#c41c1d20"
                                    anchors.verticalCenter: pathTextContainer.verticalCenter
                                    anchors.left: pathTextContainer.right
                                    anchors.leftMargin: 10
                                }

                                TopBarButton {
                                    id: saveCheckFig
                                    width: 25
                                    height: 25
                                    visible: false
                                    anchors.verticalCenter: saveDataBtn.verticalCenter
                                    anchors.left: saveDataBtn.right
                                    radiousValue: 15
                                    btnColorMouseOver: "#19ce2b"
                                    btnColorDefaul: "#19ce2b"
                                    btnColorClicked: "#00000000"
                                    enabled: false
                                    anchors.leftMargin: 10
                                    btnIconSource: "../../images/svg_images/check_icon.svg"
                                }

                                TopBarButton {
                                    id: saveFailedFig
                                    width: 25
                                    height: 25
                                    visible: false
                                    anchors.verticalCenter: saveDataBtn.verticalCenter
                                    anchors.left: saveDataBtn.right
                                    radiousValue: 15
                                    btnColorMouseOver: "#f75656"
                                    btnColorDefaul: "#f75656"
                                    btnColorClicked: "#00000000"
                                    enabled: false
                                    anchors.leftMargin: 10
                                    btnIconSource: "../../images/svg_images/failed_icon.svg"
                                }
                            }
                        }

                        LeftMenuBtn {
                            id: btnWelcome
                            width: leftMenu.width
                            text: qsTr("Welcome")
                            anchors.top: parent.top
                            font.pointSize: 12
                            isActiveMenu: true
                            anchors.topMargin: 0
                            flat: true
                            btnIconSource: "../../images/svg_images/guide_icon.svg"
                            onClicked: {
                                labelRightInfo.text = "| WELCOME"
                                btnHome.isActiveMenu = false
                                btnOpen.isActiveMenu = false
                                btnSave.isActiveMenu = false
                                btnWelcome.isActiveMenu = true
                                btnPerformance.isActiveMenu = false
                                btnSettings.isActiveMenu = false
                                pagesHome.visible = false
                                pagesSettings.visible = false
                                pagesWelcome.visible = true
                                pagesPerformance.visible = false
                                saveContainer.visible = false
                                leftMenu.enableOpenSaveOptions(false)
                            }
                        }

                        LeftMenuBtn {
                            id: btnPerformance
                            width: leftMenu.width
                            text: qsTr("Performance")
                            anchors.top: btnHome.bottom
                            font.pointSize: 12
                            isActiveMenu: false
                            flat: true
                            anchors.topMargin: 0
                            btnIconSource: "../../images/svg_images/performance_icon.svg"
                            onClicked: {
                                labelRightInfo.text = "| PERFORMANCE"
                                btnHome.isActiveMenu = false
                                btnOpen.isActiveMenu = false
                                btnSave.isActiveMenu = false
                                btnWelcome.isActiveMenu = false
                                btnPerformance.isActiveMenu = true
                                btnSettings.isActiveMenu = false
                                pagesHome.visible = false
                                pagesWelcome.visible = false
                                pagesPerformance.visible = true
                                pagesSettings.visible = false
                                saveContainer.visible = false
                                leftMenu.enableOpenSaveOptions(false)
                            }
                        }
                    }

                    LeftMenuBtn {
                        id: btnSettings
                        width: leftMenu.width
                        text: qsTr("Settings")
                        anchors.bottom: parent.bottom
                        font.pointSize: 12
                        anchors.bottomMargin: 25
                        btnIconSource: "../../images/svg_images/settings_icon.svg"
                        onClicked: {
                            labelRightInfo.text = "| SETTINGS"
                            btnHome.isActiveMenu = false
                            btnOpen.isActiveMenu = false
                            btnSave.isActiveMenu = false
                            btnWelcome.isActiveMenu = false
                            btnPerformance.isActiveMenu = false
                            btnSettings.isActiveMenu = true
                            pagesHome.visible = false
                            pagesSettings.visible = true
                            pagesWelcome.visible = false
                            pagesPerformance.visible = false
                            saveContainer.visible = false
                            leftMenu.enableOpenSaveOptions(false)
                        }
                    }

                }

                Rectangle {
                    id: contentPages
                    color: "#00000000"
                    anchors.left: leftMenu.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    clip: true
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                    anchors.bottomMargin: 25
                    anchors.topMargin: 0
                    Loader{
                        id: pagesHome
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/homePage.qml")
                        enabled: true
                        visible: false
                    }
                    Loader{
                        id: pagesSettings
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/settingsPage.qml")
                        visible: false
                    }
                    Loader{
                        id: pagesWelcome
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/WelcomePage.qml")
                        visible: true
                    }
                    Loader{
                        id: pagesPerformance
                        anchors.fill: parent
                        source: Qt.resolvedUrl("pages/performancePage.qml")
                        visible: false
                    }
                }

                Rectangle {
                    id: buttonBarDescription
                    color: "#282c34"
                    anchors.left: leftMenu.right
                    anchors.right: parent.right
                    anchors.top: contentPages.bottom
                    anchors.bottom: parent.bottom
                    anchors.rightMargin: 0
                    anchors.leftMargin: 0
                    anchors.bottomMargin: 0
                    anchors.topMargin: 0

                    Label {
                        id: labelBottomInfo
                        color: "#5f6a82"
                        text: qsTr("Disconnected")
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        verticalAlignment: Text.AlignVCenter
                        anchors.rightMargin: 30
                        anchors.bottomMargin: 0
                        anchors.leftMargin: 10
                        anchors.topMargin: 0
                    }

                    MouseArea {
                        id: resizeWindow
                        width: 25
                        height: 25
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 0
                        anchors.rightMargin: 0
                        cursorShape: Qt.SizeFDiagCursor

                        onPressed: {
                            mainWindow.startSystemResize(Qt.RightEdge | Qt.BottomEdge)
                        }

                        onReleased: {
                            backendSerialPort.resizeGraphs()
                        }

                        Image {
                            id: resizeImage
                            opacity: 0.5
                            anchors.fill: parent
                            source: "../images/svg_images/resize_icon.svg"
                            anchors.leftMargin: 5
                            anchors.topMargin: 5
                            sourceSize.height: 16
                            sourceSize.width: 16
                            fillMode: Image.PreserveAspectFit
                            antialiasing: false
                        }
                    }
                }
            }
        }
    }

    /*
    DropShadow{
        anchor.fill: bg
        horizontalOffset: 0
        verticalOffset: 0
        radius: 10
        sample: 16
        color: "#80000000"
        source: bg
        z: 0
    }
    */

    MouseArea {
        id: resizeLeft
        width: 10
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.leftMargin: 0
        anchors.topMargin: 10
        cursorShape: Qt.SizeHorCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.LeftEdge)
        }
    }

    MouseArea {
        id: resizeRight
        width: 10
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 0
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        cursorShape: Qt.SizeHorCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.RightEdge)
        }
        /*
        DragHandler{
            target: null
            onActiveChanged: if(active){
                                 mainWindow.startSystemResize(Qt.RightEdge)
                             }
        }*/
    }

    MouseArea {
        id: resizeBottom
        height: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 0
        cursorShape: Qt.SizeVerCursor

        onPressed: {
            mainWindow.startSystemResize(Qt.BottomEdge)
        }

        onReleased: {
            backendSerialPort.resizeGraphs()
        }
    }


    Dialog{
        id: popup
        title: "Save therapy results"
        x: 300
        y: 300
        width: 420
        height: 120
        standardButtons: Dialog.Ok | Dialog.Cancel
        contentItem: Text{
            id: tfText
            text: "Are you sure you don't want to save the therapy results?"
            font.pointSize: 12
        }
        onAccepted: {
            backendSerialPort.closeSerialPort()
            mainWindow.close()
        }

        onRejected: console.log("Cancel clicked")
    }

    Connections{
        target: backendSerialPort

        function onIsConnectedInfo(info){
            labelBottomInfo.text = info
        }

        function onSetSavePath(path){
            pathText.text = path
        }

        function onFinishLoad(){
            btnHome.isActiveMenu = true
            btnOpen.isActiveMenu = false
            pagesHome.enabled = true
            leftMenu.enableOpenSaveOptions(true)
        }

        function onUpdateSaveStatus(isSaved){
            if (isSaved){
                pathBtn.enabled = false
                pathBtn.opacity = 1
                pathBtn.btnColorMouseOver = "#f8d775"
                folderNameTextEdit.enabled = false
                saveCheckFig.visible = true
                folderNameTextEdit.text = ""
                pathText.text = ""
            }else{
                saveFailedFig.visible = true
                saveDataBtn.colorMouseOver = "#55AAFF"
                saveDataBtn.opacity = 1
                saveDataBtn.enabled = true
            }
        }

        function onInitMainPage(){
            labelRightInfo.text = "| HOME"
            btnHome.isActiveMenu = true
            btnSettings.isActiveMenu = false
            btnOpen.isActiveMenu = false
            btnSave.isActiveMenu = false
            pagesSettings.visible = false
            btnWelcome.isActiveMenu = false
            btnPerformance.isActiveMenu = false
            pagesHome.visible = true
            pagesWelcome.visible = false
            pagesPerformance.visible = false
            pagesHome.enabled = true
            saveContainer.visible = false
            leftMenu.enableOpenSaveOptions(true)
        }

        function onInitSettingsPage(){
            labelRightInfo.text = "| SETTINGS"
            btnHome.isActiveMenu = false
            btnOpen.isActiveMenu = false
            btnSave.isActiveMenu = false
            btnWelcome.isActiveMenu = false
            btnPerformance.isActiveMenu = false
            btnSettings.isActiveMenu = true
            pagesHome.visible = false
            pagesSettings.visible = true
            pagesWelcome.visible = false
            pagesPerformance.visible = false
            saveContainer.visible = false
            leftMenu.enableOpenSaveOptions(false)
        }

        function onPopupSaveOption(isSaved){
            if (!isSaved){
                popup.open()
            }else{
                mainWindow.close()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.75}
}
##^##*/
