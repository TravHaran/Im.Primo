import json
import os
import time

from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt

from PrintProcess.models import PrintJobData
from . import PrintJob

# Create your views here.

def testOutput(request):
    return HttpResponse("Hello World, this is a test")

#Recieves ply file from app
@csrf_exempt
def recievePLY(request):

    #Get data from json
    if request.method == "POST":
        body = request.body.decode('utf-8')
        bodyData = json.loads(body)

    #convert data into an integer array
    #Write function to parse data
    plyStr = bodyData["PLYdata"]

    #Create a new job (saves to database on django)
    databaseJob = PrintJobData(plyText=plyStr,pub_date=timezone.now())
    databaseJob.save()
    #Create mirror job object
    # Save PLY into file
    # convert stl and usdz
    realJob = PrintJob.PrintJobObj(databaseJob.id, plyStr)

    realJob.convertPLY()

    time_to_wait = 40
    time_counter = 0

    while not os.path.exists(realJob.fileDir + "/" + realJob.folderName + "/" + realJob.usdzName):
        time.sleep(1)
        time_counter += 1

        if time_counter > time_to_wait: break

    time.sleep(1)
    realJob.binaryConvert2Arr()

    databaseJob.stlText = realJob.stlStr
    databaseJob.usdzText = realJob.usdzStr
    databaseJob.save()

    #Send print ID

    return JsonResponse({'id':databaseJob.id,'USDZdata':databaseJob.usdzText})

@csrf_exempt
def requestUSDZ(request,print_id):
    my_record = PrintJobData.objects.get(id=print_id)

    #Create mirror object
    realJob = PrintJob.PrintJobObj(my_record.id)

    #Converts USDZ to binary array
    #Concatnates into string

    #Sends to JSON

    return JsonResponse({'id':my_record.id,'STLdata':realJob.stlStr})

@csrf_exempt
def printJob(request,print_id):
    my_record = PrintJobData.objects.get(id=print_id)
    #Create mirror object
    realJob = PrintJob.PrintJobObj(str(my_record.id))
    #print file
    realJob.printFile()
    #send status HttpResponse as JSON
    return JsonResponse({'id': my_record.id, 'printStatus': 'Printing'})

