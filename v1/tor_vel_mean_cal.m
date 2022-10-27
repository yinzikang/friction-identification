% 利用分割点计算每段力矩、速度的均值
function joint_t_v_mean = tor_vel_mean_cal(current_file, split_idx_list, joint_idx, speed_num)
    %% 文件内容为：时间+关节力矩+关节速度+关节位置
    time_stamp = current_file(:, 1);
    data_length = length(time_stamp);
    % 实际运动的关节
    joint_torque = current_file(:, joint_idx + 1);
    joint_vel = current_file(:, joint_idx + 7);
    joint_pos = current_file(:, joint_idx + 13);
    %% 计算均值
    joint_t_v_mean = zeros(2*speed_num,2); % 存储力矩速度对
    for speed_idx = 1 : speed_num
        % 前三个关节的传动比为101,后3个为121
        if joint_idx < 4
            Ng = 101;
        else
            Ng = 121;
        end
        start_i = split_idx_list(speed_idx);
        end_i = split_idx_list(speed_idx + 1);
        speed_length = end_i - start_i; %该速度下点的个数
        mid_i = floor((start_i + end_i) / 2);
        tolerance = floor(0.05 *  speed_length);
        p1 = start_i + tolerance;
        p2 = mid_i - tolerance;
        p3 = mid_i + tolerance;
        p4 = end_i - tolerance;
        % 求均值并从驱动器端转换到关节端
        joint_t_v_mean(2 * speed_idx - 1, 1) = mean(joint_torque(p1:p2)) * Ng;
        joint_t_v_mean(2 * speed_idx - 1, 2) = mean(joint_vel(p1:p2)) * 2 * pi / 60 / Ng;
        joint_t_v_mean(2 * speed_idx, 1) = mean(joint_torque(p3:p4)) * Ng;
        joint_t_v_mean(2 * speed_idx, 2) = mean(joint_vel(p3:p4)) * 2 * pi / 60 / Ng;
    end
end