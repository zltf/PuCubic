#ifndef IMU_H
#define IMU_H

#include <I2Cdev.h>
#include <MPU6050.h>
#include <list>

// MUP6050
#define IMU_I2C_SDA 41
#define IMU_I2C_SCL 42

// 方向类型
enum MPU_DIR_TYPE
{
    NORMAL_DIR_TYPE = 0,
    X_DIR_TYPE = 0x01,
    Y_DIR_TYPE = 0x02,
    Z_DIR_TYPE = 0x04,
    XY_DIR_TYPE = 0x08
};

struct SysMpuConfig
{
    int16_t x_gyro_offset;
    int16_t y_gyro_offset;
    int16_t z_gyro_offset;

    int16_t x_accel_offset;
    int16_t y_accel_offset;
    int16_t z_accel_offset;
};

struct ImuAction
{
    int16_t v_ax; // v表示虚拟参数（用于调整6050的初始方位）
    int16_t v_ay;
    int16_t v_az;
    int16_t v_gx;
    int16_t v_gy;
    int16_t v_gz;
};

class IMU
{
private:
    MPU6050 mpu;
    int flag;
    long last_update_time;
    uint8_t order; // 表示方位，x与y是否对换

public:
    ImuAction action_info;
    // 用来储存历史动作
    // std::list<ACTIVE_TYPE> act_info_history;

public:
    IMU();
    void init(uint8_t order, uint8_t auto_calibration,
              SysMpuConfig *mpu_cfg);
    void setOrder(uint8_t order); // 设置方向
    void getVirtureMotion6(ImuAction *action_info);
};

#endif
