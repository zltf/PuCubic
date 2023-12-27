function require(mod)
    local code = arduino.read_file("/" .. mod .. ".lua")
    local fn = load(code)
    local ret = fn()
    package.loaded[mod] = ret
    return ret
end

function setup()
    arduino.log_i("setup")

    local ap_ip = arduino.open_ap("小女警的家", "pupupupu")
    arduino.log_i(string.format("ap_ip %s", ap_ip))

    local html = [[<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>小女警之家</title>
</head>
<body>
    <h1>小女警之家</h1>
    <input type="text" id="path" placeholder="输入文件路径">
    <br>
    <textarea id="textbox" rows="40" cols="100"></textarea>
    <br>
    <input type="button" value="文件列表" onclick="listFile()">
    <input type="button" value="读文件" onclick="readFile()">
    <input type="button" value="写文件" onclick="writeFile()">
    <input type="button" value="删除文件" onclick="deleteFile()">
    <input type="button" value="重启" onclick="restart()">
    <br>
    <input type="text" id="ssid" placeholder="wifi名称">
    <input type="text" id="pwd" placeholder="密码">
    <input type="button" value="连接wifi" onclick="wifi()">
    <br>
    <input type="text" id="yr" placeholder="年">
    <input type="text" id="mt" placeholder="月">
    <input type="text" id="dy" placeholder="日">
    <input type="text" id="hr" placeholder="时">
    <input type="text" id="mn" placeholder="分">
    <input type="text" id="sc" placeholder="秒">
    <input type="button" value="设置时间" onclick="setTime()">
    <br>
    <input type="text" id="time" placeholder="时间">
    <input type="button" value="获取时间" onclick="getTime()">
    <script>
        function listFile() {
            var path = document.getElementById("path").value;
            var url = "http://192.168.4.2/list_file";
            fetch(url, {
                method: "post",
                body: "path=" + encodeURIComponent(path),
                headers: {
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
                }
            })
            .then(response => response.text())
            .then(data => {
                document.getElementById("textbox").value = data;
            })
            .catch(error => {
                alert("读取失败：" + error);
            });
        }
        function readFile() {
            var path = document.getElementById("path").value;
            var url = "http://192.168.4.2/read_file";
            fetch(url, {
                method: "post",
                body: "path=" + encodeURIComponent(path),
                headers: {
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
                }
            })
            .then(response => response.text())
            .then(data => {
                document.getElementById("textbox").value = data;
            })
            .catch(error => {
                alert("读取失败：" + error);
            });
        }
        function writeFile() {
            var path = document.getElementById("path").value;
            var text = document.getElementById("textbox").value;
            var url = "http://192.168.4.2/write_file";
            fetch(url, {
                method: "post",
                body: "path=" + encodeURIComponent(path) + "&text=" + encodeURIComponent(text),
                headers: {
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
                }
            })
            .then(response => response.text())
            .then(data => {
                alert(data);
            })
            .catch(error => {
                alert("上传失败：" + error);
            });
        }
        function deleteFile() {
            var path = document.getElementById("path").value;
            var url = "http://192.168.4.2/delete_file";
            fetch(url, {
                method: "post",
                body: "path=" + encodeURIComponent(path),
                headers: {
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
                }
            })
            .then(response => response.text())
            .then(data => {
                alert(data);
            })
            .catch(error => {
                alert("读取失败：" + error);
            });
        }
        function restart() {
            var url = "http://192.168.4.2/restart";
            fetch(url, { method: "post" })
            .then(response => response.text())
            .then(data => {
                alert(data);
            })
            .catch(error => {
                alert("重启失败：" + error);
            });
        }
        function wifi() {
            var ssid = document.getElementById("ssid").value;
            var pwd = document.getElementById("pwd").value;
            var url = "http://192.168.4.2/wifi";
            fetch(url, {
                method: "post",
                body: "ssid=" + encodeURIComponent(ssid) + "&pwd=" + encodeURIComponent(pwd),
                headers: {
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
                }
            })
            .then(response => response.text())
            .then(data => {
                alert(data);
            })
            .catch(error => {
                alert("读取失败：" + error);
            });
        }
        function setTime() {
            var yr = document.getElementById("yr").value;
            var mt = document.getElementById("mt").value;
            var dy = document.getElementById("dy").value;
            var hr = document.getElementById("hr").value;
            var mn = document.getElementById("mn").value;
            var sc = document.getElementById("sc").value;
            var url = "http://192.168.4.2/set_time";
            fetch(url, {
                method: "post",
                body: "yr=" + encodeURIComponent(yr)
                        + "&mt=" + encodeURIComponent(mt)
                        + "&dy=" + encodeURIComponent(dy)
                        + "&hr=" + encodeURIComponent(hr)
                        + "&mn=" + encodeURIComponent(mn)
                        + "&sc=" + encodeURIComponent(sc),
                headers: {
                    "content-type": "application/x-www-form-urlencoded; charset=UTF-8"
                }
            })
            .then(response => response.text())
            .then(data => {
                alert(data);
            })
            .catch(error => {
                alert("读取失败：" + error);
            });
        }
        function getTime() {
            var url = "http://192.168.4.2/get_time";
            fetch(url, { method: "post" })
            .then(response => response.text())
            .then(data => {
                document.getElementById("time").value = data;
            })
            .catch(error => {
                alert("读取失败：" + error);
            });
        }
    </script>
</body>
</html>]]

    arduino.web_get("/", [[
        arduino.web_send(200, "text/html", [==[]] .. html .. [[]==])
    ]])

    arduino.web_post("/list_file", [[
        local path = arduino.web_arg("path")
        local list = arduino.list_file(path)
        arduino.web_send(200, "text/html", list)
    ]])

    arduino.web_post("/read_file", [[
        local path = arduino.web_arg("path")
        local content = arduino.read_file(path)
        arduino.web_send(200, "text/html", content)
    ]])

    arduino.web_post("/write_file", [[
        local path = arduino.web_arg("path")
        local text = arduino.web_arg("text")
        arduino.write_file(path, text)
        arduino.web_send(200, "text/html", "写入成功")
    ]])

    arduino.web_post("/delete_file", [[
        local path = arduino.web_arg("path")
        arduino.delete_file(path)
        arduino.web_send(200, "text/html", "删除成功")
    ]])

    arduino.web_post("/restart", [[
        arduino.web_send(200, "text/html", "3秒后重启")
        arduino.delay(3000)
        arduino.restart()
    ]])

    arduino.web_post("/wifi", [[
        local ssid = arduino.web_arg("ssid")
        local pwd = arduino.web_arg("pwd")
        local wifi_ip = arduino.conn_wifi(ssid, pwd)
        arduino.web_send(200, "text/html", "连接成功 ip:" .. wifi_ip)
    ]])

    arduino.web_post("/set_time", [[
        local yr = arduino.web_arg("yr")
        local mt = arduino.web_arg("mt")
        local dy = arduino.web_arg("dy")
        local hr = arduino.web_arg("hr")
        local mn = arduino.web_arg("mn")
        local sc = arduino.web_arg("sc")
        arduino.time_set(yr, mt, dy, hr, mn, sc)
        arduino.web_send(200, "text/html", "设置成功")
    ]])

    arduino.web_post("/get_time", [[
        local yr, mt, dy, hr, mn, sc = arduino.time_get()
        arduino.web_send(200, "text/html", string.format("%d-%d-%d %d:%d:%d", yr, mt, dy, hr, mn, sc))
    ]])

    arduino.time_set(2023, 12, 25, 0, 0, 0)
    arduino.web_begin()
    -- arduino.tft_string("hello", 50, 50, 2)

    -- local code, resp = arduino.web_req_post("http://47.116.21.61:7000/post_endpoint", "{\"hello\":999}")
    -- arduino.log_i(tostring(code))
    -- arduino.log_i(resp)
end

local flag = false

local Bee1 = require "bee1"
local Bee2 = require "bee2"

function loop()
    arduino.web_loop()

    -- local ax, ay, az = arduino.get_mpu_info()
    -- arduino.log_i(string.format("ms:%d ,ax:%f, ay:%f, az:%f", arduino.millis(), ax, ay, az))

    if flag then
        arduino.tft_img(60, 80, 120, 95, Bee1)
        flag = false
    else
        arduino.tft_img(60, 80, 120, 95, Bee2)
        flag = true
    end

    -- local yr, mt, dy, hr, mn, sc = arduino.time_get()
    -- arduino.tft_fill(50, 50, 200, 50, 0xFFE0)
    -- arduino.tft_string(string.format("%d-%d-%d %d:%d:%d", yr, mt, dy, hr, mn, sc), 50, 50, 2)

    arduino.delay(50)
end