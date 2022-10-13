% 加载文件，分割点位并返回
function [split_flag, split_idx_list] = sequence_split(current_file, joint_idx, real_speed_num)
    %% 文件内容为：时间+关节力矩+关节速度+关节位置
    time_stamp = current_file(:, 1);
    data_length = length(time_stamp);
    % 实际运动的关节
    joint_torque = current_file(:, joint_idx + 1);
    joint_vel = current_file(:, joint_idx + 7);
    joint_pos = current_file(:, joint_idx + 13);

    %% 对不同速度段运动进行分割（利用关节速度）
    %%% 首先滤波去除曲线平滑，并利用符号函数求出所有跳变点，包括返回原值与跳变为相反值
    direction_sign = sign(medfilt2(joint_vel, [500, 1]));
    %%% 对于每一组速度进行切换，应当为从-1（再至0）最后至1
    split_idx_list = [];
    split_idx_list(1) = 0; % 起点
    j = 2;
    left_idx = [];
    for i = 2 : data_length
        if direction_sign(i) == 1
            left_idx = i;
        end
        if (direction_sign(i) == -1) && (~isempty(left_idx))
            right_idx = i;
            split_idx_list(j) = floor((left_idx + right_idx) / 2);
            j = j + 1;
            left_idx = [];
        end
    end
    if split_idx_list(end) < data_length - 500 % 终点
        split_idx_list(end + 1) = data_length;
    end
    %%% 统计一共有多少种速度
    pred_speed_num = length(split_idx_list) - 1;
    if pred_speed_num == real_speed_num
        split_flag = 0;
    else
        split_flag = 1;
    end
    %% 画出信号与分隔
    plot_fig = 1;
    if plot_fig
        fig_dir = './figs/';
        fig = figure(1);
        hold on
        plot(joint_torque)
        plot(direction_sign)
        scatter(split_idx_list, zeros(size(split_idx_list)),'MarkerFaceColor',[1 1 1])
        saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' torque.jpg']);
        close(fig);

        fig = figure(2);
        plot(joint_vel)
        hold on
        plot(150 .* direction_sign)
        scatter(split_idx_list, zeros(size(split_idx_list)),'MarkerFaceColor',[1 1 1])
        saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' vel.jpg']);
        close(fig);
    end
end