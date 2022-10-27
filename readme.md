# 数据特点
起始：速度小，存在过0现象；运动时间短，数据多
后期：速度大，不存在过0现象；运动时间短，数据少
每个来回时间不变

# 流程
- 滤波，消除干扰的过零点
- sign确定分割点：左为正右为负则为一个正、逆转周期
- 求均值：取每一个正/逆方向上中间90%的数据，消除两端的上升下降
- 对每个关节同方向上速度进行拟合，得到函数与参数

# 文件
- friction_para_identification
未封装的代码
- friction_para_identification_dir
路径下所有文件进行处理
- friction_para_identification_file
单个文件进行处理

# 其他
- 同关节正逆转差距挺大
- 拟合的参数选择将影响参数结果

# 结果
## num1_p
Coefficients (with 95% confidence bounds):
       a =       41.63  (29.9, 53.35)
       b =       17.97  (17.07, 18.87)
       c =     -0.2613  (-0.3344, -0.1883)
       d =      -30.52  (-66.79, 5.755)

Goodness of fit:
  SSE: 57.02
  R-square: 0.9146
  Adjusted R-square: 0.9074
  RMSE: 1.259


## num1_n
Coefficients (with 95% confidence bounds):
       a =       29.95  (21.84, 38.05)
       b =       16.98  (16.35, 17.6)
       c =      0.2715  (0.1592, 0.3839)
       d =       5.811  (-19.45, 31.07)

Goodness of fit:
  SSE: 27.86
  R-square: 0.9618
  Adjusted R-square: 0.9587
  RMSE: 0.8796

## num2_p
Coefficients (with 95% confidence bounds):
       a =       5.729  (5.457, 6)
       b =       5.474  (5.315, 5.633)
       c =     0.03539  (-0.01907, 0.08984)
       d =       22.27  (20.94, 23.6)

Goodness of fit:
  SSE: 2.104
  R-square: 0.9901
  Adjusted R-square: 0.9893
  RMSE: 0.2353

## num2_n
Coefficients (with 95% confidence bounds):
       a =       2.949  (-1.2, 7.098)
       b =       4.469  (4.171, 4.767)
       c =      0.1965  (0.0783, 0.3148)
       d =       27.48  (14.65, 40.3)

Goodness of fit:
  SSE: 7.29
  R-square: 0.9644
  Adjusted R-square: 0.9616
  RMSE: 0.438

## num3_p
Coefficients (with 95% confidence bounds):
       a =      0.5415  (0.4957, 0.5873)
       b =      0.6825  (0.561, 0.804)
       c =    0.004906  (-1.308e-05, 0.009824)
       d =       3.773  (3.51, 4.036)

Goodness of fit:
  SSE: 0.1973
  R-square: 0.9646
  Adjusted R-square: 0.9618
  RMSE: 0.07205

## num3_n
Coefficients (with 95% confidence bounds):
       a =       1.183  (1.071, 1.294)
       b =       1.382  (0.9888, 1.775)
       c =   -0.003691  (-0.01162, 0.00424)
       d =       3.465  (2.805, 4.124)

Goodness of fit:
  SSE: 1.379
  R-square: 0.8238
  Adjusted R-square: 0.8099
  RMSE: 0.1905

## num4_p
Coefficients (with 95% confidence bounds):
       a =       2.254  (2.216, 2.291)
       b =       2.923  (2.899, 2.947)
       c =    -0.06572  (-0.07158, -0.05986)
       d =       3.208  (3.098, 3.319)

Goodness of fit:
  SSE: 0.131
  R-square: 0.987
  Adjusted R-square: 0.9865
  RMSE: 0.0439

## num4_n
Coefficients (with 95% confidence bounds):
       a =       3.111  (3.063, 3.159)
       b =       3.916  (3.872, 3.961)
       c =     0.03619  (0.03145, 0.04094)
       d =       2.984  (2.836, 3.132)

Goodness of fit:
  SSE: 0.3471
  R-square: 0.9659
  Adjusted R-square: 0.9644
  RMSE: 0.07145

## num5_p
Coefficients (with 95% confidence bounds):
       a =       5.472  (4.974, 5.97)
       b =       2.926  (2.883, 2.968)
       c =     -0.4841  (-0.5631, -0.4051)
       d =     -0.9974  (-1.894, -0.1006)

Goodness of fit:
  SSE: 0.387
  R-square: 0.9689
  Adjusted R-square: 0.9675
  RMSE: 0.07544


## num5_n
Coefficients (with 95% confidence bounds):
       a =       2.635  (2.602, 2.669)
       b =       2.894  (2.829, 2.959)
       c =    -0.01039  (-0.0149, -0.00588)
       d =       2.846  (2.737, 2.956)

Goodness of fit:
  SSE: 0.2751
  R-square: 0.9803
  Adjusted R-square: 0.9794
  RMSE: 0.0636

## num6_p
Coefficients (with 95% confidence bounds):
       a =        1.97  (1.935, 2.004)
       b =       2.431  (2.383, 2.479)
       c =    -0.01702  (-0.02089, -0.01314)
       d =       3.846  (3.735, 3.958)

Goodness of fit:
  SSE: 0.251
  R-square: 0.9893
  Adjusted R-square: 0.9888
  RMSE: 0.06076

## num6_n
Coefficients (with 95% confidence bounds):
       a =        1.86  (1.823, 1.898)
       b =       2.429  (2.379, 2.479)
       c =     0.01814  (0.01458, 0.0217)
       d =       4.009  (3.889, 4.129)

Goodness of fit:
  SSE: 0.2862
  R-square: 0.9883
  Adjusted R-square: 0.9878
  RMSE: 0.06487
