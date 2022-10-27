#!/usr/bin/env python
# -*- encoding: utf-8 -*-
"""
@Target :   to test differential evolution algorithm
@File   :   differential_evolution.py    
@author :   yinzikang

@Modify Time      @Author    @Version    @Description
------------      -------    --------    -----------
4/17/22 11:52 AM   yinzikang      1.0         None
"""
import numpy as np
import matplotlib.pyplot as plt


def population_init(population_number, individual_dimension, individual_limitation):
    population = np.empty([population_number] + individual_dimension)
    for i in range(population_number):
        population[i] = np.random.uniform(individual_limitation[0], individual_limitation[1], individual_dimension)
        # print(population[i])

    return population


def mutation(population_number, population_origin, mutation_operator_ratio):
    index_table = range(population_number)
    population_mutation = np.zeros_like(population_origin)
    for i in range(population_number):
        mutation_index = np.random.choice(np.delete(index_table, i), 3, replace=False)
        population_mutation[i] = population_origin[mutation_index[0]] + mutation_operator_ratio * \
                                 (population_origin[mutation_index[1]] - population_origin[mutation_index[2]])
        # print(mutation_index)
        # print('number', i, 'before mutation: ', population_mutation[i])
        # print('number', i, 'after mutation: ', population_origin[mutation_index[0]])

    return population_mutation


def crossover(population_number, individual_dimension, population_origin, population_mutation,
              crossover_operator_ratio):
    population_crossover = np.zeros_like(population_origin)
    for i in range(population_number):
        crossover_table = np.random.uniform(size=individual_dimension)
        population_crossover[i] = np.where(crossover_table < crossover_operator_ratio,
                                           population_origin[i], population_mutation[i])
        # print('table:', crossover_table)
        # print('crossover_ratio', crossover_operator_ratio)
        # print('population_crossover', population_crossover[i])
        # print('population_origin', population_origin[i])
        # print('population_mutation', population_mutation[i])

    return population_crossover


def clip(population_number, individual_limitation, population_crossover):
    population_clip = np.zeros_like(population_crossover)
    for i in range(population_number):
        np.clip(population_crossover[i], individual_limitation[1], individual_limitation[0], out=population_clip[i])
        # print('before clip:', population_crossover[i])
        # print('after clip:', population_clip[i])

    return population_clip


def selection(target_function, population_number, population_origin, population_clip, old_score, extra_data=None):
    population_selection = np.zeros_like(population_origin)
    new_score = target_function(population_clip, extra_data)
    for i in range(population_number):
        population_selection[i] = population_clip[i] if old_score[i] > new_score[i] else population_origin[i]
        # print('old_generation',population_origin[i])
        # print('new_generation',population_clip[i])
        # print('selected_generation',population_selecton[i])

    return population_selection, target_function(population_selection, extra_data)


def differential_evolution_algorithm(target_function,
                                     individual_dimension,
                                     individual_limitation,
                                     population_number: int = 0,
                                     generation_number: int = 0,
                                     mutation_operator_ratio: float = 0,
                                     crossover_operator_ratio: float = 0,
                                     extra_data=None):
    score = np.empty([generation_number + 1, population_number])
    # initialize population
    population_origin = population_init(population_number,
                                        individual_dimension,
                                        individual_limitation)
    score[0] = target_function(population_origin, extra_data)
    root = np.argmin(score[0])
    for generation_index in range(generation_number):
        # mutation operation
        population_mutation = mutation(population_number,
                                       population_origin,
                                       mutation_operator_ratio)
        # crossover operation
        population_crossover = crossover(population_number,
                                         individual_dimension,
                                         population_origin,
                                         population_mutation,
                                         crossover_operator_ratio)
        # clip operation
        population_clip = clip(population_number,
                               individual_limitation,
                               population_crossover)
        # selection operation
        population_selection, score[generation_index + 1] = selection(target_function,
                                                                      population_number,
                                                                      population_origin,
                                                                      population_clip,
                                                                      score[generation_index],
                                                                      extra_data)
        # reset new generation
        population_origin = population_selection
        root = np.argmin(score[generation_index + 1])
        # print(score[generation_index + 1].min())

    return score, population_origin[root]


if __name__ == "__main__":
    def function(population,data=None):
        # score = [np.linalg.norm(population[i], ord=np.inf) for i in range(population.shape[0])]
        score = [np.cos(population[i, 0, 0] * population[i, 1, 0]) + population[i, 0, 0] + population[i, 1, 0]
                 for i in range(population.shape[0])]
        return score


    # dimension = [2, 5]  # x,y * t=3
    # limit_max = [[20., 20., 20., 20., 20.],
    #              [20., 20., 20., 20., 20.]]
    # limit_min = [[-20., -20., -20., -20., -20.],
    #              [-20., -20., -20., -20., -20.]]
    dimension = [2, 1]
    limit_max = [[5.], [5.]]
    limit_min = [[-5.], [-5.]]
    p_number = 10
    g_number = 40
    m_ratio = 0.5
    c_ratio = 0.1

    score_of_function, root = differential_evolution_algorithm(target_function=function,
                                                               individual_dimension=dimension,
                                                               individual_limitation=[limit_max, limit_min],
                                                               population_number=p_number,
                                                               generation_number=g_number,
                                                               mutation_operator_ratio=m_ratio,
                                                               crossover_operator_ratio=c_ratio)
    print(root)
    plt.figure(1)
    plt.subplot(121)
    plt.plot(score_of_function)
    plt.xlabel('generation')
    plt.ylabel('score')
    plt.title('score of every individual')
    plt.subplot(122)
    plt.plot(score_of_function.min(axis=1))
    plt.xlabel('generation')
    plt.ylabel('score')
    plt.title('best score of each generation')
    plt.show()
