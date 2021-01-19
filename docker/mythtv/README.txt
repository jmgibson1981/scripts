Git - https://github.com/jmgibson1981/scripts/tree/main/docker/mythtv

V1.3 Notes: Fixed another permissions issue with the SQL directory. Also added a check to remove existing pid file on container stop / start. This existing pid would prevent the backend from starting properly.
V1.2 Notes: sorted out some issues with permissions when creating a new image. also gave the mythtv user the /bin/bash shell prompt.
V1.1 Notes: moved to a proper entrypoint rather than systemd service to manage. also added the xmltv-util package.

This docker is built for a fully self contained mythtv backend. It has mariadb built in and the ability to run multiple instances based on environment files. It also has cron installed and runs the optimization script on the database weekly.

To run this container use the following format

docker run -id --name "$NAME" -h "$NAME" --network host --mount source=mythtvenv,destination=/etc/mythtvenv --mount source="$NAME",destination=/var/lib/mythtv --restart always mythtv

I symlink the mythtvenv volume into /root/MYTHTVENV for convenience. You name these files to the "$NAME" variable. If you do not have a matching file it will run on default ports. The files are just 4 bash / sh variables. Example below. The shebang is just for highlighting in my editor.

#!/bin/sh
# these are default in built-in config files
SSHPORT=22222
SQLPORT=33066
# different ports to run on. MasterServerPort is not defined. It is deprecated.
# The script assigns it the same value as BackendServerPort.
BackendServerPort=50000
BackendStatusPort=50001

The entrypoint script handles basic initial sql configuration and adjusts ports when needed based on the environment files.

TODO
* need to do a full test. mythtv does some interesting things with ports. as such while i have ran multiple instances on a single host i have not had them both running at the same time. i only have a single network tuner with 2 outputs. it appears that 2 can't pull from the same tuner at the same time.

* need to tighten sql permissions for backup

* still chasing why i cannot restart the mythtv service after configuration over the ssh connection. workaround is running the following command. 
	docker exec -it "$NAME" service mythtv-backend start

