# Im.Primo: Wireless 3D Scanning & 3D Printing at your fingertips
InPrimo is an application that allows a user to scan an object using their iOS device (faceID enabled) and print it wirelessly with impressive detail. Users can replicate hand-made models, artwork, and machine parts. 3D scanning circumvents the long hours required to build 3D models from scratch in computer software, and users have the freedom to scan their own models, or choose from a large database of premade 3-D scans. The wireless automated conversions and slicing reduces steps preformed manually, reducing preparation time by 85%, (calculated based on average prep times).

Once you’ve installed the app, you can choose to create a new scan.
You scan the item by rotating the phone around the subject.
InPrimo uses the TrueDepth sensor to create a point cloud map of the object.
After you view the scan you can choose to rescan or send it to the printer.
Once you click print, the app automatically converts the point cloud scan into an STL file, slices it and sends the file to the printer. The printer will convert to G code, adjust the printer settings and begin printing.

The application leverages the Lidar scanner in an iPhone coupled with SLAM algorithms to scan an object and grenerate a mesh file. This mesh file is then sent to a backend server which processes it and converts it into a 3D Printable STL file. This STL file is then sent to a 3D printer running Octoprint on a Raspberry Pi to enable wireless printing.


Built using Python, Swift, Django, StandardCyborg API, & OctoPrint API

Check it out...

Youtube: https://www.youtube.com/watch?v=HLnXVU77FOM

DevPost:https://devpost.com/software/imprimo

