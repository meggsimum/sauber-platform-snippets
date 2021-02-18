@echo off
call "D:\Program_Files\QGIS_3_16\bin\o4w_env.bat"
call "D:\Program_Files\QGIS_3_16\bin\qt5_env.bat"
call "D:\Program_Files\QGIS_3_16\bin\py3_env.bat"

@echo on
"D:\Program_Files\QGIS_3_16\apps\Python37\Scripts\pyrcc5.bat" -o resources.py resources.qrc