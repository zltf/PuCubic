function setup()
    arduino.log_i("setup")

    local ap_ip = arduino.open_ap("小女警的家", "pupupupu")
    arduino.log_i(string.format("ap_ip %s", ap_ip))
    local wifi_ip = arduino.conn_wifi("3/218-F", "jh589999")
    arduino.log_i(string.format("wifi_ip %s", wifi_ip))

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
    <textarea id="textbox" rows="4" cols="50"></textarea>
    <br>
    <input type="button" value="写文件" onclick="writeFile()">
    <input type="button" value="重启" onclick="restart()">
    <script>
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
    </script>
</body>
</html>]]

    arduino.web_on("/", [[
        arduino.web_send(200, "text/html", [==[]] .. html .. [[]==])
    ]])

    arduino.web_on("/write_file", [[
        local path = arduino.web_arg("path")
        local text = arduino.web_arg("text")
        arduino.write_file(path, text)
        arduino.web_send(200, "text/html", "写入成功")
    ]])

    arduino.web_on("/restart", [[
        arduino.web_send(200, "text/html", "3秒后重启")
        arduino.delay(3000)
        arduino.restart()
    ]])

    arduino.web_begin()

    local img = {}
    for i = 1, 100 do
        for j = 1, 100 do
            table.insert(img, i * 100)
        end
    end

    arduino.tft_img(100, 100, 100, 100, img)
end

local off = 0

function loop()
    arduino.log_i("loop1")
    arduino.web_loop()
    arduino.log_i("loop2")
    local ax, ay, az = arduino.get_mpu_info()
    arduino.log_i("loop3")
    --arduino.log_i(string.format("ms:%d ,ax:%f, ay:%f, az:%f", arduino.millis(), ax, ay, az))
    local img = {}
    for i = 1, 100 do
        for j = 1, 100 do
            table.insert(img, i * 100)
        end
    end
    arduino.log_i("loop4")

    off = off + 1

    arduino.tft_fill(100 + off - 1, 100 + off - 1, 100, 100, 0)
    arduino.tft_img(100 + off, 100 + off, 100, 100, img)
end