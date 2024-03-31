<!--
 * @Descripttion: 
 * @Author: ISMY
 * @contact: mingyu_shu@tju.edu.cn
 * @version: 
 * @Date: 2024-03-26 10:31:35
 * @LastEditors: ISMY
 * @LastEditTime: 2024-03-31 17:32:57
-->
This work is used for image processing based on FPGA zynq7020 which consists of three main functions: 1. image grey scale, 2. image Gaussian filtering and 3. image edge detection based on sobel operator. Final implementation of face recognition and extraction of block diagrams.

# 0. Processing Flow

## 0.1 Image Gray Scale

This flow is used to gray-scale the input image data.

Gray-scale Processing Flow：

<img src=".\other\imag gray flow.png" width = 500>

Gray-scale Operation：

<img src=".\other\gray calculation.png" width = 500>

## 0.2 Gaussian Filter

This flow is used to perform Gaussian filtering on the gray-scale image data.

Gaussian Filter Processing Flow：

<img src=".\other\filter flow.png" width = 500>

Gaussian Filter Operation：

<img src=".\other\filter operation.png" width = 500>

## 0.3 Sobel Edge Detection

This flow is used to perform sobel edge detection on the gray-scale image data.

Sobel Edge Detection Processing Flow：

<img src=".\other\sobel detector flow.png" width = 500>

Sobel Edge Detection Operation：

<img src=".\other\sobel operation.png" width = 400>

# 1. Hardware

In the folder of 'hardware', There are three folders of hardware source code files corresponding to three different image processing functions.

One other thing worth noting is the configuration of the ROM for the FPGA-based BRAMs.

## 1.1 rgb2gray single setting:

<img src=".\other\rgb2gray_singlerom_setting.png" width = 700>

## 1.2 filter&sobel single setting:

<img src=".\other\filter&sobel_singlerom_setting.png" width = 700>

# 2. Software

## 2.1 Matlab

### (1) img512.m

Due to the storage of ROM and the way of data shifting, it is necessary to shape the image that you used into a 512\*512 image data. Then, this function is used to transform to generate a 512\*512 image data.

### (2) im2coe_565.m

Since data in 565 format is easier to save in FPGAs, the provided image data needs to be converted to 565 format and stored as a coe file and later put into ROM when converting a color map to a grayscale map.

### (3) hex2im.m

Converts a hexadecimal file that has been greyscaled and received by uart into a greyscale image.

### (4) im2coe_gray.m

Converts the greyscaled image to a coe file and stores it in ROM.

## 2.2 py_face_detector

This is a python program that uses the opencv library to detect faces in the image. 

### (1) haarcascade_frontalface_alt2.xml

Requires <u>**cv2**</u> dependencies. The haarcascade_frontalface_alt2.xml file is the classifier.

### (2) detector.py

Detects faces with colorful image.

### (3) detector_gray.py

Detects faces with grayscale image.

## 2.3 UART Transmission

### XCOM V2.0.exe

The XCOM V2.0 file is used to recept the data from FPGA.

<img src=".\other\XCOM.png" width = 700>

You should set the Baud Rate to 115200 and the Parity to None, and so on just like the picture. <u>It must be noted that the position of **'1'** in the diagram, and then the number of data after receiving all the data must be 512\*512 = 2662144.</u> If not, please reset. About 6~7s per run.

# 3. Operation Flow

When you have constructs the corresponding hardware and software, you can run the program as follows:

<img src=".\other\Operation Flow.png" width = 700>

# 4. Conclusion

In this simple project, based on ZYNQ7020 of FPGA, three functions of image processing are implemented: 1. image greyscaling, 2. image Gaussian filtering, and 3. image edge detection. And Matlab is used to write the corresponding programme to implement the image processing functions. Write the program for face detection using python-opencv library to implement the function of face detection. Use XCOM V2.0.exe to achieve the function of serial communication.

But there are still the following can be improved: 1. UART communication is slow, can be used in other high-speed communication methods; 2. For convenience, the whole picture is currently stored in the FRAM of the FPGA, you can consider storing the picture in the SD card, and then use the DDR for data retrieval, reducing the pressure of on-chip storage。