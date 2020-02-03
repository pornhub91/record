# record
https://logoly.pro/#/ 图片生成网址

Jenkins上面优化maven编译时间执行命令：
````
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

sublime license
```
ZYNGA INC.
50 User License
EA7E-811825
927BA117 84C9300F 4A0CCBC4 34A56B44
985E4562 59F2B63B CCCFF92F 0E646B83
0FD6487D 1507AE29 9CC4F9F5 0A6F32E3
0343D868 C18E2CD5 27641A71 25475648
309705B3 E468DDC4 1B766A18 7952D28C
E627DDBA 960A2153 69A2D98A C87C0607
45DC6049 8C04EC29 D18DFA40 442C680B
1342224D 44D90641 33A3B9F2 46AADB8F
```
