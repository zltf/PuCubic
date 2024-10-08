function require(mod)
    local code = arduino.read_file("/" .. mod .. ".lua")
    local fn = load(code)
    assert(fn)
    local ret = fn()
    package.loaded[mod] = ret
    return ret
end

local hi_score = 0

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

    local hi_score_str = arduino.read_file("/hi_score.txt")
    if #hi_score_str > 0 then
        hi_score = tonumber(hi_score_str) or 0
    end
    -- arduino.tft_string("hello", 50, 50, 2)

    -- local code, resp = arduino.web_req_post("http://47.116.21.61:7000/post_endpoint", "{\"hello\":999}")
    -- arduino.log_i(tostring(code))
    -- arduino.log_i(resp)
end

local Fly = require "fly"
local GameOver = require "game_over"
local Gift = {}
Gift[1] = require "gift1"
Gift[2] = require "gift2"
Gift[3] = require "gift3"
Gift[4] = require "gift4"
Gift[5] = require "gift5"
Gift[6] = require "gift6"
local pos = 0

local status = 1

local SPEED = {
    [1] = 1,
    [2] = 2,
    [3] = 2,
    [4] = 3,
    [5] = 4,
    [6] = 5,
    [7] = 4,
}

local DELAY = {
    [1] = 10,
    [2] = 15,
    [3] = 10,
    [4] = 10,
    [5] = 10,
    [6] = 10,
    [7] = 5,
}

local LEVELUP = {
    [1] = 10,
    [2] = 30,
    [3] = 60,
    [4] = 100,
    [5] = 150,
    [6] = 200,
}

local cur_gift = {}
local good_pos = 0
local cur_gift_x = 241
local level = 1
local score = 0

local fly_x = 20
local fly_w = 60
local fly_h = 31
local gift_w = 40
local gift_h = 50

local last_ay = 0

local function fly_fill()
    if pos == 1 then
        arduino.tft_fill(fly_x, 44, fly_w, fly_h, 0)
    elseif pos == 2 then
        arduino.tft_fill(fly_x, 94, fly_w, fly_h, 0)
    elseif pos == 3 then
        arduino.tft_fill(fly_x, 144, fly_w, fly_h, 0)
    end
end

local function gen_gift()
    local p = math.random(1, 3)
    while p == good_pos do
        p = math.random(1, 3)
    end
    good_pos = p
    local have
    for i = 1, 3 do
        if i == good_pos then
            cur_gift[i] = math.random(4, 6)
        else
            local g = math.random(1, 3)
            while g == have do
                g = math.random(1, 3)
            end
            cur_gift[i] = g
            have = g
        end
    end
    cur_gift_x = 241
end

local function get_circle_y(ay)
    return math.ceil(157 - (10 / 3 * -ay))
end

----------------------------------

local WuKong11 = require "wukong11"
local WuKong12 = require "wukong12"
local WuKong13 = require "wukong13"
local WuKong14 = require "wukong14"
local WuKong15 = require "wukong15"
local WuKong16 = require "wukong16"
local WuKong17 = require "wukong17"
local WuKong18 = require "wukong18"

local function main()
    arduino.tft_img(0, 0, 240, 30, WuKong11)
    arduino.tft_img(0, 30, 240, 30, WuKong12)
    arduino.tft_img(0, 60, 240, 30, WuKong13)
    arduino.tft_img(0, 90, 240, 30, WuKong14)
    arduino.tft_img(0, 120, 240, 30, WuKong15)
    arduino.tft_img(0, 150, 240, 30, WuKong16)
    arduino.tft_img(0, 180, 240, 30, WuKong17)
    arduino.tft_img(0, 210, 240, 30, WuKong18)
end

function loop()
    arduino.web_loop()

    local ax, ay, az = arduino.get_mpu_info()
    -- arduino.log_i(string.format("ms:%d ,ax:%f, ay:%f, az:%f", arduino.millis(), ax, ay, az))

    if status == 1 then
        main()

        if ay < -15 then
            status = 2
            arduino.tft_fill(0, 0, 240, 240, 0)
        end
        return
    end

    arduino.tft_draw_circle(5, get_circle_y(last_ay), 5, 0)
    arduino.tft_draw_circle(5, get_circle_y(ay), 5, 0xFFFF)
    last_ay = ay
    arduino.tft_draw_circle(5, get_circle_y(-10), 5, 0xFFE0)
    arduino.tft_draw_circle(5, get_circle_y(-20), 5, 0xFFE0)

    if good_pos == 0 then
        gen_gift()
    end

    if ay >= -10 and pos ~= 3 then
        arduino.tft_img(fly_x, 144, fly_w, fly_h, Fly)
        fly_fill()
        pos = 3
    elseif ay < -10 and ay >= -20 and pos ~= 2 then
        arduino.tft_img(fly_x, 94, fly_w, fly_h, Fly)
        fly_fill()
        pos = 2
    elseif ay < -20 and pos ~= 1 then
        arduino.tft_img(fly_x, 44, fly_w, fly_h, Fly)
        fly_fill()
        pos = 1
    end

    if cur_gift_x > fly_w + fly_x then
        for i, gift_id in ipairs(cur_gift) do
            local y = 28 + (i - 1) * 50
            arduino.tft_img(cur_gift_x, y, gift_w, gift_h, Gift[gift_id])
            arduino.tft_fill(cur_gift_x + gift_w, y, SPEED[level], gift_h, 0)
        end
        cur_gift_x = cur_gift_x - SPEED[level]
    else
        for i = 1, 3 do
            local y = 28 + (i - 1) * 50
            arduino.tft_fill(cur_gift_x + SPEED[level], y, gift_w, gift_h, 0)
        end
        if pos == good_pos then
            score = score + 10
            if LEVELUP[level] and score >= LEVELUP[level] then
                level = level + 1
            end
        else
            if score > hi_score then
                hi_score = score
                arduino.write_file("/hi_score.txt", tostring(hi_score))
            end
            arduino.tft_fill(0, 0, 240, 240, 0)
            arduino.tft_string(string.format("Game Over!"), 90, 40, 2)
            arduino.tft_img(70, 60, 100, 100, GameOver)
            arduino.tft_string(string.format("score: %d", score), 90, 160, 2)
            if score == hi_score then
                arduino.tft_string(string.format("Hi-Score"), 90, 180, 2)
            end
            arduino.delay(4000)
            arduino.tft_fill(0, 0, 240, 240, 0)
            status = 1
            level = 1
            score = 0
            good_pos = 0
            pos = 0
            return
        end
        gen_gift()
    end
    arduino.tft_string(string.format("Hi-Score: %d", hi_score), 10, 20, 2)
    arduino.tft_string(string.format("level: %d    score: %d", level, score), 10, 200, 2)
    arduino.delay(DELAY[level])
end