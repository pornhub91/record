# record
https://logoly.pro/#/ 图片生成网址

Jenkins上面优化maven编译时间执行命令：
```
clean install   -T 1C -Dmaven.test.skip=true -Dmaven.compile.fork=true -U -pl  panda-bss-schedule  -am
-T 1C 表示每个CPU核心跑一个工程；
-Dmaven-test-skip=true  表示：跳过maven 测试
-Dmaven.compile.fork=true 多线程进行编译；
-pl ........ 代表 需要打包的模块
-am : 把该模块所依赖的 包全部打进去
```



redis cluster down可能和这个参数有关
```
vm.overcommit_memory
0， 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。
1， 表示内核允许分配所有的物理内存，而不管当前的内存状态如何。
2， 表示内核允许分配超过所有物理内存和交换空间总和的内存

需要改成1
```

# K8S相关
https://github.com/easzlab/kubeasz
