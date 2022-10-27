#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""利用差分进化算法解决全局寻优问题

Write detailed description here

Write typical usage example here

@Modify Time      @Author    @Version    @Description
------------      -------    --------    -----------
10/26/22 9:01 PM   yinzikang      1.0         None
"""

import scipy.io as scio

import numpy as np
import matplotlib.pyplot as plt
from differential_evolution import differential_evolution_algorithm as de

# def function(population, data):
#     score = np.zeros(population.shape[0])
#     # every individual
#     # t = f(v)
#     for i in range(population.shape[0]):

data = scio.loadmat('Joint_raw.mat')['Joint_raw']

dimension = [1, 4]  # x,z * t
limit_max = [[10, 10., 10., 10.]]
limit_min = [[-10, -10., -10., -10.]]
p_number = 150
g_number = 400
m_ratio = 0.25
c_ratio = 0.1
np.random.seed(32)
score_of_function_de, root_de = de(target_function=function,
                                   individual_dimension=dimension,
                                   individual_limitation=[limit_max, limit_min],
                                   population_number=p_number,
                                   generation_number=g_number,
                                   mutation_operator_ratio=m_ratio,
                                   crossover_operator_ratio=c_ratio)

plt.figure(1)
plt.subplot(221)
plt.plot(score_of_function_de)
# plt.xlabel('generation')
plt.ylabel('de score')
plt.title('score of every individual')
plt.subplot(222)
plt.plot(score_of_function_de.min(axis=1))
# plt.xlabel('generation')
# plt.ylabel('de score')
plt.title('best score of each generation')