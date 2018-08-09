## install pytorch

# update source list
cp ubuntu_16.04_sources_cn.list /etc/apt/sources.list
cp dot.vimrc /root/.vimrc


# Install dependencies
apt-get update -y
apt-get install software-properties-common -y

# All packages (Will install much faster)
apt-get install --no-install-recommends -y git cmake python-pip build-essential 

# update pip mirror
mkdir -p /root/.config/pip
cp pip.conf /root/.config/pip/pip.conf

# for python 3
apt-get install python3-pip

# pytorch (Python 3.5, CUDA 9.0)
pip3 install http://download.pytorch.org/whl/cu90/torch-0.4.0-cp35-cp35m-linux_x86_64.whl 
pip3 install torchvision


