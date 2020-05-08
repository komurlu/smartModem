# smartModem
This script checks if one of either your TV Set-top-box or HTPC (home theater PC) is turned on.

If one of them is turned on, script runs an action - turns on Smart Power Plug to control external speakers(or home thater)

This script should run on your home router/modem. 

It depends on https://github.com/komurlu/c-miio to control smart plug (Xiaomi Wifi Plug - chuangmi )

#### Run

Enter the following command to start the script. It continues to run even if you exit from ssh session, until you will manually `kill` it.   

`setsid ./monitor.sh < /dev/null >/dev/null 2>&1 &`
