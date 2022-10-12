data_dir = './data/';
speed_num_list = [22,21,18,21,14,20];
[result, point_set, para_set] = friction_para_identification(data_dir,speed_num_list);
% 愚蠢的toolbox只能识别一维数组
% joint_idx = 6;
% Y_data_t = point_set{joint_idx}(:,1);
% X_data_v = point_set{joint_idx}(:,2);
% Y_data_t_p = Y_data_t(Y_data_t>0);
% X_data_v_p = X_data_v(X_data_v>0);
% scatter(Y_data_t_p,X_data_v_p)

% (a + (b - a) .* exp(-(x./d) .* (x./d))) .* sign(x) + e .* x
% 