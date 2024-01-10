import requests
import yaml
import subprocess
import time
import os
"""
for raspberry Pi to get the yml Data when reboot 
# bug:k1 k3站有連通 會打架 先把K1的網路線拔掉 2023/12/29
"""


def error2DB(timestamp, status):
    url = 'http://evsbglab.deltaos.corp/api/'
    query = """
    mutation MyMutation($status: String , $timestamp: Float) {
    addErrorlog(Input: {timestamp: $timestamp, status: $status}) {
        success
        text
    }
    }
    """
    variables = {
        "timestamp": timestamp,
        "status": status
    }
    r = requests.post(url, json={'query': query, "variables": variables})


def runcmd(cmd):
    process = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        shell=True
    )
    std_out, std_err = process.communicate()
    return std_out.strip()


def main(ChamberMac, PiMac):
    url = 'http://evsbglab.deltaos.corp/api/'
    query = """query MyQuery($ChamberMac: [String!], $PiMac: [String!]) {
    getYML(Input: {ChamberMac: $ChamberMac, PiMac: $PiMac}) {
      content
      success
    }
    }
    """
    variables = {
        "ChamberMac": ChamberMac,
        "PiMac": PiMac
    }
    r = requests.post(url, json={'query': query, "variables": variables})
    print(r.json())
    content = r.json().get('data').get('getYML')
    data = content['content'][0]
    success = content['success']
    yaml_string = yaml.dump(data, default_flow_style=False)
    with open("/home/pi/MQTT/config.yml", "w") as f:
        f.write(yaml_string)
    return success


if __name__ == "__main__":
    cmd = f"""ifconfig wlan0 | grep "ether"  | awk '{{print $2}}'"""
    PiMac = runcmd(cmd)
    for i in range(6):
        try:
            cmd = f"""sudo nmap -sn 192.168.1.0/24 | grep 'MAC Address' | awk '{{print $3}}'"""
            a = runcmd(cmd)
            ChamberMac = a.split('\n')
            success = main(ChamberMac, PiMac)
            if success:
                break
            else:
                time.sleep(10)
        except:
            time.sleep(10)
    if not os.path.isfile('/home/pi/MQTT/config.yml'):
        ti_ = time.time()
        error2DB(ti_, f'Pi {PiMac} error')
