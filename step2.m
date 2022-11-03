clear;clc;close all;
load("Joint_raw.mat")
[row_num, col_num] = size(Joint_raw);
save_flag = 1;
close_flag = 1;
gravity_flag = 1;

% 全文件处理，自动参数调节，效果一般
% for i = 1:row_num
%     % 取cell的第x列不能用cell{:,x}，需要按照下面的写法来取
%     data = Joint_raw(i, 1:end);
%     jnt_num = data{1,1};
%     split_idx = sequence_split(data, jnt_num, save_flag, close_flag, gravity_flag);
%     disp(length(split_idx));
%     joint_t_v_mean = tor_vel_mean_cal(data, split_idx, jnt_num, gravity_flag);
%     disp(joint_t_v_mean(:,2)')
%     para_and_func = fric_curve_fitting(joint_t_v_mean, jnt_num, save_flag, close_flag, gravity_flag);
%     clear split_idx  joint_t_v_mean para_and_func;
% end

% 单个文件处理，用于手动参数调节
% num = 3;
% for i = num:num
%     % 取cell的第x列不能用cell{:,x}，需要按照下面的写法来取
%     data = Joint_raw(i, 1:end);
%     jnt_num = data{1,1};
%     split_idx = sequence_split(data, jnt_num, save_flag, close_flag, gravity_flag);
%     disp(length(split_idx));
%     joint_t_v_mean = tor_vel_mean_cal(data, split_idx, jnt_num, gravity_flag);
%     disp(joint_t_v_mean(:,2)')
% %     para_and_func = fric_curve_fitting(joint_t_v_mean, jnt_num, save_flag, close_flag, gravity_flag);
% %     clear split_idx  joint_t_v_mean para_and_func;
%     torque = joint_t_v_mean(:,1);
%     vel = joint_t_v_mean(:,2);
%     pos_idx = find(vel>0);
%     neg_idx = find(vel<0);
%     vp = vel(pos_idx(1:end));
%     vn = vel(neg_idx(1:end));
%     tp = torque(pos_idx);
%     tn = torque(neg_idx);
% end

% 全文件分割与均值保存
joint_t_v_mean = cell(1,6);
for i = 1:row_num
    % 取cell的第x列不能用cell{:,x}，需要按照下面的写法来取
    data = Joint_raw(i, 1:end);
    jnt_num = data{1,1};
    split_idx = sequence_split(data, jnt_num, save_flag, close_flag, gravity_flag);
    disp(length(split_idx));
    joint_t_v_mean{1,i} = tor_vel_mean_cal(data, split_idx, jnt_num, gravity_flag);
%     disp(joint_t_v_mean(:,2)')
end    

%% 加载文件，分割点位并返回
function split_idx_list = sequence_split(current_file, joint_idx, save_flag, close_flag, gravity_flag)
    % 文件内容为：关节号+时间+关节力矩+关节速度+关节位置+关节重力矩+空间位姿
    time_stamp = current_file{2};
    data_length = length(time_stamp);
    % 实际运动的关节
    joint_torque = current_file{3};
    joint_vel = current_file{4};
    joint_pos = current_file{5};

    % 对不同速度段运动进行分割（利用关节速度）
    %%% 首先滤波去除曲线平滑，并利用符号函数求出所有跳变点，包括返回原值与跳变为相反值
    mmm = medfilt2(joint_vel, [500, 1]);
    figure(999);
    plot(joint_vel);hold on;
    plot(mmm);
    direction_sign = sign(medfilt2(joint_vel, [500, 1]));  % 这里的滤波不用来求均值，仅用来判断分割点
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

    % 画出信号与分隔，这里用的中值滤波只是显示用，实际求的时候不是这样的
    plot_fig = 1;
    if plot_fig
        if gravity_flag
            fig_dir = './figs/gravity_flag/';
        else
            fig_dir = './figs/';
        end
        fig = figure(1);
        hold on
        plot(joint_torque)
        plot(direction_sign)
        grid on;
        scatter(split_idx_list, zeros(size(split_idx_list)),'MarkerFaceColor',[1 1 1])
        if save_flag
            saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' torque.jpg']);
        end
        if close_flag
            close(fig);
        end

        fig = figure(2);
        plot(joint_vel)
        hold on
        plot(150 .* direction_sign)
        grid on;
        scatter(split_idx_list, zeros(size(split_idx_list)),'MarkerFaceColor',[1 1 1])
        if save_flag
            saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' vel.jpg']);
        end
        if close_flag
            close(fig);
        end
    end
end

