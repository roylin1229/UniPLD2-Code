clc; clearvars; close all; addpath('./utils_raw/'); addpath('./line_utils/'); addpath('./point_utils/'); warning('off')

tic
img1                                                            = imread('1.ppm');
[kps1, kp_descs1, kp_descs_b1, kls1, kl_descs1, kl_descs_b1]    = UPLD2(img1);
toc

tic
img3                                                            = imread('3.ppm');
[kps3, kp_descs3, kp_descs_b3, kls3, kl_descs3, kl_descs_b3]    = UPLD2(img3);
toc