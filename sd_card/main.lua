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
            var url = "http://192.168.4.2/list_file?path=" + encodeURIComponent(path);
            fetch(url, { method: "GET" })
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
            var url = "http://192.168.4.2/read_file?path=" + encodeURIComponent(path);
            fetch(url, { method: "GET" })
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
            var url = "http://192.168.4.2/write_file?path=" + encodeURIComponent(path) + "&text=" + encodeURIComponent(text);
            fetch(url, { method: "GET" })
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
            var url = "http://192.168.4.2/delete_file?path=" + encodeURIComponent(path);
            fetch(url, { method: "GET" })
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
            fetch(url, { method: "GET" })
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
            var url = "http://192.168.4.2/wifi?ssid=" + encodeURIComponent(ssid) + "&pwd=" + encodeURIComponent(pwd);
            fetch(url, { method: "GET" })
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
            var url = "http://192.168.4.2/set_time?yr=" + encodeURIComponent(yr)
                    + "&mt=" + encodeURIComponent(mt)
                    + "&dy=" + encodeURIComponent(dy)
                    + "&hr=" + encodeURIComponent(hr)
                    + "&mn=" + encodeURIComponent(mn)
                    + "&sc=" + encodeURIComponent(sc);
            fetch(url, { method: "GET" })
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
            fetch(url, { method: "GET" })
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

    arduino.web_on("/", [[
        arduino.web_send(200, "text/html", [==[]] .. html .. [[]==])
    ]])

    arduino.web_on("/list_file", [[
        local path = arduino.web_arg("path")
        local list = arduino.list_file(path)
        arduino.web_send(200, "text/html", list)
    ]])

    arduino.web_on("/read_file", [[
        local path = arduino.web_arg("path")
        local content = arduino.read_file(path)
        arduino.web_send(200, "text/html", content)
    ]])

    arduino.web_on("/write_file", [[
        local path = arduino.web_arg("path")
        local text = arduino.web_arg("text")
        arduino.write_file(path, text)
        arduino.web_send(200, "text/html", "写入成功")
    ]])

    arduino.web_on("/delete_file", [[
        local path = arduino.web_arg("path")
        arduino.delete_file(path)
        arduino.web_send(200, "text/html", "删除成功")
    ]])

    arduino.web_on("/restart", [[
        arduino.web_send(200, "text/html", "3秒后重启")
        arduino.delay(3000)
        arduino.restart()
    ]])

    arduino.web_on("/wifi", [[
        local ssid = arduino.web_arg("ssid")
        local pwd = arduino.web_arg("pwd")
        local wifi_ip = arduino.conn_wifi(ssid, pwd)
        arduino.web_send(200, "text/html", "连接成功 ip:" .. wifi_ip)
    ]])

    arduino.web_on("/set_time", [[
        local yr = arduino.web_arg("yr")
        local mt = arduino.web_arg("mt")
        local dy = arduino.web_arg("dy")
        local hr = arduino.web_arg("hr")
        local mn = arduino.web_arg("mn")
        local sc = arduino.web_arg("sc")
        arduino.time_set(yr, mt, dy, hr, mn, sc)
        arduino.web_send(200, "text/html", "设置成功")
    ]])

    arduino.web_on("/get_time", [[
        local yr, mt, dy, hr, mn, sc = arduino.time_get()
        arduino.web_send(200, "text/html", string.format("%d-%d-%d %d:%d:%d", yr, mt, dy, hr, mn, sc))
    ]])

    arduino.web_begin()

    local img = {}
    for i = 1, 100 do
        for j = 1, 100 do
            table.insert(img, i * 100)
        end
    end

    arduino.tft_img(100, 100, 100, 100, img)
    arduino.tft_string("hello", 50, 50, 2)

    -- local code, resp = arduino.web_post("http://47.116.21.61:7000/post_endpoint", "{\"hello\":999}")
    -- arduino.log_i(tostring(code))
    -- arduino.log_i(resp)
end

local off = 0

function loop()
    arduino.web_loop()
    local ax, ay, az = arduino.get_mpu_info()
    --arduino.log_i(string.format("ms:%d ,ax:%f, ay:%f, az:%f", arduino.millis(), ax, ay, az))
    local img = {}
    for i = 1, 100 do
        for j = 1, 100 do
            table.insert(img, i * 100)
        end
    end

    off = off + 1

    local yr, mt, dy, hr, mn, sc = arduino.time_get()
    arduino.tft_fill(50, 50, 200, 100, 0)
    arduino.tft_string(string.format("%d-%d-%d %d:%d:%d", yr, mt, dy, hr, mn, sc), 50, 50, 2)

    arduino.tft_fill(100 + off - 1, 100 + off - 1, 100, 100, 0)
    arduino.tft_img(100 + off, 100 + off, 100, 100, img)
end