%% 利用分割点计算每段力矩、速度的均值
function joint_t_v_mean = tor_vel_mean_cal(current_file, split_idx_list, joint_idx,gravity_flag)
    % 文件内容为：时间+关节力矩+关节速度+关节位置
    time_stamp = current_file{2};
    data_length = length(time_stamp);
    % 实际运动的关节
    joint_torque = current_file{3};
    joint_vel = current_file{4};
    joint_pos = current_file{5};
    gravity_torque = current_file{6};
    % 计算均值，这里和求分割点时用均值函数来求并不一样
    joint_t_v_mean = zeros(2*(length(split_idx_list)-1),2); % 存储力矩速度对
    for speed_idx = 1 : length(split_idx_list)-1
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
        if gravity_flag
            joint_t_v_mean(2 * speed_idx - 1, 1) = mean(joint_torque(p1:p2)*Ng -  gravity_torque(p1:p2));
            joint_t_v_mean(2 * speed_idx, 1) = mean(joint_torque(p3:p4)*Ng -  gravity_torque(p3:p4));
        else
            joint_t_v_mean(2 * speed_idx - 1, 1) = mean(joint_torque(p1:p2))*Ng;
            joint_t_v_mean(2 * speed_idx, 1) = mean(joint_torque(p3:p4))*Ng;
        end      
        
        joint_t_v_mean(2 * speed_idx - 1, 2) = mean(joint_vel(p1:p2)) * 2 * pi / 60 / Ng;
        joint_t_v_mean(2 * speed_idx, 2) = mean(joint_vel(p3:p4)) * 2 * pi / 60 / Ng;
    end
end

%% 摩擦曲线拟合
function para_and_func = fric_curve_fitting(joint_t_v_mean, joint_idx, save_flag, close_flag,gravity_flag)
    % 指明自变量以及待解参数
    % a .* (tanh(b .* x) - tanh(c .*x)) + d .* tanh(e .* x) + f .* x
    syms x;
    f = fittype('(a + (b - a) .* exp(-(x./c) .* (x./c))) .* sign(x) + d .* x','independent','x','coefficients',{'a','b','c','d'});
    % 指明拟合参数，不同参数可能导致不同拟合效果
%     options = fitoptions(f);
%     options.Robust = 'Bisquare'; % For most cases, the bisquare weight method is preferred over LAR
%     options.StartPoint = 0 * ones(1,4);
%     options.Lower = -100 * ones(1,4);
%     options.Upper = 100 * ones(1,4);
%     options.DiffMaxChange = 1.0e-1;
%     options.DiffMinChange = 1.0e-09;
%     options.MaxFunEvals = 4e6;
%     options.MaxIter = 4e6;
%     options.TolFun = 1.0e-9;
%     options.TolX = 1.0e-9;
    % 对正转与反转进行拟合得到两组各4个参数
    torque = joint_t_v_mean(:,1);
    vel = joint_t_v_mean(:,2);
    pos_idx = find(vel>0);
    neg_idx = find(vel<0);
    % 返回函数以及函数输出设置，函数可用来做图cfun(x)，函数输出设置可选rsquare等
    [cfun_p,rsquare_p]=fit(vel(pos_idx), torque(pos_idx), f,...
        'StartPoint', [-10,-100,-5,-10],...
        'Lower', -100 * ones(1,4),...
        'Upper', 100 * ones(1,4),...
        'DiffMaxChange', 1.0e-1,...
        'DiffMinChange', 1.0e-09,...
        'MaxFunEvals', 4e6,...
        'MaxIter', 4e6,...
        'TolFun', 1.0e-9,...
        'TolX', 1.0e-9);
    [cfun_n,rsquare_n]=fit(vel(neg_idx), torque(neg_idx), f,...
        'StartPoint', [-10,-100,-5,-10],...
        'Lower', [-10,-100,-5,-10],...
        'Upper', 100 * ones(1,4),...
        'DiffMaxChange', 1.0e-1,...
        'DiffMinChange', 1.0e-09,...
        'MaxFunEvals', 4e6,...
        'MaxIter', 4e6,...
        'TolFun', 1.0e-9,...
        'TolX', 1.0e-9);
    para_and_func = {{cfun_p,rsquare_p},{cfun_n,rsquare_n}};
    % 保存图片
    plot_fig = 1;
    if plot_fig
        if gravity_flag
            fig_dir = './figs/gravity_flag/';
        else
            fig_dir = './figs/';
        end
        fig = figure(1);
        plot(cfun_p, vel(pos_idx), torque(pos_idx));
        grid on;
        if save_flag
            saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' positive.jpg']);
        end
        if close_flag
            close(fig);
        end
        fig = figure(2);
        plot(cfun_n, vel(neg_idx), torque(neg_idx));
        grid on;
        if save_flag
            saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' negative.jpg']);
        end
        if close_flag
            close(fig);
        end
    end
end

