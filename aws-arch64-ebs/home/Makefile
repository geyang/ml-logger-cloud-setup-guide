.PHONY: default
SHELL=/bin/bash
default: launch-logger launch-dash

launch-logger:
	SANIC_REQUEST_MAX_SIZE=5000000000 SANIC_REQUEST_TIMEOUT=3600 SANIC_RESPONSE_TIMEOUT=3600 screen -dm python -m ml_logger.server --logdir ~/runs --port 8080 --host 0.0.0.0 --workers 16
launch-dash:
	screen -dm python -m ml_dash.server --logdir runs --port 8090 --host 0.0.0.0 --workers 20

jupyter:
	source activate pytorch_p36 && cd runs && jupyter notebook --ip=* --port=5040
tunnel:
	sudo nc -k -l 0.0.0.0 80 -n 127.0.0.1 5040
resize-ebs:
	sudo resize2fs /dev/nvme1n1