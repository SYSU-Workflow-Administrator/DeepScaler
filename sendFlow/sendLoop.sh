#
#nohup python3 workload_manager.py >/dev/null 2>&1 &
# The -a means address of API server, 0.0.0.0 is necessary, or server can't be accessed outside.

while true
do
    echo "开始发送流量"
    nohup locust -f /ssj/ssj/boutiquessj/pyboutique/sendflow/load_generator.py --headless > /ssj/ssj/boutiquessj/pyboutique/logs/loadLoopNEWHAB.log 2>&1 &
    wait
    echo "结束流量"
done