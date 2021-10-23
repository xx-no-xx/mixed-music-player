# mixed-music-player

## 歌单数据的管理

### API

详见proto部分。
### 数据存储说明

#### 歌曲无关的歌单数据

TODO
#### 歌曲数据

歌曲数据（包括歌曲与它所属的歌单编号）被裸露地存储在./data.txt（目前不是data.txt，而是测试路径）
以如下的格式：

每个歌曲目前包括几行：

```
（换行符号）
数字标识的歌单编号（换行符号）
歌曲的路径
```
```
e.g.

99824  
C:\Users\gassq\Desktop\114567630-1-208.mp3 
99824 
C:\Users\gassq\Desktop\goddhere.mp3  
3231         
C:\Users\gassq\Desktop\114567630-1-208.mp3 
```

注意事项：

- 长度分别被补全为maxGroupDetailLength, maxFileLength; 便于读取时读取。

- 如果一首歌属于多个组，它需要多次存储