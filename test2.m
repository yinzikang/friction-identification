clear;clc;close all;
load("Joint_raw.mat")
[row_num, col_num] = size(Joint_raw);
save_flag = 1;
close_flag = 1;
gravity_flag = 1;
num = 1;
for i = num:num
    % 取cell的第x列不能用cell{:,x}，需要按照下面的写法来取
    data = Joint_raw(i, 1:end);
    jnt_num = data{1,1};
    split_idx = sequence_split(data, jnt_num, save_flag, close_flag, gravity_flag);
    disp(length(split_idx));
    joint_t_v_mean = tor_vel_mean_cal(data, split_idx, jnt_num, gravity_flag);
    disp(joint_t_v_mean(:,2)')
%     para_and_func = fric_curve_fitting(joint_t_v_mean, jnt_num, save_flag, close_flag, gravity_flag);
%     clear split_idx  joint_t_v_mean para_and_func;
    torque = joint_t_v_mean(:,1);
    vel = joint_t_v_mean(:,2);
    pos_idx = find(vel>0);
    neg_idx = find(vel<0);
end