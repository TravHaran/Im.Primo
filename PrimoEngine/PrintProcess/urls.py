from django.urls import path

from . import views

urlpatterns = [
    path('test/', views.testOutput, name='test'),
    path('sendPLY/',views.recievePLY, name='recievePLY'),
    path('<int:print_id>/getUSDZ/',views.requestUSDZ, name='requestUSDZ'),
    path('<int:print_id>/printJob/',views.printJob,name = 'printJob')
]