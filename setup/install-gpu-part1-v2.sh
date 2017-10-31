# This script is designed to work with ubuntu 16.04 LTS

# ensure system is updated and has basic build tools
sudo apt-get update
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes install tmux build-essential gcc g++ make binutils unzip
sudo apt-get --assume-yes install software-properties-common

# download and install GPU drivers
wget "https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb"

sudo dpkg -i cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda
sudo apt-get --assume-yes upgrade
sudo apt-get --assume-yes autoremove
sudo modprobe nvidia
nvidia-smi

# install Anaconda for current user
wget "https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh"
bash "Anaconda3-5.0.1-Linux-x86_64.sh" -b

echo "export PATH=\"$HOME/anaconda3/bin:\$PATH\"" >> ~/.bashrc
export PATH="$HOME/anaconda3/bin:$PATH"
conda install -y bcolz
conda upgrade -y --all

# install cudnn libraries
wget "http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64/libcudnn7_7.0.3.11-1+cuda9.0_amd64.deb"
sudo dpkg -i libcudnn7_7.0.3.11-1+cuda9.0_amd64.deb

# install tensorflow
conda install tensorflow

# install and configure keras
pip install git+git://github.com/fchollet/keras.git
mkdir ~/.keras
echo '{
    "image_dim_ordering": "tf",
    "epsilon": 1e-07,
    "floatx": "float32",
    "backend": "tensorflow"
}' > ~/.keras/keras.json

# Install python dependencies for fastai
conda install opencv tqdm
pip install isoweek pandas_summary

# install pytorch
export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" # [anaconda root directory]
conda install numpy pyyaml mkl setuptools cmake cffi
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch && python setup.py install && cd ..

git clone --recursive https://github.com/pytorch/vision.git
cd vision && python setup.py install && cd ..

# configure jupyter
jupyter notebook --generate-config

# Leaving the next line uncommented will prompt you to provide a password to
# use with your jupyter notebok.
jupass=`python -c "from notebook.auth import passwd; print(passwd())"`
# To hardcode the password to 'jupyter' comment line above and uncomment the line below.
#jupass=sha1:85ff16c0f1a9:c296112bf7b82121f5ec73ef4c1b9305b9e538af

echo "c.NotebookApp.password = u'"$jupass"'" >> $HOME/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py

# create ssl cert for jupyter notebook
openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout $HOME/mykey.key -out $HOME/mycert.pem -subj "/C=IE"
# save notebook startup command
echo jupyter notebook --certfile=$HOME/mycert.pem --keyfile $HOME/mykey.key > $HOME/start-jupyter-notebook
chmod +x $HOME/start-jupyter-notebook

# Uncomment the 3 lines below ONLY if you are following the guide for setting
# up persistent AWS spot instances as outlined here:
#    https://medium.com/@radekosmulski/automated-aws-spot-instance-provisioning-with-persisting-of-data-ce2b32bdc102
#mkdir workspace
#echo sudo mount /dev/xvdf1 $HOME/workspace > $HOME/mount-workspace
#chmod +x $HOME/mount-workspace

# Download the dogs vs cats dataset and extract it into the appropriate folder
mkdir data
wget http://files.fast.ai/data/dogscats.zip
unzip dogscats.zip -d data/

# Delete installation files
rm libcudnn7_7.0.3.11-1+cuda9.0_amd64.deb dogscats.zip install-gpu-part1-v2.sh cuda-repo-ubuntu1604-9-0-local_9.0.176-1_amd64-deb Anaconda3-5.0.1-Linux-x86_64.sh pytorch vision

# clone a forked fast.ai course repo
cd ~
git clone https://github.com/radekosmulski/fastai.git

# Start new shell for updates to PATH to take effect
exec bash
