wget https://github.com/Archiconda/build-tools/releases/download/0.2.3/Archiconda3-0.2.3-Linux-aarch64.sh
#chmod +x Archiconda3-0.2.3-Linux-aarch64.sh
bash Archiconda3-0.2.3-Linux-aarch64.sh -b -p $HOME/archiconda
#echo ". /home/ec2-user/archiconda/etc/profile.d/conda.sh" >> ~/.bashrc
sudo ln -s /home/ec2-user/archiconda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
source /etc/profile.d/conda.sh

sudo yum install libcurl-devel.aarch64

conda env update -q --name base --file ml_logger.yml
make
