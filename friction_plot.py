# -*- coding: utf-8 -*-
# @Time    : 2022/10/31 上午9:20
# @Author  : XXX
# @Site    : 
# @File    : friction_plot.py
# @Project : PyCharm 
# @Explain : 对摩擦的绘图

import numpy as np
import matplotlib.pyplot as plt
import scipy.io as scio
import scipy.signal as signal

mat_path = './Joint_raw.mat'

load_mat = scio.loadmat(mat_path)
data = load_mat['Joint_raw']
print(type(data), data.shape)
print(type(data[0,2]), data[0,2].shape)
# load_mat为字典类型, <class 'dict'>
print(type(load_mat))

# coding=utf-8

# plt.rcParams['font.sans-serif'] = ['Arial']  # 如果要显示中文字体,则在此处设为：SimHei
# plt.rcParams['font.sans-serif'] = ['Times New Roman']  # 如果要显示中文字体,则在此处设为：SimHei
plt.rcParams['axes.unicode_minus'] = False  # 显示负号
plt.rc('font',family='Times New Roman')

# x = np.array([i for i in range(data[5,1].shape[0])])
x = data[5,1][:,0] - data[5,1][0,0]
for i in range(5):
    print("x[",i,"]=",x[i])
print(x[120000], ', ', x[200000])
tau = (data[5,2][:,0]*101 - data[5,5][:,0])
vel = data[5,3][:,0] * 2 * np.pi / 60 / 101
pos = data[5,4][:,0]

x = x[120000:200000]
tau = tau[120000:200000]
vel = vel[120000:200000]
pos = pos[120000:200000]


tau_mean = signal.medfilt(tau, 401)
vel_mean = signal.medfilt(vel, 401)
print(x.shape)
print(tau.shape)
print(vel.shape)
print(pos.shape)
# ourNetwork = np.array([2.0205495, 2.6509762, 3.1876223, 4.380781, 6.004548, 9.9298])

# label在图示(legend)中显示。若为数学公式,则最好在字符串前后添加"$"符号
# color：b:blue、g:green、r:red、c:cyan、m:magenta、y:yellow、k:black、w:white、、、
# 线型：-  --   -.  :    ,
# marker：.  ,   o   v    <    *    +    1
# plt.figure(figsize=(10, 5))
plt.figure()
plt.grid(linestyle="--")  # 设置背景网格线为虚线
ax = plt.gca()
ax.spines['top'].set_visible(False)  # 去掉上边框
ax.spines['right'].set_visible(False)  # 去掉右边框

# plt.subplot(131)
# plt.plot(x, tau, marker='o', color="blue", label="friction", linewidth=1.5)
plt.plot(x, pos, color='#0c84c6', linewidth=1.5)
# plt.plot(x, vel, color='#0c84c6', label="Measured Position", linewidth=1.5)
# plt.plot(x, vel_mean, color="#f74d4d", label="Mean Value", linewidth=1.5)
# plt.subplot(132)
# plt.plot(x, vel[460:615], color="green", label="velocity", linewidth=1.5)
# plt.subplot(133)
# plt.plot(x, pos[460:615], color="red", label="pos", linewidth=1.5)

# group_labels = ['Top 0-5%', 'Top 5-10%', 'Top 10-20%', 'Top 20-50%', 'Top 50-70%', ' Top 70-100%']  # x轴刻度的标识
# plt.xticks(x, group_labels, fontsize=12, fontweight='bold')  # 默认字体大小为10
# plt.yticks(fontsize=12, fontweight='bold')
# plt.title("example", fontsize=12, fontweight='bold')  # 默认字体大小为12
plt.xlabel("Time (s)")
# plt.ylabel("Velocity (rad/s)", fontsize=13)
plt.ylabel("Joint Angle (deg)")
# plt.xlim(0.9, 6.1)  # 设置x轴的范围
# plt.ylim(1.5, 16)

# plt.legend()          #显示各曲线的图例
# plt.legend(loc=0, numpoints=1)
# leg = plt.gca().get_legend()
# ltext = leg.get_texts()
# plt.setp(ltext, fontsize=12, fontweight='bold')  # 设置图例字体的大小和粗细
# plt.setp(ltext)  # 设置图例字体的大小和粗细

# plt.savefig('./Joint6-pos.svg', format='svg')  # 建议保存为svg格式,再用inkscape转为矢量图emf后插入word中
plt.show()

# for i,j in load_mat.items():
#     print(i)
'''
# 访问load_mat即为访问字典
X_src = load_mat['X_src']
# 这个X_src为numpy类型，<class 'numpy.ndarray'>
print(type(X_src))
Y_src = load_mat['Y_src']
# 这个Y_src为numpy类型，<class 'numpy.ndarray'>
print(type(Y_src))
'''