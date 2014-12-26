Agilent_Measurement_System
==========================

This project packages some basic measurement function of Agilent‘s oscilloscope and signal analyzer into matlab functions.

The `Instrument_Command` folder is for some common command such as **SA_MeasPow.m** (“Measure Power Using the Signal Analyzer"), and **Scope_MeasVAmp.m** ("Measure Power Using the Oscilloscope").

The `Reference` folder is for some programming mannual provided by instrument manufacture.

The ".m" files is the top directory is the measuring-progress-control program, using commands in the `Instrument_Command` in a certain manner and order for some general measurement purpose, an "amplitude v.s. frequency graph" for example.
