import cv2
# import numpy as np
# import sys,os,glob,numpy
# from skimage import io


# specify image for face recognition and then store
img = cv2.imread("../other_temp/p1.jpg")
color = (0, 255, 0)


grey = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

classfier = cv2.CascadeClassifier("./haarcascade_frontalface_alt2.xml")



faceRects = classfier.detectMultiScale(grey, scaleFactor=1.2, minNeighbors=3, minSize=(32, 32))
if len(faceRects) > 0:         # greater than 0, the face is detected
    for faceRect in faceRects: # frame each face individually
        x, y, w, h = faceRect
        cv2.rectangle(img, (x - 10, y - 10), (x + w + 10, y + h + 10), color, 3) # control the thickness of the green box



# write the image
cv2.imwrite('../other_temp/p1_face.jpg',img)
cv2.imshow("Find Faces!",img)
cv2.waitKey(0)