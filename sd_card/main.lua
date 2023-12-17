function setup()
    arduino.log_i("setup")
    arduino.log_i(string.format("content: %s", arduino.read_file("/init.lua")))
    arduino.write_file("/main.lua", 'print("hello")')
    arduino.delete_file("/init.lua")

    local ap_ip = arduino.open_ap("小女警的家", "pupupupu")
    arduino.log_i(string.format("ap_ip %s", ap_ip))
    local wifi_ip = arduino.conn_wifi("3/218-F", "jh589999")
    arduino.log_i(string.format("wifi_ip %s", wifi_ip))
end

function loop()
    --arduino.log_i("loop")
    local ax, ay, az = arduino.get_mpu_info()
    --arduino.log_i(string.format("ms:%d ,ax:%f, ay:%f, az:%f", arduino.millis(), ax, ay, az))
    arduino.delay(1000)
end