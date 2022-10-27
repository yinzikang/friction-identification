% 摩擦曲线拟合
function para_and_func = fric_curve_fitting(joint_t_v_mean, joint_idx)
    %% 指明自变量以及待解参数
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
    %% 对正转与反转进行拟合得到两组各4个参数
    torque = joint_t_v_mean(:,1);
    vel = joint_t_v_mean(:,2);
    % 返回函数以及函数输出设置，函数可用来做图cfun(x)，函数输出设置可选rsquare等
    [cfun_p,rsquare_p]=fit(vel(vel>0), torque(torque>0), f);
    [cfun_n,rsquare_n]=fit(vel(vel<0), torque(torque<0), f);
    para_and_func = {{cfun_p,rsquare_p},{cfun_n,rsquare_n}};
    %% 保存图片
    plot_fig = 1;
    if plot_fig
        fig_dir = './figs/';
        fig = figure(1);
        plot(cfun_p, vel(vel>0), torque(torque>0));
        saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' positive.jpg']);
        close(fig);
        fig = figure(2);
        plot(cfun_n, vel(vel<0), torque(torque<0));
        saveas(gcf,[fig_dir, 'joint ', num2str(joint_idx), ' negative.jpg']);
        close(fig);
    end
end

