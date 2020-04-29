
from django.db import models

# Create your models here.

class PrintJobData(models.Model):
    pub_date = models.DateTimeField('date published')
    stlText = models.TextField(blank=True)
    plyText = models.TextField(blank=True)
    usdzText = models.TextField(blank=True)


