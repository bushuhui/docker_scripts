
#
#
# References:
#   https://blog.csdn.net/steveyg/article/details/52400097
#   https://blog.csdn.net/SweetTool/article/details/70224459

# add chinese language support
apt-get install  language-pack-zh-han*

# reconfigure locales
dpkg-reconfigure locales

# copy ../data/fonts-linux.tar.gz to /usr/share/fonts/
# and then run 
#
#   sudo mkfontscale
#   sudo mkfontdir
#   sudo fc-cache


# add to system environment
echo "LC_ALL=zh_CN.UTF-8" >> /etc/environment
echo "LANG=zh_CN.UTF-8" >> /etc/environment

# or set in you ~/.bashrc
#export LC_ALL=zh_CN.UTF-8
#export LANG=zh_CN.UTF-8

