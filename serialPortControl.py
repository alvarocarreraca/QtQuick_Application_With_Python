import json
import os.path
import time
from datetime import date
from PySide6.QtCore import QObject, Slot, Signal, QPointF, QPointFList
from PySide6.QtSerialPort import QSerialPort, QSerialPortInfo
from PySide6.QtCore import QIODeviceBase
from PySide6.QtCharts import QAbstractSeries, QXYSeries, QChartView, QAbstractBarSeries, QBarSet
from PySide6.QtWidgets import QFileDialog
from timeit import default_timer as timer

# Flex sensor constants:
VCC = 5  # Measured voltage of Arduino 5V line
R_DIV = 10000.0  # Measured resistence of 10k resistor
STRAIGHT_RESISTANCE = 7000.0  # 8000.0 # resistance of flex sensor when straight
BEND_RESISTANCE = 4300.0  # 5300.0 # resistance of flex sensor at 90 deg

baudRate = 19200  # 9600
bufferSize = 40
bufferSize_fes = 25
bufferSize_therapy = 15
arduinoFrequency = 62500
interval = 10
portInfoArray = []
buffer = ""
fm = 12
SAMPLE_COUNT = 20
xIdx = 0
actionID = 0
maxFlexAngle = 75
percentage_max_value = 0.6  # EMG threshold defined to 60% of the max EMG detected
jsonInfo = {
    "action": -1,
    "connect": -1
}
movingAvgInfo = {
    "interval": interval,
    "readingNumber": 0,
    "sum": 0,
    "next": 0,
    "readingBuffer": [None] * interval,
    "maxEMG": 0
}
paramDefaultValues = {
    "action": -1,
    "connect": 2,
    "MAX_BUCK_V": 20,
    "EMG_THRESHOLD": 512,
    "onState": 7,
    "offState": 1200
}
paramCurrentValues = {
    "duration": -1,
    "useStop": False,
    "onState": -1,
    "freq": -1,
    "maxFlex": -1,
    "maxBuck": -1,
    "emgThreshold": -1,
    "saveDir": "",
    "folderName": ""
}

endWithMaxFlexAngle = False
isSavedTherapy = True
emgThreshold = []
emgMaxVal = 0
emgMinVal = 100
angleMaxVal = 0
angleMinVal = 100
fesMaxVal = 0
fesMinVal = 100
isAdjustedEMG = False
isAdjustedAngle = False
isAdjustedFES = False
start_time = 0
ref_time = 0


