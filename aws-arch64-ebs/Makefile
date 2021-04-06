INS_IP=`< instrument_ip_address.txt`

DEBUG_FILE_MASK=--include='*/' --include='*.*' --exclude='*'
DEBUG_REMOTE_RUN=/home/ubuntu/machine_learning/berkeley-playground/runs/

ALL=--include='*/' --include='*'
FILE_MASK=--include='*/' --include='*10.pkl' --include='*Conv2d.pkl' --include='*000_[A-Z]*.pkl' --include='parameters.pkl' --include='.diff' --include='data.pkl' --include='*[A-z0].png' --include='*.jpg' --include='*.log' --include='*debug.png' --include='*.py' --exclude='*'
# FILE_MASK=--include='test-causal_infogan/' --include='test-causal_infogan/***' --include='*.*' --exclude='*'
# FILE_MASK=--include='key_seq_tran/' --include='key_seq_tran/***' --include='*.*' --exclude='*'
# REMOTE_RUN=/home/ubuntu/runs/
EXP_FOLDER='geyang/uvpn/2020/07-11/03_evaluations/mpc_eval/inv_m-mpc/14.10.02/peg-insert-per-task-baseline/y\(-0.12\)'
REMOTE_RUN=/home/ubuntu/runs/${EXP_FOLDER}/
LOCAL_RUN=/Users/ge/berkeley/runs/${EXP_FOLDER}
EXT_HDD_RUN=/Volumes/ge-bair/ins-runs/${EXP_FOLDER}

start:
	yes yes | terraform apply
hodor:
	ssh ubuntu@hodor.banatao.berkeley.edu -i ~/.ssh/incrementium-berkeley
oberyn:
	ssh ubuntu@oberyn.banatao.berkeley.edu -i ~/.ssh/incrementium-berkeley
bill:
	ssh ubuntu@169.229.223.113 -i ~/.ssh/incrementium-berkeley
krypton:
	ssh -o "PasswordAuthentication=no" -o "ChallengeResponseAuthentication=no" ge@slab-krypton.uchicago.edu -i ~/.ssh/incrementium-uchicago
ssh-instrument:
	ssh ec2-user@${INS_IP} -i ~/.aws/ge-improbable-aws-west-2.pem
show-instrument:
	echo ${INS_IP}
exec:
	ssh -t ubuntu@${IP} -i ~/.ec2/ge-berkeley.pem ${cmd}
exec-instrument:
	ssh -t ubuntu@${INS_IP} -i ~/.ec2/ge-berkeley.pem ${cmd}
log:
	make exec-instrument cmd="make tail"
htop:
	make exec cmd="htop"
ps:
	make exec cmd="docker ps"
kill:
	make exec cmd="docker kill ${id}"
stop:
	terraform destroy -force
clean:
	rm ip_address.txt
upload:
	echo "copying from server-scripts to ubuntu@${IP}:/home/ubuntu/scripts"
	scp -i ~/.ec2/ge-berkeley.pem -r server-scripts/* ubuntu@${IP}:/home/ubuntu/scripts
download:
	mkdir -p ${LOCAL_RUN}
	echo "copying from ubuntu@${INS_IP}:${REMOTE_RUN} to local"
	rsync -am ${FILE_MASK} -P -e "ssh -i ~/.aws/ge-berkeley.pem" ubuntu@${INS_IP}:${REMOTE_RUN} ${LOCAL_RUN}
download-all:
	mkdir -p ${LOCAL_RUN}
	echo "copying from ubuntu@${INS_IP}:${REMOTE_RUN} to local"
	rsync -am ${ALL} -P -e "ssh -i ~/.aws/ge-berkeley.pem" ubuntu@${INS_IP}:${REMOTE_RUN} ${LOCAL_RUN}
ext-download:
	mkdir -p ${EXT_HDD_RUN}
	echo "copying from ubuntu@${INS_IP}:${REMOTE_RUN} to local"
	rsync -am ${FILE_MASK} -P -e "ssh -i ~/.ec2/ge-berkeley.pem" ubuntu@${INS_IP}:${REMOTE_RUN} ${EXT_HDD_RUN}
ext-download-all:
	mkdir -p ${EXT_HDD_RUN}
	echo "copying from ubuntu@${INS_IP}:${REMOTE_RUN} to local"
	rsync -am ${ALL} -P -e "ssh -i ~/.ec2/ge-berkeley.pem" ubuntu@${INS_IP}:${REMOTE_RUN} ${EXT_HDD_RUN}
open:
	open ${LOCAL_RUN}
get-ip:
	cat ip_address.txt
mount-runs:
	sshfs ubuntu@${INS_IP}:/home/ubuntu/runs ../../aws-runs -o IdentityFile=~/.ec2/ge-berkeley.pem


debug-download:
	mkdir -p ${LOCAL_RUN}
	echo "copying from ubuntu@${IP}:${DEBUG_REMOTE_RUN} to local"
	rsync -am ${DEBUG_FILE_MASK} -P -e "ssh -i ~/.ec2/ge-berkeley.pem" ubuntu@${IP}:${DEBUG_REMOTE_RUN} ${LOCAL_RUN}
