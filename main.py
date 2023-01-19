import os
from pathlib import Path
import sys
import serialPortControl as sp

from PySide6.QtWidgets import QApplication
# from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


if __name__ == "__main__":
    app = QApplication(sys.argv)  # QGuiApplication
    engine = QQmlApplicationEngine()

    # Get context for serial port
    serialPortControl = sp.serialPortWindow()
    engine.rootContext().setContextProperty("backendSerialPort", serialPortControl)

    engine.load(os.fspath(Path(__file__).resolve().parent / "qml/main.qml"))
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
