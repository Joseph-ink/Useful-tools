#!/bin/bash

checkurl() {
  local url=$1
  if [ -z "$url" ]; then
    echo -e "${Error} 链接为空，请检查网络或稍后再试" && exit 1
  fi
  status_code=$(curl --write-out %{http_code} --silent --output /dev/null $url)
  if [ $status_code -eq 200 ]; then
    echo -e "连接正常"
  else
    echo -e "${Error} 连接失败，请检查网络或稍后再试" && exit 1
  fi
}

remove_existing_kernels() {
  echo -e "删除系统上所有已有的内核"
  sudo apt-get purge $(dpkg --get-selections | grep linux-image | awk '{print $1}')
  sudo apt-get purge $(dpkg --get-selections | grep linux-headers | awk '{print $1}')
  sudo update-grub
}

get_cpu_instruction_set() {
  cpuinfo=$(lscpu)
  if echo "$cpuinfo" | grep -q "avx512"; then
    echo "x64v4"
  elif echo "$cpuinfo" | grep -q "avx2"; then
    echo "x64v3"
  elif echo "$cpuinfo" | grep -q "sse3"; then
    echo "x64v2"
  elif echo "$cpuinfo" | grep -q "sse2"; then
    echo "x64v1"
  else
    echo "Unsupported"
  fi
}

install_xanmod_kernel() {
  # 获取系统发行版信息
  if grep -Eqi "ubuntu" /etc/issue || grep -Eqi "debian" /etc/issue; then
    release="supported"
  else
    echo -e "${Error} 不支持此系统，仅支持Debian和Ubuntu !" && exit 1
  fi

  # 删除现有内核
  remove_existing_kernels

  # 获取CPU支持的指令集
  cpu_instruction_set=$(get_cpu_instruction_set)

  if [[ "$cpu_instruction_set" == "Unsupported" ]]; then
    echo -e "${Error} 不支持此CPU，无法找到合适的内核版本 !" && exit 1
  fi

  # 下载并安装Xanmod内核
  echo -e "开始安装Xanmod内核（指令集：${cpu_instruction_set}）"
  all_kernels=$(curl -s https://api.github.com/repos/xanmod/linux/releases | jq '.[] | select(.prerelease==false) | .tag_name' | tr -d '\"' | grep -v "rt")
  latest_kernel="0"
  
  for kernel in $all_kernels; do
    if [[ $(printf '%s\n' "$kernel" "$latest_kernel" | sort -V | head -n1) != "$latest_kernel" ]]; then
      latest_kernel=$kernel
    fi
done


  echo -e "获取到的最新内核版本为：${latest_kernel}"

  headers_deb_url=$(curl -s https://api.github.com/repos/xanmod/linux/releases/tags/$latest_kernel | grep "browser_download_url" | grep "amd64.deb" | grep "headers" | grep "${cpu_instruction_set}" | head -n 1 | cut -d\" -f4)
  kernel_deb_url=$(curl -s https://api.github.com/repos/xanmod/linux/releases/tags/$latest_kernel | grep "browser_download_url" | grep "amd64.deb" | grep "image" | grep "${cpu_instruction_set}" | head -n 1 | cut -d\" -f4)

  if [ -z "$headers_deb_url" ] || [ -z "$kernel_deb_url" ]; then
    echo -e "${Error} 未找到headers或内核下载链接，请检查网络或稍后再试" && exit 1
  fi

  echo -e "正在检查headers下载链接..."
  checkurl $headers_deb_url
  echo -e "正在检查内核下载链接..."
  checkurl $kernel_deb_url

  wget -N -O xanmod-headers.deb $headers_deb_url
  wget -N -O xanmod-kernel.deb $kernel_deb_url
  
  if [[ "${release}" == "supported" ]]; then
  sudo dpkg -i xanmod-headers.deb
  sudo dpkg -i xanmod-kernel.deb
  sudo apt-get install -f
  else
  echo -e "${Error} 不支持此系统，仅支持Debian和Ubuntu !" && exit 1
  fi
  
  current_kernel=$(uname -r)
  echo -e "当前系统内核版本为：${current_kernel}"
  
  if [[ "${current_kernel}" == "${latest_kernel}" ]]; then
  echo -e "Xanmod内核安装完成，请重启系统以启用新内核"
  else
  echo -e "${Error} 内核安装失败，请检查日志并尝试重新安装"
  fi
}

install_xanmod_kernel