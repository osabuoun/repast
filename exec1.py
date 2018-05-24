from __future__ import absolute_import, unicode_literals
import time, shlex, subprocess, random, sys, os

task_command = ["bash", "/opt/execute.sh"]
task_data = [
	"repast", 
	"repast_test_123258",
	"ftp://jobserver.hopto.org/repast/exp_02/output/",
	'http://jobserver.hopto.org/repast/exp_02/model.tar',
	"http://jobserver.hopto.org/repast/exp_02/input/batch_params.xml_18"
]
command = ['sudo', 'docker', 'exec', sys.argv[1]]  + task_command + task_data
#command = "sudo docker " + "exec " + sys.argv[1] + " ls /"
print("command: " + str(command))
output = subprocess.check_output(command)

print(output)