class serialPortWindow(QObject):
    def __init__(self):
        QObject.__init__(self)
        self.serialPort = QSerialPort()
        self.emgBuffer = QPointFList()
        self.angleBuffer = QPointFList()
        self.fesBuffer = QPointFList()
        self.connect()

    def connect(self):
        self.serialPort.readyRead.connect(self.readData)

    def readData(self):
        # Function that reads the data from the bluetooth channel
        global buffer
        buffer += str(self.serialPort.readLine(), 'ascii').rstrip('\n')
        if buffer.__contains__('}') and buffer[0] == '{' and buffer[-1] == '}':
            self.deserializeJson(buffer)
            buffer = ""
        elif buffer.__contains__('}'):
            buffer = ""

    def deserializeJson(self, json_Data):
        # Function that deserializes the JSON structure and call the handler of the action in execution
        data = json.loads(json_Data)
        if actionID == 1:
            print(data['emg'])
            self.handleEMGData(data['emg'])
        elif actionID == 2:
            # print(data['angle'])
            self.handleAngleData(data['angle'])
        elif actionID == 3:
            print(data)
            self.handleFESData(data)
        elif actionID == 4:
            print(data)
            self.handleTherapyData(data)

    def handleEMGData(self, data):
        # Function that handles the data received when EMG calibration is in execution
        global start_time, ref_time
        end_time = timer()
        step = (end_time - start_time) / bufferSize
        for i, val in enumerate(data):
            movingAVG = val
            #  movingAVG = self.calculateMovingAvg(val)
            if movingAVG > movingAvgInfo["maxEMG"]:
                movingAvgInfo["maxEMG"] = round(movingAVG)
            self.emgBuffer.append(QPointF(ref_time + step * (i + 1), val))
        ref_time = ref_time + (end_time - start_time)
        start_time = end_time

    def handleAngleData(self, data):
        # Function that handles the data received when Angle calibration is in execution
        global start_time, ref_time
        end_time = timer()
        step = (end_time - start_time) / bufferSize
        for i, val in enumerate(data):
            angle = self.calculateFlexAngle(val)
            self.angleBuffer.append(QPointF(ref_time + step * (i + 1), angle))
        ref_time = ref_time + (end_time - start_time)
        start_time = end_time

    def handleFESData(self, data):
        # Function that handles the data received when FES calibration is in execution
        global start_time, ref_time
        end_time = timer()
        step = (end_time - start_time) / bufferSize_fes
        for i, val in enumerate(data["angle"]):
            angle = self.calculateFlexAngle(val)
            self.angleBuffer.append(QPointF(ref_time + step * (i + 1), angle))
            self.fesBuffer.append(QPointF(ref_time + step * (i + 1), data["fes"][i]))
            if angle > maxFlexAngle:
                print("In max Flex angel")
                self.finishNow.emit()
                # self.runAction(5, 0, 0, 0, 0, 0)
        ref_time = ref_time + (end_time - start_time)
        start_time = end_time

    def handleTherapyData(self, data):
        # Function that handles the data received when Run Therapy is in execution
        global start_time, ref_time
        end_time = timer()
        step = (end_time - start_time) / bufferSize_fes
        for i, val in enumerate(data["angle"]):
            angle = self.calculateFlexAngle(val)
            self.angleBuffer.append(QPointF(ref_time + step * (i + 1), angle))
            self.fesBuffer.append(QPointF(ref_time + step * (i + 1), data["fes"][i]))
            self.emgBuffer.append(QPointF(ref_time + step * (i + 1), data["emg"][i]))
            if angle > maxFlexAngle and endWithMaxFlexAngle:
                self.finishNow.emit()
                # self.runAction(5, 0, 0, 0, 0, 0)
        ref_time = ref_time + (end_time - start_time)
        start_time = end_time

    def calculateFlexAngle(self, val):
        # Function that calculates the flex angle from the resistance measured by the flex sensor
        flexV = val * VCC / 1023
        flexR = R_DIV * (VCC / flexV - 1)
        angle = self.mapValue(flexR, STRAIGHT_RESISTANCE, BEND_RESISTANCE, 0, 90)
        if angle < 0:
            angle = 0
        # elif angle > 90:
        #    angle = 90
        return angle

    def mapValue(self, val, fromMin, fromMax, toMin, toMax):
        # Function that maps the resistan value from the flex sensor to an angle value
        return (val - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin

    def calculateMovingAvg(self, val):
        # Function that calculates the moving average of the EMG value captured by the sensor (it is based on the Arduino function)
        if movingAvgInfo["readingNumber"] < movingAvgInfo["interval"]:
            movingAvgInfo["readingNumber"] = movingAvgInfo["readingNumber"] + 1
            movingAvgInfo["sum"] = movingAvgInfo["sum"] + val
        else:
            movingAvgInfo["sum"] = movingAvgInfo["readingBuffer"][movingAvgInfo["next"]] + val
        movingAvgInfo["readingBuffer"][movingAvgInfo["next"]] = val
        movingAvgInfo["next"] = movingAvgInfo[
                                    "next"] + 1
        if movingAvgInfo["next"] >= movingAvgInfo["interval"]:
            movingAvgInfo["next"] = 0
        return (movingAvgInfo["sum"] + movingAvgInfo["readingNumber"] / 2) / movingAvgInfo["readingNumber"]

    def beginMovingAvg(self):
        # Function that initializes the values of the moving average function
        movingAvgInfo["interval"] = interval
        movingAvgInfo["readingNumber"] = 0
        movingAvgInfo["sum"] = 0
        movingAvgInfo["next"] = 0
        movingAvgInfo["readingBuffer"] = [None] * interval
        movingAvgInfo["maxEMG"] = 0

    def generateJSON(self, isAction):
        # Function that serializes the JSON structure to be sent through the communication channel
        if isAction:
            return json.dumps(paramDefaultValues)
        else:
            return json.dumps(jsonInfo)

    def updatePickValues(self, idx, value):
        # Function that updates the maximum value of the graphs for visualization handling
        if idx == 1:
            global emgMaxVal, emgMinVal
            if value > emgMaxVal:
                emgMaxVal = value
                pkg = [1, emgMinVal, emgMaxVal]
                self.setPickValues.emit(pkg)
            elif value < emgMinVal:
                emgMinVal = value
                pkg = [1, emgMinVal, emgMaxVal]
                self.setPickValues.emit(pkg)
        elif idx == 2:
            global angleMaxVal, angleMinVal
            if value > angleMaxVal:
                angleMaxVal = value
                pkg = [2, angleMinVal, angleMaxVal]
                self.setPickValues.emit(pkg)
            elif value < angleMinVal:
                angleMinVal = value
                pkg = [2, angleMinVal, angleMaxVal]
                self.setPickValues.emit(pkg)
        elif idx == 3:
            global fesMaxVal, fesMinVal
            if value > fesMaxVal:
                fesMaxVal = value
                pkg = [3, fesMinVal, fesMaxVal]
                self.setPickValues.emit(pkg)
            elif value < fesMinVal:
                fesMinVal = value
                pkg = [3, fesMinVal, fesMaxVal]
                self.setPickValues.emit(pkg)

    @Slot(QAbstractSeries, int)
    def getEMGThreshold(self, series, actionSelected):
        # Slot that returns the EMG threshold value to the front-end
        emgThresholdBuffer = QPointFList()
        if actionSelected == 4:
            emgThresholdBuffer.append(QPointF(0, movingAvgInfo["maxEMG"] * percentage_max_value))
            emgThresholdBuffer.append(QPointF(301, movingAvgInfo["maxEMG"] * percentage_max_value))
        series.replace(emgThresholdBuffer)

    @Slot(QAbstractSeries)
    def getEMGValues(self, series):
        # Slot that replaces the EMG graph in the front-end
        series.replace(self.emgBuffer)

    @Slot(QAbstractSeries)
    def getAngleValues(self, series):
        # Slot that replaces the Angle graph in the front-end
        series.replace(self.angleBuffer)

    @Slot(QAbstractSeries)
    def getFESValues(self, series):
        # Slot that replaces the FES graph in the front-end
        series.replace(self.fesBuffer)

    # Signals
    setName = Signal(str)
    isPortReady = Signal(list)
    isInfoList = Signal(list)
    isConnected = Signal(bool)
    isConnectedInfo = Signal(str)
    setGraphValues = Signal(bool)
    setSizeGraphs = Signal(bool)
    setPickValues = Signal(list)
    setXAxisValues = Signal(float)
    setActionButtons = Signal(bool)
    getChartInfo = Signal()
    getParameters = Signal()
    loadData = Signal(str)
    setSavePath = Signal(str)
    setPerformancePath = Signal(str, list)
    finishLoad = Signal()
    updateSaveStatus = Signal(bool)
    setPerformanceRange = Signal(int, int)
    setPerformanceGraph = Signal(list, list)
    initMainPage = Signal()
    initSettingsPage = Signal()
    updateEmgThreshold = Signal(int)
    popupSaveOption = Signal(bool)
    finishNow = Signal()

    @Slot(bool)
    def lookForPorts(self, isChecked):
        # Slot that look for the serial ports available within the operative system
        global portInfoArray
        if isChecked:
            portInfoArray = QSerialPortInfo.availablePorts()
            portList = []
            for port in portInfoArray:
                portList.append(port.portName())
            self.isPortReady.emit(portList)

    @Slot(int)
    def showPortInfo(self, index):
        # Slot that updates the port information visualized in the front-end
        portInfo = portInfoArray[index]
        infoList = ["Description: " + portInfo.description(), "Manufacturer: " + portInfo.manufacturer(),
                    "Serial number: " + portInfo.serialNumber(), "Location: " + portInfo.systemLocation()]
        self.isInfoList.emit(infoList)

    @Slot(int)
    def openSerialPort(self, index):
        # Slot that initializes the communication with Myo-FES
        global jsonInfo
        print("Open Serial Port")
        portInfo = portInfoArray[index]
        self.serialPort.setPortName(portInfo.portName())
        self.serialPort.setBaudRate(baudRate)
        self.serialPort.setDataBits(QSerialPort.DataBits.Data8)
        self.serialPort.setParity(QSerialPort.Parity.NoParity)
        self.serialPort.setStopBits(QSerialPort.StopBits.OneStop)
        self.serialPort.setReadBufferSize(0)
        if self.serialPort.open(QIODeviceBase.ReadWrite):
            self.isConnected.emit(True)
            self.setActionButtons.emit(True)
            info = "Connected to " + portInfo.portName() + " : Baud rate = " + str(baudRate)
            self.isConnectedInfo.emit(info)
            if self.serialPort.isWritable():
                jsonInfo["action"] = 0
                jsonInfo["connect"] = 1
                info_json = self.generateJSON(False)
                self.serialPort.write(info_json.encode())
                self.serialPort.waitForBytesWritten()
            print("Connected")
        else:
            self.isConnected.emit(False)

    @Slot()
    def closeSerialPort(self):
        # Slot that closes the communication with Myo-FES
        global jsonInfo
        print("Close Serial Port")
        if self.serialPort.isOpen():
            if self.serialPort.isWritable():
                jsonInfo["action"] = 0
                jsonInfo["connect"] = 0
                info_json = self.generateJSON(False)
                self.serialPort.write(info_json.encode())
                self.serialPort.waitForBytesWritten()
            print("Disconnected")
            self.serialPort.close()
        self.isConnected.emit(False)
        self.isConnectedInfo.emit("Disconnected")
        self.setActionButtons.emit(False)

    @Slot(int, int, int, int, int, int)
    def runAction(self, idxAction, onState, freqState, maxFlex, maxBuck, emgThres):
        # Slot that communicates to Myo-FES the action that has to be run and the configuration parameters needed
        global jsonInfo, actionID, isSavedTherapy
        if idxAction == 5 and actionID == 1:
            self.updateEmgThreshold.emit(movingAvgInfo["maxEMG"] * percentage_max_value)
        actionID = idxAction
        if actionID == 4:
            isSavedTherapy = False
        self.establishCommunication()
        if idxAction != 5:
            self.handleConfigParameters(idxAction, onState, freqState, maxFlex, maxBuck, emgThres)
            info_json = self.generateJSON(True)
        else:
            jsonInfo["action"] = idxAction
            info_json = self.generateJSON(False)
        self.serialPort.write(info_json.encode())
        self.serialPort.waitForBytesWritten()
        self.prepareForInfo(idxAction)
        print("Action sent")

    def handleConfigParameters(self, idxAction, onState, freqState, maxFlex, maxBuck, emgThres):
        # Function that updates the configuration parameters
        global maxFlexAngle
        paramDefaultValues["action"] = idxAction
        paramDefaultValues["onState"] = onState
        offState = round(arduinoFrequency / freqState)
        paramDefaultValues["offState"] = offState
        maxFlexAngle = maxFlex
        paramDefaultValues["MAX_BUCK_V"] = maxBuck
        paramDefaultValues["EMG_THRESHOLD"] = emgThres

    def prepareForInfo(self, idx):
        # Function that initialices the time reference when an action is executed (this time reference is used to control the duration of the therapy)
        global start_time, ref_time
        start_time = timer()
        ref_time = 0
        if idx == 1:
            self.beginMovingAvg()

    def establishCommunication(self):
        # Function that sends a control information before sending the real information to control the communication channel
        info = "start"
        self.serialPort.write(info.encode())
        self.serialPort.waitForBytesWritten()
        time.sleep(1)

    @Slot()
    def resizeGraphs(self):
        # Slot that resizes the graphs in the front-end
        self.setSizeGraphs.emit(True)

    @Slot(int)
    def getPickValues(self, idx):
        # Slot that returns the peak values for each graph to the front-end
        if idx == 1:
            global emgMaxVal, emgMinVal, isAdjustedEMG
            for point in self.emgBuffer:
                if point.y() > emgMaxVal:
                    emgMaxVal = point.y()
                elif point.y() < emgMinVal:
                    emgMinVal = point.y()
            isAdjustedEMG = True
            pkg = [1, emgMinVal, emgMaxVal]
            self.setPickValues.emit(pkg)
        elif idx == 2:
            global angleMaxVal, angleMinVal, isAdjustedAngle
            for point in self.angleBuffer:
                if point.y() > angleMaxVal:
                    angleMaxVal = point.y()
                elif point.y() < angleMinVal:
                    angleMinVal = point.y()
            isAdjustedAngle = True
            pkg = [2, angleMinVal, angleMaxVal]
            self.setPickValues.emit(pkg)
        elif idx == 3:
            global fesMaxVal, fesMinVal, isAdjustedFES
            for point in self.fesBuffer:
                if point.y() > fesMaxVal:
                    fesMaxVal = point.y()
                elif point.y() < fesMinVal:
                    fesMinVal = point.y()
            isAdjustedFES = True
            pkg = [3, fesMinVal, fesMaxVal]
            self.setPickValues.emit(pkg)

    @Slot(int)
    def setNotAdjusted(self, idx):
        # Slot that updated the auto-adjusted status
        if idx == 1:
            global isAdjustedEMG
            isAdjustedEMG = False
        elif idx == 2:
            global isAdjustedAngle
            isAdjustedAngle = False
        elif idx == 3:
            global isAdjustedFES
            isAdjustedFES = False

    @Slot(str)
    def openDirectory(self, origin):
        # Slot that opens a directory in the front-end
        directory = QFileDialog.getExistingDirectory()
        if directory and origin == "save":
            self.setSavePath.emit(directory)
        if directory and origin == "performance":
            dirList = os.listdir(directory)
            self.setPerformancePath.emit(directory, dirList)

    @Slot()
    def openFile(self):
        # Slot that load a JSON for visualization in the front-end
        fileName = QFileDialog.getOpenFileName(caption="Open file")
        if fileName[0] != "":
            with open(fileName[0]) as file:
                data = json.load(file)
            self.loadData.emit(json.dumps(data))
            self.emgBuffer.clear()
            for i in range(len(data["EMG_X"])):
                self.emgBuffer.append(QPointF(data["EMG_X"][i], data["EMG_Y"][i]))
            self.angleBuffer.clear()
            for i in range(len(data["Angle_X"])):
                self.angleBuffer.append(QPointF(data["Angle_X"][i], data["Angle_Y"][i]))
            self.fesBuffer.clear()
            for i in range(len(data["FES_X"])):
                self.fesBuffer.append(QPointF(data["FES_X"][i], data["FES_Y"][i]))
            self.setGraphValues.emit(True)
        else:
            pass
        self.finishLoad.emit()

    @Slot(str, str)
    def saveInfo(self, savePath, name):
        # Slot that save the therapy information in different formats for offline handling
        # This function is missing to save the information in .txt and .csv format -> it should be implemented
        isSaved = True
        sessionID = 0
        saveFolder_path = savePath + "/" + name
        if os.path.isdir(saveFolder_path):
            dirList = os.listdir(saveFolder_path)
            for dirName in dirList:
                tempID = int(dirName[7:])
                if tempID > sessionID:
                    sessionID = tempID
        elif os.path.isdir(savePath):
            os.mkdir(saveFolder_path)
        else:
            isSaved = False
        if isSaved:
            sessionID = sessionID + 1
            saveSession_path = saveFolder_path + "/Session" + str(sessionID)
            os.mkdir(saveSession_path)
            self.getParameters.emit()
            info = {
                "Date": str(date.today()),
                "Patient_name": -1,
                "EMG_X": [],
                "EMG_Y": [],
                "Angle_X": [],
                "Angle_Y": [],
                "FES_X": [],
                "FES_Y": [],
                "Therapy_duration": paramCurrentValues["duration"],
                "Therapy_useStop": paramCurrentValues["useStop"],
                "Therapy_onState": paramCurrentValues["onState"],
                "Therapy_frequency": paramCurrentValues["freq"],
                "Therapy_maxFlexAngle": paramCurrentValues["maxFlex"],
                "Therapy_maxBuck": paramCurrentValues["maxBuck"],
                "Therapy_EMGThreshold": paramCurrentValues["emgThreshold"]
            }
            for point in self.emgBuffer:
                info["EMG_X"].append(point.x())
                info["EMG_Y"].append(point.y())
            for point in self.angleBuffer:
                info["Angle_X"].append(point.x())
                info["Angle_Y"].append(point.y())
            for point in self.fesBuffer:
                info["FES_X"].append(point.x())
                info["FES_Y"].append(point.y())

            fileName = name + "_Session" + str(sessionID) + ".json"
            completeName = os.path.join(saveSession_path, fileName)
            with open(completeName, 'w') as json_file:
                json.dump(info, json_file)
        self.updateSaveStatus.emit(isSaved)

    @Slot(int, bool, int, int, int, int, int)
    def updateParam(self, duration, useStop, onState, freq, maxFlex, maxBuck, emgThres):
        # Slot that updates the therapy parameters
        paramCurrentValues["duration"] = duration
        paramCurrentValues["useStop"] = useStop
        paramCurrentValues["onState"] = onState
        paramCurrentValues["freq"] = freq
        paramCurrentValues["maxFlex"] = maxFlex
        paramCurrentValues["maxBuck"] = maxBuck
        paramCurrentValues["emgThreshold"] = emgThres

    @Slot(str, str)
    def getPerformanceValues(self, subjectName, path):
        # Slot that returns the performance values for the visualization in the front-end
        global emgThreshold
        maxID = 0
        folder_path = path + "/" + subjectName
        print(folder_path)
        if os.path.isdir(folder_path):
            dirList = os.listdir(folder_path)
            emgThresholdList = [None] * len(dirList)
            for dirName in dirList:
                dirID = int(dirName[7:])
                final_path = folder_path + "/" + dirName + "/" + subjectName + "_Session" + str(dirID) + ".json"
                with open(final_path) as file:
                    data = json.load(file)
                    emgThresholdList[dirID - 1] = data["Therapy_EMGThreshold"]
                if dirID > maxID:
                    maxID = dirID
            emgThreshold = emgThresholdList
            self.setPerformanceRange.emit(maxID, max(emgThresholdList)*1.05)

    @Slot(str, str)
    def updatePerformanceGraph(self, minVal, maxVal):
        # Slot that shows the performance values in the front-end
        minV = int(minVal)
        maxV = int(maxVal)
        categoriesVal = []
        for i in range(minV, maxV + 1):
            categoriesVal.append("Session " + str(i))
        self.setPerformanceGraph.emit(emgThreshold[minV - 1: maxV], categoriesVal)

    @Slot()
    def changeToMainWindow(self):
        # Slot to send information to main home page
        self.initMainPage.emit()

    @Slot()
    def changeToSettingsWindow(self):
        # Slot to send information to settings page
        self.initSettingsPage.emit()

    @Slot()
    def checkIfTherapyIsSaved(self):
        # Slot that controls if the therapy was saved, a pop-up will be shown otherwise
        self.popupSaveOption.emit(isSavedTherapy)

    @Slot()
    def cleanGraphs(self):
        # Slot that cleans the graphs in the front-end
        self.emgBuffer.clear()
        self.angleBuffer.clear()
        self.fesBuffer.clear()

    @Slot(bool)
    def updateEndFlexAngle(self, isChecked):
        # Slot that updates the end with flex angle check-box status
        global endWithMaxFlexAngle
        endWithMaxFlexAngle = isChecked
