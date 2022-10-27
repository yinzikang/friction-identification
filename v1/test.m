data_dir = './data/';
joint_idx_list = [6, 5, 4, 3, 2, 1];
speed_num_list = [22, 21, 18, 21, 14, 20];
[result, point_set] = friction_para_identification_dir(data_dir, joint_idx_list, speed_num_list);


% file_name = './data/data-2022-10-08-14_35_38.txt';
% joint_idx = 6;
% real_speed_num = 22;
% [result, point_set] = friction_para_identification_file(file_name, joint_idx, real_speed_num);

