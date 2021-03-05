
import os
import subprocess32

PLY_file = '/Users/trav/Desktop/Python/ARSCAN/PLY_Files/'
FILES = os.listdir(PLY_file)

while True:
    if os.path.exists(PLY_file + str(FILES[0])):
        subprocess32.run('python mesh.py ' + str(FILES[0]), shell=True)