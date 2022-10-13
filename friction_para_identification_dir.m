% 使用如下
% data_dir = './data/';
% joint_idx_list = [6, 5, 4, 3, 2, 1];
% speed_num_list = [22, 21, 18, 21, 14, 20];
% [result, point_set] = friction_para_identification_dir(data_dir, joint_idx_list, speed_num_list);

function [para_and_func, joint_t_v_mean] = friction_para_identification_dir(data_dir, joint_idx_list, speed_num_list)
    % 读取文件，文件为驱动器端速度和力矩的原始数据等
    % 对不同速度分割
    % 滤波
    % 得到该速度下摩擦力与速度
    % 得到摩擦力与速度曲线并拟合得到参数
    % 返回值为元组，元组每个元素也为元组，与文件一一对应
    % 每个文件元组元素包含两个元组，对应正转与反转
    % 每个正转与反转元组中包含一个cfit与一个struct，分别为拟合的模型、参数与相关指标
    file_table = dir([data_dir '*.txt']);
    file_num = length(file_table); %一共的文件数
    for file_idx = 1 : file_num
        % 加载文件、分割、返回分割点
        file_name = [data_dir file_table(file_idx).name];
        joint_idx = joint_idx_list(file_idx); % 时间越往后，关节越往前
        real_speed_num = speed_num_list(file_idx); %每个关节运行的速度数（只考虑大小未考虑方向）
        [para_and_func{file_idx}, joint_t_v_mean{file_idx}] = friction_para_identification_file(file_name, joint_idx, real_speed_num); 
    end
end






