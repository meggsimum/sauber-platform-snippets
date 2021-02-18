from PyQt5 import QtCore, QtGui, QtWidgets

from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg, NavigationToolbar2QT as NavigationToolbar
from matplotlib.figure import Figure

class PlotterCanvas(FigureCanvasQTAgg):

    def __init__(self, parent=None, width=10, height=5, dpi=200):
        fig = Figure(figsize=(width, height), dpi=dpi)
        self.axes = fig.add_subplot(1,1,1)
        super(PlotterCanvas, self).__init__(fig)

class Plotter(QtWidgets.QMainWindow):

    def __init__(self, *args, **kwargs):
        super(Plotter, self).__init__(*args, **kwargs)

    def plot(self,dataseries):

        # y-axis: Data series
        ds = ([float(x[1]) for x in dataseries])

        # x-axis: Datetimes
        ts = ([x[0] for x in dataseries])

        sc = PlotterCanvas(self, width=10, height=5, dpi=200)
        sc.axes.plot(ts, ds)

        toolbar = NavigationToolbar(sc, self)

        layout = QtWidgets.QVBoxLayout()
        layout.addWidget(toolbar)
        layout.addWidget(sc)

        widget = QtWidgets.QWidget()
        widget.setLayout(layout)
        self.setCentralWidget(widget)

        self.show()