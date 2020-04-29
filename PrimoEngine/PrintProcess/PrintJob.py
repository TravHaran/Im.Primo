import os
import time
import octorest
from pathlib import Path
import subprocess
import base64


class PrintJobObj():
    def __init__(self, id, ply=""):
        self.stlStr = ''
        self.usdzStr = ''
        self.binaryFile = ''
        self.id = id
        self.fileDir = str(Path(os.path.dirname(os.path.realpath(__file__))).parent) + "/3D_MODELS"
        self.folderName = "Print_" + str(self.id)
        self.plyName = "Print_" + str(self.id) + ".ply"
        self.stlName = "Print_" + str(self.id) + ".stl"
        self.usdzName = "Print_" + str(self.id) + ".usdz"
        if os.path.exists(self.fileDir + "/" + self.folderName + "/" + self.plyName):
            self.plyStr = "Not Needed"
        else:
            self.mkDir()
            self.plyStr = ply
            self.b64Write(str(self.fileDir+"/"+self.folderName+"/"+self.plyName), self.plyStr)

    def mkDir(self):
        cmd1 = 'cd ' + str(Path(os.path.dirname(os.path.realpath(__file__))).parent)
        cmd2 = "mkdir " + "3D_MODELS"
        cmd3 = "cd " + self.fileDir
        cmd4 = "mkdir " + self.folderName
        final = subprocess.Popen("{}; {}; {}; {};".format(cmd1, cmd2, cmd3, cmd4), shell=True, stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
        final.communicate()

    def convertPLY(self):

        cmd1 = 'cd ' + '"' + str(Path(os.path.dirname(os.path.realpath(__file__))).parent) + "/ARSCAN_ENGINE" + '"'
        cmd2 = "python2 mesh.py " + str(self.id)
        final = subprocess.Popen("{}; {};".format(cmd1, cmd2), shell=True, stdin=subprocess.PIPE,
                                 stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
        final.communicate()

    def printFile(self):
        cmd1 = 'cd ' + str(Path(os.path.dirname(os.path.realpath(__file__))))
        cmd2 = 'python3 PrintCode.py ' + self.id
        final = subprocess.Popen("{}; {};".format(cmd1,cmd2), shell=True, stdin=subprocess.PIPE,
                                      stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
        final.communicate()

        # file = str(self.fileDir + "/" + self.folderName + "/")
        # print(file)
        # cmd1 = 'cp -R ' + file + self.stlName + " " + str(Path(os.path.dirname(os.path.realpath(__file__))))
        # final = subprocess.Popen("{};".format(cmd1), shell=True, stdin=subprocess.PIPE,
        #                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
        # final.communicate()
        # time.sleep(1)
        #
        # def make_client(url, apiKey):
        #     try:
        #         client = octorest.OctoRest(url=url, apikey=apiKey)
        #         return client
        #     except ConnectionError as ex:
        #         print("Not connected to the internet")
        #
        # client = make_client("http://octopi.local", "762074B637AA44ACB9D24731411DCC7A")
        # while (client.connection_info()['current']['baudrate'] == None):
        #     client.connect()
        #     print("Connected")
        #     time.sleep(1)
        # print("Uploading...")
        # if (client.state() == "Printing"):
        #     print("File is printing")
        # else:
        #     client.upload(self.stlName)
        #     client.slice(self.stlName, print=True)
        #     cmd1 = 'rm ' + self.stlName
        #     final = subprocess.Popen("{};".format(cmd1), shell=True, stdin=subprocess.PIPE,
        #                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
        #     final.communicate()
        #     print("done!")


        #client.upload(file="Bag3Repaired.stl")
        #client.slice("Bag3Repaired.stl", print=True)

    def binaryConvert2Arr(self):
        self.binarySTLFile = self.binaryRead(self.fileDir + "/"+self.folderName + "/" + self.stlName)
        self.binaryUSDZFile = self.binaryRead(self.fileDir + "/" + self.folderName + "/" + self.usdzName)

        STLStrings = [str(integer) for integer in self.binarySTLFile]
        self.stlStr = ",".join(STLStrings)
        USDStrings = [str(integer) for integer in self.binaryUSDZFile]
        self.usdzStr = ",".join(USDStrings)

        # if fileType == 'stl':
        #     self.binaryFile = self.binaryRead(self.fileDir + "/"+self.folderName + "/" + self.stlName)
        # elif fileType == 'usdz':
        #     self.binaryFile = self.binaryRead(self.fileDir + "/" + self.folderName + "/" + self.usdzName)
        # str1 = ','.join(self.binaryFile)
        # return str1

    def binaryRead(self, fileName):
        f = open(fileName, "rb")
        num = list(f.read())
        f.close()
        return num

    def binaryWrite(self, fileDir,binaryData):
        f = open(fileDir, "wb")
        arr = bytearray(binaryData)
        f.write(arr)
        f.close()

    def b64Write(self, fileDir, data):
        dataD = base64.b64decode(data)
        datafile = open(fileDir, 'wb')
        datafile.write(dataD)



