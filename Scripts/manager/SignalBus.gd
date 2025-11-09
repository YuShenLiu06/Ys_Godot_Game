extends Node

#专门用来存储信号    

@export var Is_choose_time : bool = false #使用信号而不是全局变量
# @export var tot_Choose_functon : int = 3 #总方法数量
@export var Is_paused : bool = false #游戏暂停状态
@export var bullet_model : int = 0 #弹药模式

enum bullet_models {normal_bullet,tracking_bullet}

signal Get_bullet_damage(damage: int) #更行弹药伤害信号
signal Choose_time(Is_Choose_time: bool) # 选卡时停信号
signal Pause_game(is_paused: bool) # 游戏暂停信号


#下面全部是selection各种实现用信号

signal Close_Choose_time

#sel系列实现
signal Sel_Bullet_damage(cof : float) #伤害
signal Sel_Bullet_fire_timer(cof : float) #开火时
signal Sel_Exp_obtain(cof : float) #经验获取

#tracking_bullet增强信号
signal Sel_Tracking_Bullet_Turn_Speed(cof : float) #追踪子弹转向速度
signal Sel_Tracking_Bullet_Max_Lifetime(increase : float) #追踪子弹最大生存时间
