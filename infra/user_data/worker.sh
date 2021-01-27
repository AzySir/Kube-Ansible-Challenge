#!/bin/bash
ping -c 10 ${masteraddress}
createuser deploy
systemctl restart networking
