import os
import time
import octorest
from pathlib import Path
import subprocess
import sys

fileDir = str(Path(os.path.dirname(os.path.realpath(__file__))).parent) + "/3D_MODELS"
folderName = "Print_" + str(sys.argv[1])
stlName = "Print_" + str(sys.argv[1]) + ".stl"
file = str(fileDir + "/" + folderName + "/")
print(file)
cmd1 = 'cp -R ' + file + stlName + " " + str(Path(os.path.dirname(os.path.realpath(__file__))))
final = subprocess.Popen("{};".format(cmd1), shell=True, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
final.communicate()
time.sleep(1)


def make_client(url, apiKey):
    try:
        client = octorest.OctoRest(url=url, apikey=apiKey)
        return client
    except ConnectionError as ex:
        print("Not connected to the internet")


client = make_client("http://octopi.local", "762074B637AA44ACB9D24731411DCC7A")
while (client.connection_info()['current']['baudrate'] == None):
    client.connect()
    print("Connected")
    time.sleep(1)
print("Uploading...")
if (client.state() == "Printing"):
    print("File is printing")
else:
    client.upload(stlName)
    client.slice(stlName, print=True)
    cmd1 = 'rm ' + stlName
    final = subprocess.Popen("{};".format(cmd1), shell=True, stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE, stderr=subprocess.STDOUT, close_fds=True)
    final.communicate()
    print("done!")
