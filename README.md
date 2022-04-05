# dedicatedInstanceServiceMemory

This tools provides memory information about all the processes running on a local or remote Windows computer. The primary use case is to understand the size of your dedicated instance ArcGIS Server services.

It will:

A.	Extract the ArcSOC.exe process service names (so you may see the memory utilization of those service instances)
B.	Report virtual memory consumption of the processes
C.	Report virtual memory and workingset memory consumption of the processes

The output is written to a csv file named for the target machine in the current directory.
