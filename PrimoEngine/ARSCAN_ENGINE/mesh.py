from mmRemote import *
import os
import mm
import sys
import subprocess32
from subprocess32 import Popen, PIPE, STDOUT
import time
import psutil
import sys
from pathlib import Path


class Mesh(object):
    def __init__(self):  # Define the location of dependencies
        # self.PLY_File = PLY_File
        self.remote = mmRemote()
        self.cmd = mmapi.StoredCommands()
        self.PLY_File = 'Print_' + sys.argv[
            1] + '.ply'  # filename of PLY file - inputted as argument when calling function
        self.USDZ_File = 'Print_' + sys.argv[1] + '.usdz'
        self.STL_File = 'Print_' + sys.argv[1] + '.stl'
        self.folder = 'Print_' + sys.argv[1] + '/'
        print (self.PLY_File)
        self.File_Dir = str(Path(os.path.dirname(os.path.realpath(
            __file__))).parent) + "/3D_MODELS/" + self.folder + self.PLY_File  # set's PLY file location
        self.Input_Dir = str(Path(
            os.path.dirname(os.path.realpath(__file__)))) + '/meshlab.app/Contents/MacOS/'  # location of MeshLabServer
        self.Output_Dir = str(Path(os.path.dirname(
            os.path.realpath(__file__))).parent) + "/3D_MODELS/" + self.folder  # location to export file to
        self.USDZ_OutDir = str(Path(os.path.dirname(
            os.path.realpath(__file__))).parent) + "/3D_MODELS/" + self.folder  # location to export file to

        self.autoML()

    def autoML(self):  # call's MeshLabServer and run's automated script to produce surface STL from PLY
        cmd1 = 'cd ' + self.Input_Dir
        cmd2 = './meshlabserver -i ' + self.File_Dir + ' -o ' + self.Output_Dir + self.STL_File + ' -s automl.mlx'
        final = Popen("{}; {}".format(cmd1, cmd2), shell=True, stdin=PIPE,
                      stdout=PIPE, stderr=STDOUT, close_fds=True)
        stdout, nothing = final.communicate()
        log = open('log', 'w')
        log.write(stdout)
        log.close()

        time_to_wait = 10
        time_counter = 0

        while not os.path.exists(self.Output_Dir + self.STL_File):
            time.sleep(1)
            time_counter += 1
            if time_counter > time_to_wait: break

        if os.path.exists(self.Output_Dir + self.STL_File):
            print("STL file exists")
            self.openFile()

    def checkIfProcessRunning(self, processName):
        # Checks if there is any running process that contains the given name processName.
        # Iterate over the all the running process
        for proc in psutil.process_iter():
            try:
                # Check if process name contains the given name string.
                if processName.lower() in proc.name().lower():
                    return True
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                pass
        return False

    def openFile(self):
        # open Meshmixer
        subprocess32.run('open -a Meshmixer ' + self.Output_Dir + self.STL_File, shell=True)

        processName = 'meshmixer'

        time_to_wait = 10
        time_counter = 0

        while not self.checkIfProcessRunning(processName):
            time.sleep(1)
            time_counter += 1

            if time_counter > time_to_wait: break

        if self.checkIfProcessRunning(processName):
            print('Yes a ' + processName + ' process was running')
            self.Apply_Profile()

        else:
            print('No ' + processName + ' process was running')

    def Apply_Profile(self):
        # initialize connection
        time.sleep(2)
        self.remote.connect()
        time.sleep(1)
        # apply commands
        self.cmd.AppendBeginToolCommand("makeSolid")
        self.cmd.AppendToolParameterCommand('solidType', 1)
        self.cmd.AppendToolParameterCommand('solidResolution', 250)
        self.cmd.AppendCompleteToolCommand("accept")
        self.cmd.AppendBeginToolCommand('separateShells')
        self.cmd.AppendCompleteToolCommand("accept")
        self.remote.runCommand(self.cmd)

        self.Save_File()

    def Save_File(self):
        time.sleep(1)
        save_path = self.Output_Dir + self.STL_File
        # request list of objects in scene
        objects = mm.list_objects(self.remote)
        # select main object in list
        main_obj = objects[1]
        select_list = [main_obj]
        mm.select_objects(self.remote, select_list)
        # export to output directory
        mm.export_mesh(self.remote, save_path)

        self.Close_Program()

    def Close_Program(self):
        time.sleep(1)
        # terminate connection
        self.remote.shutdown()
        # close Meshmixer
        subprocess32.run('pkill -x meshmixer', shell=True)

        time_to_wait = 10
        time_counter = 0

        while not os.path.exists(self.Output_Dir + self.STL_File):
            time.sleep(1)
            time_counter += 1

            if time_counter > time_to_wait: break

        if os.path.exists(self.Output_Dir + self.STL_File):
            print("PLY file exists")
            self.USDZ_Convert()

    def USDZ_Convert(self):
        time.sleep(1)

        cmd1 = 'cd ' + str(Path(os.path.dirname(os.path.realpath(__file__)))) + "/usdpython/"
        print cmd1

        cmd2 = './stl_to_usdz.sh ' + self.Output_Dir + self.STL_File + ' ' + self.USDZ_OutDir + self.USDZ_File

        final = Popen("{}; {}".format(cmd1, cmd2), shell=True, stdin=PIPE,
                      stdout=PIPE, stderr=STDOUT, close_fds=True)
        stdout, nothing = final.communicate()
        log = open('log', 'w')
        log.write(stdout)
        log.close()


# Open Terminal at 'ARSCAN' folder and enter command 'python mesh.py <filename>.ply'
# Make sure the STL file you wish to export is in the defined input directory
# Must include 'ARSCAN' folder in the defined output directory

# define path for file

Mesh()
