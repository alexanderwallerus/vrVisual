@ECHO OFF
TITLE VR batch
ECHO starting batch script for running vr shapes
::/D allows setting a path in which the program to be executed exists:
ECHO overlaying black background:
START /D C:\Users\jetball\Desktop\vrVisual\blackBackground\application.windows64 blackBackground.exe
ECHO starting left sketch:
START /D C:\Users\jetball\Desktop\vrVisual\vrVisual\application.windows64 vrVisual.exe left
ECHO starting right sketch:
START /D C:\Users\jetball\Desktop\vrVisual\vrVisual\application.windows64 vrVisual.exe right
PAUSE