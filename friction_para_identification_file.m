% 使用如下
% file_name = './data/data-2022-10-08-14_35_38.txt';
% joint_idx = 6;
% real_speed_num = 22;
% [result, point_set] = friction_para_identification_file(file_name, joint_idx, real_speed_num)

function [para_and_func, joint_t_v_mean] = friction_para_identification_file(file_name, joint_idx, real_speed_num)
    % 读取文件，文件为驱动器端速度和力矩的原始数据等
    % 对不同速度分割
    % 滤波
    % 得到该速度下摩擦力与速度
    % 得到摩擦力与速度曲线并拟合得到参数
    % 返回值为元组，元组每个元素也为元组，与文件一一对应
    % 每个文件元组元素包含两个元组，对应正转与反转
    % 每个正转与反转元组中包含一个cfit与一个struct，分别为拟合的模型、参数与相关指标
    current_file = load(file_name);
    [split_flag, split_idx_list] = sequence_split(current_file, joint_idx, real_speed_num);
    % 分割无误则计算速度与力矩均值
    if split_flag
        error('分割出错');
    end
    joint_t_v_mean = tor_vel_mean_cal(current_file, split_idx_list, joint_idx, real_speed_num);
    % 拟合
    para_and_func = fric_curve_fitting(joint_t_v_mean, joint_idx);
end






