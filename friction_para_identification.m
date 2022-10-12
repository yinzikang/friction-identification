% 使用如下
% data_dir = './data/';
% speed_num_list = [22,21,18,21,14,20];
% [result, point_set, para_set] = friction_para_identification(data_dir,speed_num_list);

function [result, point_set, para_set] = friction_para_identification(data_dir, speed_num_list)
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
    speed_num = zeros(1,6); %每个关节运行的速度数（只考虑大小未考虑方向）
    fig_dir = './figs/';
    for file_idx = 1 : file_num
        %% 文件加载
        current_file = load([data_dir file_table(file_idx).name]);
        % 文件内容为：时间+关节力矩+关节速度+关节位置
        data_length = length(current_file);
        time_stamp = current_file(:, 1);
        % 实际运动的关节
        joint_idx = 7 - file_idx; % 时间越往后，关节越往前
        joint_torque = current_file(:, 8 - file_idx);
        joint_vel = current_file(:, 14 - file_idx);
        joint_pos = current_file(:, 20 - file_idx);
        
        %% 对不同速度段运动进行分割（利用关节速度）
        %%% 首先滤波去除曲线平滑，并利用符号函数求出所有跳变点，包括返回原值与跳变为相反值
        direction_sign = sign(medfilt2(joint_vel, [500, 1]));
        %%% 对于每一组速度进行切换，应当为从-1（再至0）最后至1
        split_idx_list = [];
        split_idx_list(1) = 0;
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
        if split_idx_list(end) < data_length - 500
            split_idx_list(end + 1) = data_length;
        end
        %%% 统计一共有多少种速度
        speed_num(file_idx) = length(split_idx_list) - 1;
        %%% 画出信号与分隔
        plot_fig = 1;
        if plot_fig
            fig = figure(2 * file_idx - 1);
            hold on
            plot(joint_torque)
            plot(direction_sign)
            scatter(split_idx_list, zeros(size(split_idx_list)),'MarkerFaceColor',[1 1 1])
            saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' torque.jpg']);
            close(fig);
            
            fig = figure(2 * file_idx);
            plot(joint_vel)
            hold on
            plot(150 .* direction_sign)
            scatter(split_idx_list, zeros(size(split_idx_list)),'MarkerFaceColor',[1 1 1])
            saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' vel.jpg']);
            close(fig);
        end
        
        %% 对每个分割求均值并记录点位
        joint_t_v_mean = zeros(2*speed_num(file_idx),2); % 存储力矩速度对
        for speed_idx = 1 : speed_num(file_idx)
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
        point_set{file_idx} = joint_t_v_mean;
        
        %% 拟合
        % 指明自变量以及待解参数
        syms x;
        f = fittype('(a + (b - a) .* exp(-(x./c) .* (x./c))) .* sign(x) + d .* x','independent','x','coefficients',{'a','b','c','d'});
        % 指明拟合参数，不同参数可能导致不同拟合效果
        options = fitoptions(f);
        options.DiffMaxChange = 1.0e-8;
        options.DiffMinChange = 1.0e-8;
        options.MaxFunEvals = 20000;
        options.MaxIter = 20000;
        options.TolFun = 1.0e-6;
        options.TolX = 1.0e-6;
        % 对正转与反转进行拟合得到两组各4个参数
        torque = joint_t_v_mean(:,1);
        vel = joint_t_v_mean(:,2);
        % 返回函数以及函数输出设置，函数可用来做图cfun(x)，函数输出设置可选rsquare等
        [cfun_p,rsquare_p]=fit(vel(vel>0), torque(torque>0), f);
        [cfun_n,rsquare_n]=fit(vel(vel<0), torque(torque<0), f);
        % 保存图片
        fig = figure(1);
        plot(cfun_p, vel(vel>0), torque(torque>0));
        saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' positive.jpg']);
        close(fig);
        fig = figure(2);
        plot(cfun_n, vel(vel<0), torque(torque<0));
        saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' negative.jpg']);
        close(fig);
        para_set{file_idx} = {{cfun_p,rsquare_p},{cfun_n,rsquare_n}};
    end
    if isequal(speed_num,speed_num_list)
        result = 0;
    else
        result = 1;
    end
end



