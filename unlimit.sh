#!/bin/bash

# 1. 设置系统最大文件描述符数
echo "Setting maximum number of file descriptors..."
echo "1000000" > /proc/sys/fs/file-max

# 2. 设置硬限制和软限制的打开文件数，取消核心文件大小限制
echo "Setting ulimit parameters..."
ulimit -SHn 1000000
ulimit -c unlimited

# 3. 修改/etc/security/limits.conf文件
echo "Updating /etc/security/limits.conf..."
cat > /etc/security/limits.conf <<EOF
root     soft   nofile    1000000
root     hard   nofile    1000000
root     soft   nproc     1000000
root     hard   nproc     1000000
root     soft   core      1000000
root     hard   core      1000000
root     hard   memlock   unlimited
root     soft   memlock   unlimited
*        soft   nofile    1000000
*        hard   nofile    1000000
*        soft   nproc     1000000
*        hard   nproc     1000000
*        soft   core      1000000
*        hard   core      1000000
*        hard   memlock   unlimited
*        soft   memlock   unlimited
EOF

# 4. 修改/etc/profile文件
echo "Updating /etc/profile..."
if ! grep -q "ulimit -SHn 1000000" /etc/profile; then
    echo "ulimit -SHn 1000000" >> /etc/profile
fi

# 5. 修改/etc/pam.d/common-session文件
echo "Updating /etc/pam.d/common-session..."
if ! grep -q "session required pam_limits.so" /etc/pam.d/common-session; then
    echo "session required pam_limits.so" >> /etc/pam.d/common-session
fi

# 6. 修改/etc/systemd/system.conf文件
echo "Updating /etc/systemd/system.conf..."
sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
sed -i '/DefaultLimitCORE/d' /etc/systemd/system.conf
sed -i '/DefaultLimitNOFILE/d' /etc/systemd/system.conf
sed -i '/DefaultLimitNPROC/d' /etc/systemd/system.conf
cat >> /etc/systemd/system.conf <<EOF
[Manager]
DefaultTimeoutStopSec=30s
DefaultLimitCORE=infinity
DefaultLimitNOFILE=1000000
DefaultLimitNPROC=65535
EOF

# 7. 重新加载systemd配置
echo "Reloading systemd daemon..."
systemctl daemon-reload

echo "All settings updated. Please reboot your system for the changes to take effect."
