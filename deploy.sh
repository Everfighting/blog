#!/bin/bash

# 定义日志文件，方便排查问题
LOG_FILE="/root/blog/deploy.log"
# 部署开始时清空日志文件
> $LOG_FILE
# 写入部署开始标识
echo "===== $(date "+%Y-%m-%d %H:%M:%S") 开始部署 =====" >> $LOG_FILE

# 进入博客目录
cd /root/blog || {
  echo "错误：无法进入/root/blog目录" >> $LOG_FILE
  exit 1
}

# 拉取最新代码
echo "拉取最新代码..." >> $LOG_FILE
git pull origin main >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "错误：git pull失败" >> $LOG_FILE
  exit 1
fi

# 清理旧静态文件
echo "清理旧静态文件..." >> $LOG_FILE
hexo clean >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "错误：hexo clean失败" >> $LOG_FILE
  exit 1
fi

# 生成静态文件
echo "生成Hexo静态文件..." >> $LOG_FILE
hexo generate >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "错误：hexo generate失败" >> $LOG_FILE
  exit 1
fi

# 停止占用4000端口的进程（精准杀进程）
echo "停止占用4000端口的进程..." >> $LOG_FILE
# 查找占用4000端口的进程PID并杀死
PID=$(lsof -t -i:4000)
if [ -n "$PID" ]; then
  kill -9 $PID >> $LOG_FILE 2>&1
  echo "已杀死占用4000端口的进程（PID: $PID）" >> $LOG_FILE
else
  echo "没有占用4000端口的进程" >> $LOG_FILE
fi

# 启动Hexo服务（统一使用LOG_FILE变量并保持追加模式）
echo "启动Hexo服务..." >> $LOG_FILE
nohup hexo server  -i 0.0.0.0 >> $LOG_FILE 2>&1 &

echo "===== $(date "+%Y-%m-%d %H:%M:%S") 部署完成 =====" >> $LOG_FILE
