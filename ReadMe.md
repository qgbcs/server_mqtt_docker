在 /workspaces/build_xime_home/server_mqtt_docker  创建一个docker镜像用于运行 server_mqtt . 
因为multi mqtt是私有仓库。你只把/workspaces/build_xime_home/git.py 加入docker  当我使用 

docker run -it -p 192.168.1.20:1177:1177 -v /home/qgb/github:/home/qgb/github docker.io/qgbcs/server_mqtt https://xxx.com/qgbcs/multi_mqtt 

运行时候，才会使用 git.py  clone multi_mqtt 到/home/qgb/github/ 完成后[如果已经存在不用clone]再运行  。你需要完成构建并上传dockerhub 。在dockerhub 需要登陆时候停下来。我会自己输入密码完成剩下工作 文件夹已经在/workspaces/build_xime_home/server_mqtt_docker 