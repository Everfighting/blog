#!/bin/bash

# 定义日志文件，方便排查问题
LOG_FILE="/root/blog/deploy.log"
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

# 生成静态文件
echo "生成Hexo静态文件..." >> $LOG_FILE
hexo g >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "错误：hexo g失败" >> $LOG_FILE
  exit 1
fi

# 停止现有Hexo服务（如果存在）
echo "停止现有Hexo服务..." >> $LOG_FILE
pkill -f "hexo s" >> $LOG_FILE 2>&1

# 后台启动Hexo服务（指定端口，默认4000）
echo "启动Hexo服务..." >> $LOG_FILE
nohup hexo s > /dev/null 2>&1 &

echo "===== $(date "+%Y-%m-%d %H:%M:%S") 部署完成 =====" >> $LOG_FILE

