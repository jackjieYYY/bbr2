#!/bin/bash
clear
echo
echo "#################################################################"
echo "# Google BBRv2 x86_64 Install"
echo "# System Required: CentOS 7 "
echo "#################################################################"
echo

system_check(){
	if [ -f /usr/bin/yum ]; then
		centos_install
	#elif [ -f /usr/bin/apt ]; then
		#debian_install
	else
		echo -e "你的系统不支持"
	fi
}

centos_install(){
	yum -y install git
	git clone https://github.com/xiya233/bbr2.git
	cd bbr2/centos
	yum -y localinstall *
	grub2-set-default 0
	echo "tcp_bbr" >> /etc/modules-load.d/tcp_bbr.conf
	echo "tcp_bbr2" >> /etc/modules-load.d/tcp_bbr2.conf
	echo "tcp_dctcp" >> /etc/modules-load.d/tcp_dctcp.conf
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control = bbr2" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_ecn = 1" >> /etc/sysctl.conf
	sysctl -p
	rm -rf ~/bbr2
	read -p "内核安装完成，重启生效，是否现在重启？[Y/N] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "正在重启"
		reboot
	fi
}

debian_install(){
	apt -y update
	apt -y install git
	git clone https://github.com/xiya233/bbr2.git
	cd bbr2/debian
	apt -y install *
	echo "tcp_bbr" >> /etc/modules
	echo "tcp_bbr2" >> /etc/modules
	echo "tcp_dctcp" >> /etc/modules
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/net.ipv4.tcp_ecn/d' /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control = bbr2" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_ecn = 1" >> /etc/sysctl.conf
	sysctl -p
	rm -rf ~/bbr2
	read -p "内核安装完成，重启生效，是否现在重启？[Y/N] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "正在重启"
		reboot
	fi
}

start(){
while :
do
while :
do
    echo "0) Exit script. | 退出腳本。 (0"
    if [[ "$environment_headers" != "true" ]] || [[ "$environment_image" != "true" ]]; then echo "1) Install the kernel for BBR2. | 安裝適用於BBR2的內核。 (1"; fi
    [[ "$environment_kernel" = "true" ]] && [[ "$environment_bbr2" != "true" ]] && echo "2) Enable BBR2. | 啟用BBR2。 (2"
    [[ "$environment_bbr2" = "true" ]] && echo "3) Disable BBR2. | 禁用BBR2。 (3"
    [[ "$environment_bbr2" = "true" ]] && [[ "$environment_ecn" != "true" ]] && echo "4) Enable ECN. | 啟用ECN。 (4"
    [[ "$environment_ecn" = "true" ]] && echo "5) Disable ECN. | 禁用ECN。 (5"
    [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_otherkernels" = "true" ]] && echo "6) Remove other kernels. | 卸載其餘內核。 (6"
    [[ "$environment_headers" = "true" ]] && [[ "$environment_image" = "true" ]] && [[ "$environment_kernel" != "true" ]] && echo "7) reboot. | 重新啟動。 (7"
    unset choose_an_option
    read -p "Choose an option. | 選擇一個選項。 (Input a number | 輸入一個數字) " choose_an_option

    if [[ "$choose_an_option" = "0" ]] || [[ "$choose_an_option" = "1" ]] || [[ "$choose_an_option" = "2" ]] || [[ "$choose_an_option" = "3" ]] || [[ "$choose_an_option" = "4" ]] || [[ "$choose_an_option" = "5" ]] || [[ "$choose_an_option" = "6" ]] || [[ "$choose_an_option" = "7" ]]; then
        do_option $choose_an_option
        break
    else
        continue
    fi
done

done
}



start_menu(){
	read -p "请输入数字(1/2/3)  1：安装BBRv2  2：开启ECN  3：我是咸鱼我退出:" num
	case "$num" in
		1)
		system_check
		;;
		2)
		echo 1 > /sys/module/tcp_bbr2/parameters/ecn_enable
		;;
		3)
		exit 1
		;;
	esac
}
start
start_menu
