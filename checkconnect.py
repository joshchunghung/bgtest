import paho.mqtt.client as mqtt
import yaml
import datetime
import json
import subprocess
import psutil


def runcmd(cmd, verbose=False, *args, **kwargs):
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        shell=True
    )
    std_out, std_err = process.communicate()
    return std_out.strip()


with open("/home/pi/MQTT/config.yml", "r") as f:
    param = yaml.load(f.read(), Loader=yaml.Loader)


def Run(cmd):
    res = runcmd(cmd)
    client.publish(f"return/{param['BU']}/{param['STA']}", f"{res}")


def getYML(data):
    with open("/home/pi/MQTT/getYML.py", "wb") as f:
        f.write(data)
    runcmd('sudo reboot')


def updateCheck(data):
    with open("/home/pi/MQTT/checkconnect.py", "wb") as f:
        f.write(data)
    runcmd('sudo reboot')


def writeCode(data):
    with open("/home/pi/MQTT/getData.py", "wb") as f:
        f.write(data)


def PiDetail():
    """
    return Pi's info 
    """
    try:
        time_ = datetime.datetime.now().strftime(param["ISOTIMEFORMAT"])
        temp = runcmd('cat /sys/class/thermal/thermal_zone*/temp')
        temp = f"{float(temp)/1000:.1f}"
        Wifi = runcmd(
            f"iwconfig wlan0 | grep Quality | awk '{{print $2}}' | awk  -F'=' '{{print $2}}'")
        up, down = Wifi.split("/")
        Wifi = f"{int(up)/int(down)*100:.1f}"
        SDused = runcmd(
            f"df -h | grep '/dev/mmcblk0p2' |  awk '{{print $5}}' | awk  -F'%' '{{print $1}}'")
        CPU = psutil.cpu_percent()
        MEM = psutil.virtual_memory().percent
        payload = f'Time={time_},SDused={SDused},temp={temp},Wifi={Wifi},CPU={CPU},Memory={MEM}'
        client.publish(
            f"{param['BU']}/{param['CONNECT']}/{param['STA']}", json.dumps(payload))
    except:
        pass


def on_connect(client, userdata, flags, rc):
    print(f"on_connect {param['BU']}/{param['STA']}", rc)
    client.subscribe([(f"{param['BU']}/{param['STA']}/+", 1), ('ALL/PI/+', 1)])



def on_message(client, userdata, msg):
    _, _, info = msg.topic.upper().split("/")
    MSG = msg.payload.decode('utf-8')
    print(info, MSG)
    if info == 'GETYML':
        getYML(msg.payload)
    elif info == 'UPDATECHECK':
        updateCheck(msg.payload)
    elif info == 'SHUTDOWN':
        runcmd('sudo shutdown now')
    elif info == 'REBOOT':
        runcmd('sudo reboot')
    elif info == 'CMD':
        Run(MSG)
    elif 'import' in MSG:
        writeCode(msg.payload)
    elif MSG == '0':
        PiDetail()


# 建立 MQTT Client 物件
client = mqtt.Client()

# 設定建立連線回呼函數
client.on_connect = on_connect

# 設定接收訊息回呼函數
client.on_message = on_message

# 連線至 MQTT 伺服器（伺服器位址,連接埠）
client.connect(param['MQTT_IP'], 1883, 60)

# 進入無窮處理迴圈
client.loop_forever()
