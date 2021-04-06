#SHELL=/usr/local/bin/bash
CONDA_ENV=causal-infogan
CONDA_PATH=$(shell which anaconda)

default: conda-create fix-matplotlib install-pytorch-linux

conda-create:
	conda env create -f environment.yml
conda-clone:
	conda env create --name $(ENV_NAME) --file environment.yml
conda-remove:
	conda env remove --name $(CONDA_ENV)

start-tensorboard:
	source activate $(CONDA_ENV) && tensorboard --logdir runs

fix-matplotlib:
	mkdir -p ~/.matplotlib
	echo "backend : TkAgg" > ~/.matplotlib/matplotlibrc

#VERSION=2b4748011b5881583567bb166801ca6625f2fdda
VERSION=940a0ab67bc933b0d6c24540a9e3100d213eec49  # close to master 0.4.0a
install-pytorch-osx:
# installation instruction see: https://github.com/pytorch/pytorch#install-optional-dependencies
	source activate $(CONDA_ENV) && export CMAKE_PREFIX_PATH='$(CONDA_PATH)' && \
    yes | conda install numpy pyyaml setuptools cmake cffi typing && \
    git clone --recursive https://github.com/pytorch/pytorch && \
    cd pytorch && \
    git checkout $(VERSION) && \
    MACOSX_DEPLOYMENT_TARGET=10.13 CC=clang CXX=clang++ CXXFLAGS=-stdlib=libc++ python setup.py install
	rm -rf ./pytorch

install-pytorch-linux:
# installation instruction see: https://github.com/pytorch/pytorch#install-optional-dependencies
	export CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" && \
    source activate $(CONDA_ENV) && \
    yes | conda install numpy pyyaml mkl mkl-include setuptools cmake cffi typing && \
    yes | conda install -c pytorch magma-cuda90 && \
    git clone --recursive https://github.com/pytorch/pytorch && \
    cd pytorch && \
    git checkout $(TORCH_VER) && \
    source activate $(CONDA_ENV) && \
    python setup.py install
	rm -rf ./pytorch

install-nvidia-docker-debian:
	# If you have nvidia-docker 1.0 installed: we need to remove it and all existing GPU containers
    docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
    sudo apt-get purge -y nvidia-docker

    # Add the package repositories
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
      sudo apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
      sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update

    # Install nvidia-docker2 and reload the Docker daemon configuration
    sudo apt-get install -y nvidia-docker2
    sudo pkill -SIGHUP dockerd

    # Test nvidia-smi with the latest official CUDA image
    docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi

