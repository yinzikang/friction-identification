#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""Write target here

Write detailed description here

Write typical usage example here

@Modify Time      @Author    @Version    @Description
------------      -------    --------    -----------
10/31/22 6:19 PM   yinzikang      1.0         None
"""
import numpy
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import scipy.io as scio
import scipy.signal as signal


def Stribeck(para_list, v_array):
    tc = para_list[0]
    ts = para_list[1]
    qs = para_list[2]
    fv = para_list[3]
    v_array = v_array
    t_array = [tc + (ts - tc) * numpy.exp(-(v_array / qs) ** 2)] * numpy.sign(v_array) + fv * v_array
    return t_array.reshape(-1)


mean_file = scio.loadmat('./joint_t_v_mean_with_g.mat')  # 已经经过单位变换后的力矩与速度
data_mean = mean_file['joint_t_v_mean']
para_file = df = pd.read_excel('results_with_g.xls', 'Sheet1', header=None)
para = np.array(para_file)

dot_color_list = ['#CD5C5C', '#00FF00', '#4169E1']
line_color_list = ['#F08080', '#008000', '#6495ED']
plt.figure(1)
plt.grid(linestyle="--")  # 设置背景网格线为虚线
plt.rcParams['axes.unicode_minus'] = False  # 显示负号
plt.rc('font', family='Times New Roman')
ax = plt.gca()
ax.spines['top'].set_visible(False)  # 去掉上边框
ax.spines['right'].set_visible(False)  # 去掉右边框

for joint_index in range(3):
    torque_mean = data_mean[0, joint_index][:, 0]
    vel_mean = data_mean[0, joint_index][:, 1]
    fitness_para = para[joint_index]  # 四维参数，负正共八个
    v_array_p = numpy.linspace(0, vel_mean.max(), num=1000)
    t_array_p = Stribeck(fitness_para[:4], v_array_p)
    v_array_n = numpy.linspace(0, vel_mean.min(), num=1000)
    t_array_n = Stribeck(fitness_para[4:], v_array_n)
    plt.scatter(vel_mean, torque_mean, color=dot_color_list[joint_index], s=2, marker="o")
    plt.plot(v_array_p, t_array_p, color=line_color_list[joint_index], linewidth=1.5)
    plt.plot(v_array_n, t_array_n, color=line_color_list[joint_index], linewidth=1.5)
plt.show()

plt.figure(2)
plt.grid(linestyle="--")  # 设置背景网格线为虚线
plt.rcParams['axes.unicode_minus'] = False  # 显示负号
plt.rc('font', family='Times New Roman')
ax = plt.gca()
ax.spines['top'].set_visible(False)  # 去掉上边框
ax.spines['right'].set_visible(False)  # 去掉右边框

for joint_index in range(3, 6):
    torque_mean = data_mean[0, joint_index][:, 0]
    vel_mean = data_mean[0, joint_index][:, 1]
    fitness_para = para[joint_index]  # 四维参数，负正共八个
    v_array_p = numpy.linspace(0, vel_mean.max(), num=1000)
    t_array_p = Stribeck(fitness_para[:4], v_array_p)
    v_array_n = numpy.linspace(0, vel_mean.min(), num=1000)
    t_array_n = Stribeck(fitness_para[4:], v_array_n)
    plt.scatter(vel_mean, torque_mean, color=dot_color_list[joint_index - 3], s=2, marker="o")
    plt.plot(v_array_p, t_array_p, color=line_color_list[joint_index - 3], linewidth=1.5)
    plt.plot(v_array_n, t_array_n, color=line_color_list[joint_index - 3], linewidth=1.5)
plt.show()
