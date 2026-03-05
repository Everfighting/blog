---
title: PyTorch图像分类神经网络模型搭建教程（通俗版）
date: 2026-03-05 17:30:00
tags:
  - PyTorch
  - 深度学习
  - 计算机视觉
  - 神经网络
  - 机器学习

categories: 教程
description: 从零开始学习PyTorch图像分类：通俗易懂的完整教程，涵盖环境准备、数据加载、模型搭建、训练评估和进阶技巧，新手也能轻松掌握CNN与ResNet
abbrlink: pytorch-image-classification-tutorial
toc: true
---

# PyTorch图像分类神经网络模型搭建教程（通俗版）

## 问题背景与定义

先跟大家聊个贴近生活的场景：打开手机相册，系统能自动把照片分成"人物""风景""宠物"；刷电商平台，上传一张衣服图片，就能搜到同款--这些我们习以为常的功能，背后核心技术之一就是「图像分类」。

简单说，图像分类就是让计算机"看懂"图片，给它贴一个准确的"标签"（比如"猫""狗""飞机"）。这看似简单，对计算机来说却不容易：我们肉眼能轻松区分猫和狗，但计算机看到的只是一堆由0和1组成的像素点，它需要通过算法"学习"像素背后的规律，才能实现准确分类。

### 为什么要做这个开发？（开发背景）

在人工智能和计算机视觉领域，图像分类是最基础、最核心的任务之一，几乎所有和"看图"相关的应用，都离不开它的支撑：

- 日常应用：手机相册分类、美颜APP的场景识别、智能监控的异常检测（比如识别陌生人闯入）；

- 行业应用：医疗影像诊断（识别病灶）、农业病虫害识别、工业质检（识别产品缺陷）、自动驾驶（识别行人和车辆）；

- 学习意义：掌握图像分类模型搭建，是入门计算机视觉的关键一步，学会后能轻松迁移到其他视觉任务（比如目标检测、图像分割）。

### 我们要解决什么具体问题？（问题定义）

本次开发的核心目标很明确：用PyTorch框架，搭建一个能准确识别「CIFAR-10数据集」中10类物体的神经网络模型。

可能有小伙伴会问：什么是CIFAR-10？它是一个专门用于图像分类练习的"标准数据集"，就像我们学习编程时用的"Hello World"一样，是入门必备。它包含6万张32x32的彩色小图片，分为10个类别（飞机、汽车、鸟类、猫、鹿、狗、青蛙、马、船、卡车），其中5万张用来训练模型，1万张用来测试模型的准确率。

我们的开发任务，就是让模型通过"学习"5万张训练图片的特征，最终能在1万张测试图片上，准确识别出每一张图片属于哪一类，争取让准确率达到较高水平（新手能做到70%-80%，优化后能达到90%以上）。

另外，考虑到很多小伙伴是新手，本次教程会尽量避开晦涩的专业术语，用"大白话"解释核心概念，每一步代码都加上详细注释，确保大家能跟着操作、看懂原理，真正做到"从问题出发，落地到具体开发"。

## 环境准备

### 安装 PyTorch

要搭建模型，首先得有"工具"--PyTorch。它是目前最流行的深度学习框架之一，简单易用，特别适合新手入门，而且支持GPU加速（训练模型更快）。

大家直接复制下面的命令，在自己的终端（Windows用CMD或PowerShell，Mac/Linux用终端）执行，就能安装PyTorch和相关依赖（比如处理图像的torchvision）。

```bash
 # 安装PyTorch命令（新手直接用第一个）
 # 安装PyTorch（自动匹配你的系统，新手优先用这个）
pip install torch torchvision torchaudio

 # 或者针对特定CUDA版本（有独立显卡、懂GPU配置的小伙伴用，能加速训练）
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
```

补充说明：如果安装过程中提示"pip版本过低"，先执行 `pip install --upgrade pip` 更新pip，再重新安装即可。

### 验证安装

安装完成后，我们来检查一下是否安装成功，很简单，打开Python（或Jupyter Notebook），输入下面的代码，能正常输出版本和GPU状态就没问题。

```python
 # 验证PyTorch安装是否成功
import torch
import torchvision
print(f"PyTorch版本: {torch.__version__}")  # 输出版本号，比如2.0.0以上都可以
print(f"CUDA是否可用: {torch.cuda.is_available()}")  # 输出True就是能用GPU，False就是用CPU（新手也能正常训练，就是慢一点）
```

如果输出没有报错，就说明环境已经准备好，可以开始下一步啦！

## 基础概念

在正式搭建模型前，我们先搞懂几个PyTorch的核心概念--不用死记硬背，理解意思就行，后续用多了自然就熟练了。

### 核心组件（常用工具包）

PyTorch就像一个"工具箱"，里面有很多现成的工具，我们常用的有4个，用大白话解释如下：

- **torch.nn**: 相当于"模型零件库"，里面有搭建神经网络需要的所有"零件"--比如卷积层、全连接层、损失函数，不用我们自己从零写代码，直接拿来用就行；

- **torch.optim**: 相当于"模型优化器"，负责帮模型"调整参数"，让模型越学越准（比如我们后面会用的Adam，就是最常用的优化器之一）；

- **torchvision**: 相当于"计算机视觉专用工具"，里面有现成的数据集（比如我们要用的CIFAR-10）、图像预处理工具、甚至预训练好的模型，能省很多事；

- **torch.utils.data**: 相当于"数据搬运工"，负责把我们的数据集整理好，批量喂给模型训练，不用我们手动一张一张处理图片。

### 张量 (Tensor)--PyTorch的"核心数据格式"

我们平时用的图片，在计算机里是由"像素"组成的（比如32x32的图片，就是32行、32列的像素点）；而在PyTorch里，这些像素点会被转换成「张量」（Tensor），相当于"升级版的数组"--和NumPy的数组很像，但支持GPU加速，能让模型训练更快。

举个简单的例子，大家运行下面的代码，就能直观感受到张量是什么：

```python
 # 张量的简单操作（新手可直接复制运行）
import torch

 # 1. 创建一个简单的张量（相当于一个一维数组）
x = torch.tensor([1, 2, 3])
print("简单张量:", x)  # 输出：tensor([1, 2, 3])

 # 2. 创建一个3x3的随机张量（符合正态分布，常用在模型初始化）
x = torch.randn(3, 3)  # 3行3列的随机数
print("3x3随机张量:\n", x)

 # 3. 张量的基本运算（比如矩阵乘法，模型中常用）
y = torch.matmul(x, x)  # 两个3x3张量做矩阵乘法
print("矩阵乘法结果:\n", y)
```

补充说明：后续我们处理图片时，图片会被转换成「3通道张量」（因为彩色图片有RGB三个通道），形状大概是（3, 32, 32）--3代表通道数，32x32代表图片的宽和高，大家记住这个形状，后面搭建模型时会用到。

## 数据加载与预处理

### 什么是数据预处理？（大白话解释）

我们拿到的原始图片，就像"生食材"--有的亮、有的暗，有的角度歪，有的尺寸不一样，直接喂给模型，模型会"学懵"，训练效果会很差。

数据预处理，就是把这些"生食材"加工成"熟食材"，让模型能更好地"吸收"，简单说就是做一系列统一化、多样化的处理，核心作用有4个：

- 提高模型的收敛速度：让模型更快找到"学习规律"，不用走弯路；

- 增强模型的泛化能力：让模型不仅能"看懂"训练过的图片，还能"看懂"没见过的图片；

- 减少过拟合：避免模型"死记硬背"训练图片，导致换一张图片就识别错；

- 统一数据格式：把所有图片转换成模型能处理的张量格式，避免报错。

### 使用 CIFAR-10 数据集（我们的"训练素材"）

前面我们提到过，本次开发用的是CIFAR-10数据集，这里再详细跟大家说下，方便大家理解我们要"喂"给模型的是什么：

- 总共60,000张图片，都是32x32像素的彩色图（很小，大概只有指甲盖大小，所以训练起来比较快，适合新手）；

- 分成10个类别，每个类别6,000张图，类别很常见：飞机、汽车、鸟类、猫、鹿、狗、青蛙、马、船、卡车；

- 数据集分为两部分：50,000张训练集（让模型"学习"的素材），10,000张测试集（检验模型学得好不好的"考题"）。

下面的代码，就能帮我们自动下载CIFAR-10数据集，并且完成预处理，大家直接复制运行即可，每一步都加了详细注释，看不懂的地方可以看注释：

```python
 # CIFAR-10数据集加载与预处理（新手可直接运行）
import torchvision
import torchvision.transforms as transforms

 # 数据预处理：把原始图片转换成模型能处理的格式，同时做数据增强
transform = transforms.Compose([
    # 1. 数据增强：随机水平翻转（50%概率），相当于让模型看到"正放"和"反放"的图片，减少过拟合
    transforms.RandomHorizontalFlip(p=0.5),
    # 2. 数据增强：随机裁剪（先在图片边缘填4个像素，再随机裁出32x32），增加图片多样性
    transforms.RandomCrop(32, padding=4),
    # 3. 核心步骤：把PIL格式的图片转换成PyTorch张量，同时把像素值从0-255变成0-1（方便模型计算）
    transforms.ToTensor(),
    # 4. 归一化：把像素值从0-1变成-1到1，让模型训练更稳定（避免某些像素值太大影响训练）
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
])

 # 加载训练集：root是数据集保存路径（./data就是当前文件夹下的data文件夹），train=True表示是训练集
trainset = torchvision.datasets.CIFAR10(
    root='./data', train=True, download=True, transform=transform
)

 # 加载测试集：train=False表示是测试集，download=True表示如果本地没有，自动从网上下载
testset = torchvision.datasets.CIFAR10(
    root='./data', train=False, download=True, transform=transform
)

 # 创建数据加载器：批量加载数据，避免一次性加载所有图片占满内存
trainloader = torch.utils.data.DataLoader(
    trainset, batch_size=64, shuffle=True, num_workers=2
)
 # 测试集加载器：shuffle=False表示不打乱顺序，方便后续统计准确率
testloader = torch.utils.data.DataLoader(
    testset, batch_size=64, shuffle=False, num_workers=2
)

 # 类别标签：和数据集的10个类别对应，后续用来查看模型预测的结果
classes = ('plane', 'car', 'bird', 'cat', 'deer',
           'dog', 'frog', 'horse', 'ship', 'truck')
```

补充说明：第一次运行时，会自动下载数据集（大概几百MB），网速慢的话耐心等一下，下载完成后会保存在当前文件夹的data文件夹里，下次运行就不用再下载了。

### 数据预处理详解（每个步骤通俗解释）

上面的预处理代码里，有4个关键步骤，这里用大白话再解释一遍，帮大家彻底理解：

1. **RandomHorizontalFlip**: 随机水平翻转图片，比如把"朝左的汽车"变成"朝右的汽车"。这样做的目的，是让模型不会"认死理"--不会认为"只有朝左的才是汽车"，从而增强模型的泛化能力；

2. **RandomCrop**: 随机裁剪图片。比如一张32x32的图片，先在边缘填4个像素（变成40x40），再随机裁出32x32的区域。这样能让模型看到图片的不同局部，避免只记住"图片中间有个猫"，而忽略了"猫在角落"的情况；

3. **ToTensor**: 把我们平时看到的图片（PIL格式），转换成PyTorch能处理的张量。这一步是必须的，因为模型只能识别张量格式的数据，不能直接识别图片文件；

4. **Normalize**: 归一化处理。原始图片的像素值是0-255，转换成张量后变成0-1，再通过归一化变成-1到1。这样做是为了让模型计算更稳定，避免某些像素值太大（比如255）导致模型参数更新混乱。

### 数据加载器的作用（为什么需要它？）

很多新手会疑惑：为什么不直接把所有图片加载进来，还要用DataLoader？其实原因很简单，就像"吃饭不能一口吃撑"，模型训练也不能一次性加载所有数据：

- 批量加载数据：每次只加载64张图片（batch_size=64），避免一次性加载6万张图片占满内存，导致程序崩溃；

- 随机打乱训练数据：trainloader的shuffle=True，会每次训练前打乱图片顺序，避免模型"记住"图片的顺序，从而减少过拟合；

- 支持多进程加载：num_workers=2，表示用2个进程同时加载数据，比单进程更快，节省训练时间；

- 支持自定义采样：后续如果需要调整加载策略（比如只加载某个类别的图片），也可以通过DataLoader实现。

## 模型搭建

接下来就是本次开发的核心--搭建神经网络模型。我们会先从"简单模型"入手（适合新手），再介绍"经典模型ResNet"（适合实际应用），大家可以根据自己的基础选择学习。

### 什么是卷积神经网络 (CNN)？（通俗解释）

我们搭建的模型，是「卷积神经网络」（简称CNN），它是专门用来处理图像的神经网络--和传统的"全连接网络"相比，它更"懂"图片，效率更高，原因就在于它有3个核心优势，用大白话解释：

1. **局部感受野**: 就像我们看图片，不会一下子看完整张图，而是先看局部（比如看猫，先看它的脸）。CNN的神经元也一样，每个神经元只关注图片的一个局部区域，这样能减少模型的参数数量，避免模型过于复杂；

2. **参数共享**: 用同一个"特征检测器"（比如"检测猫耳朵的检测器"），去扫描整张图片，而不是每个局部都用一个新的检测器。这样能大大减少参数数量，提高训练效率；

3. **平移不变性**: 不管猫在图片的左上角、右下角，模型都能识别出它是猫--这就是CNN的优势，它能识别不同位置的相同特征；

4. **降维能力**: 通过"池化层"，逐步缩小图片的尺寸（比如32x32变成16x16，再变成8x8），既能保留关键特征，又能减少计算量，让模型训练更快。

### CNN 的基本组成部分（模型的"零件"）

不管是简单CNN还是复杂CNN，核心组成部分都离不开这5个"零件"，每个零件的作用都用大白话讲清楚：

1. **卷积层 (Convolution Layer)**: 核心"特征提取器"，负责从图片中提取特征（比如猫的耳朵、狗的尾巴、汽车的轮子），是CNN的核心；

2. **激活函数 (Activation Function)**: 给模型"注入非线性"，让模型能学习复杂的特征（比如区分"猫"和"狗"的细微差别），常用的是ReLU函数；

3. **池化层 (Pooling Layer)**: "降维工具"，负责缩小图片尺寸，减少计算量，同时保留关键特征，常用的是最大池化（取局部区域的最大值）；

4. **全连接层 (Fully Connected Layer)**: "决策器"，负责把卷积层提取的特征，转换成10个类别的概率（比如"这张图是猫的概率是80%，是狗的概率是10%"），最终输出分类结果；

5. **Dropout 层**: "防过拟合工具"，随机让一部分神经元"休息"（不工作），避免模型"死记硬背"训练图片，从而增强泛化能力。

### 简单 CNN 模型（新手入门首选）

我们先搭建一个简单的CNN模型，包含3个卷积层（提取特征）和2个全连接层（做决策），结构简单，容易理解，新手能轻松跟着实现。下面的代码，每一行都加了详细注释，大家可以一边看注释，一边复制运行：

```python
 # 简单CNN模型搭建（新手必看，注释详细）
import torch.nn as nn
import torch.nn.functional as F

 # 定义简单CNN模型，继承nn.Module（PyTorch中所有模型都要继承这个类）
class SimpleCNN(nn.Module):
    def __init__(self):
        super(SimpleCNN, self).__init__()  # 固定写法，初始化父类

        # 卷积层1: 输入3通道(RGB彩色图)，输出16通道（16个特征检测器），卷积核3x3
        # padding=1：让输入和输出的图片尺寸一样（32x32输入，32x32输出），避免尺寸缩小
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)

        # 池化层: 2x2最大池化，步长为2（每次移动2个像素）
        # 作用：把图片尺寸缩小一半（32x32变成16x16），减少计算量
        self.pool = nn.MaxPool2d(2, 2)

        # 卷积层2: 输入16通道（上一层的输出），输出32通道，卷积核3x3，padding=1
        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)

        # 卷积层3: 输入32通道，输出64通道，卷积核3x3，padding=1
        self.conv3 = nn.Conv2d(32, 64, 3, padding=1)

        # 全连接层1: 输入64*4*4，输出512
        # 为什么是64*4*4？因为经过3次池化，32x32的图片变成4x4，每个位置有64个特征
        self.fc1 = nn.Linear(64 * 4 * 4, 512)

        # 全连接层2: 输入512，输出10（对应10个类别）
        self.fc2 = nn.Linear(512, 10)

        # Dropout层: 随机失活50%的神经元（train时生效，test时不生效），防止过拟合
        self.dropout = nn.Dropout(0.5)

    # 前向传播：定义数据在模型中的流动路径（核心，必须有）
    def forward(self, x):
        # 第一步：卷积1 -> ReLU激活 -> 池化
        # 输入：3x32x32 -> 卷积后：16x32x32 -> ReLU激活（注入非线性） -> 池化后：16x16x16
        x = self.pool(F.relu(self.conv1(x)))

        # 第二步：卷积2 -> ReLU激活 -> 池化
        # 输入：16x16x16 -> 卷积后：32x16x16 -> ReLU激活 -> 池化后：32x8x8
        x = self.pool(F.relu(self.conv2(x)))

        # 第三步：卷积3 -> ReLU激活 -> 池化
        # 输入：32x8x8 -> 卷积后：64x8x8 -> ReLU激活 -> 池化后：64x4x4
        x = self.pool(F.relu(self.conv3(x)))

        # 第四步：展平：把64x4x4的特征图，转换成一维向量（方便全连接层处理）
        # -1表示自动计算该维度的大小（这里就是64*4*4=1024）
        x = x.view(-1, 64 * 4 * 4)

        # 第五步：Dropout -> 全连接1 -> ReLU激活
        # Dropout只在训练阶段起作用，测试阶段会自动关闭，防止过拟合
        x = F.relu(self.dropout(self.fc1(x)))

        # 第六步：全连接2，输出10个类别的logits（后续会转换成概率）
        x = self.fc2(x)

        return x

 # 创建模型实例
model = SimpleCNN()

 # 移动模型到GPU（如果可用），没有GPU就用CPU，不影响运行
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
model.to(device)

 # 打印模型结构，看看我们搭建的模型长什么样
print(model)
```

运行代码后，会输出模型的结构，大家可以对照着注释，看看每个层的输入输出尺寸，就能理解数据在模型中是如何流动的了。对于新手来说，不用纠结"为什么是16、32、64个通道"，这是经验值，后续可以自己调整尝试。

### 经典 ResNet 模型（实际应用首选）

上面的简单CNN模型，适合新手入门，但层数比较浅（只有3个卷积层），识别准确率有限。在实际应用中，我们更常用「ResNet」（残差网络）--它是2015年提出的经典模型，解决了"深层网络训练难"的问题（层数越多，模型越容易"学歪"，ResNet通过"残差连接"解决了这个问题）。

#### 残差连接的原理（通俗解释）

传统的深层网络，层数越多，准确率反而会下降（比如100层的网络，比50层的准确率还低），这就是"梯度消失"问题--模型学不到有用的特征。

ResNet的核心创新，就是"残差连接"：相当于给模型加了一条"捷径"，让数据可以"跳过"某些层，直接传递到后面的层。这样一来，模型不用"从头学起"，而是学习"当前层和捷径之间的差异"（残差），从而让深层网络的训练变得更容易，准确率也更高。

好在PyTorch已经帮我们实现了ResNet，我们不用自己从零搭建，直接调用即可，还能使用"预训练权重"（别人已经用大量数据训练好的模型参数），节省我们的训练时间，代码如下：

```python
 # ResNet模型调用（实际应用首选，简单高效）
import torchvision.models as models

 # 使用预训练的ResNet18（18层的ResNet，适合新手，训练速度快）
 # pretrained=True：表示使用在ImageNet（百万张图片）上预训练的权重，相当于"站在巨人的肩膀上"
model = models.resnet18(pretrained=True)

 # 注意：ResNet18默认是识别1000个类别（ImageNet数据集的类别），而我们只需要识别10个类别（CIFAR-10）
 # 所以需要修改最后一层（全连接层），把输出类别数从1000改成10
num_ftrs = model.fc.in_features  # 获取最后一层的输入特征数
model.fc = nn.Linear(num_ftrs, 10)  # 重新定义最后一层，输出10个类别

 # 移动模型到GPU（如果可用）
model.to(device)

 # 打印模型结构，看看修改后的ResNet18
print(model)
```

补充说明：ResNet有很多版本（ResNet18、ResNet34、ResNet50等），层数越多，准确率越高，但训练速度越慢，需要的计算资源越多。新手建议先用ResNet18，既能保证准确率，又能快速看到训练效果。

### 模型参数分析（为什么有的模型训练慢？）

很多新手会疑惑：为什么简单CNN训练快，ResNet训练慢？核心原因就是"参数数量"--参数越多，模型越复杂，训练时需要计算的内容就越多，速度就越慢。

下面的代码，能帮我们计算模型的参数数量（单位：个），大家可以运行一下，对比一下简单CNN和ResNet18的参数差异：

```python
计算模型参数数量（看模型复杂程度）def count_parameters(model):
    # 统计模型中需要训练的参数数量（requires_grad=True表示需要训练）
    return sum(p.numel() for p in model.parameters() if p.requires_grad)

 # 计算并打印两个模型的参数数量（注意：运行前要先创建对应的模型实例）
 # print(f"SimpleCNN 参数数量: {count_parameters(simple_cnn_model):,}")  # 简单CNN，约130万个参数
print(f"ResNet18 参数数量: {count_parameters(model):,}")  # ResNet18，约1100万个参数
```

补充说明：简单CNN只有约130万个参数，ResNet18有约1100万个参数，所以ResNet18的训练速度会慢一些，但准确率会更高。对于新手来说，用CPU训练ResNet18可能需要几个小时，用GPU的话只需要几十分钟，大家可以根据自己的设备选择模型。

## 训练过程

模型搭建好之后，就进入最关键的"训练阶段"了--相当于让模型"学习"训练集中的图片，记住每个类别的特征，从而能准确识别新的图片。

很多新手觉得训练过程很复杂，其实核心就4步：前向传播（让模型预测）→ 计算损失（看预测得多不准）→ 反向传播（计算误差）→ 参数更新（让模型下次预测更准）。下面我们一步步拆解，用通俗的语言和代码讲解。

### 训练的基本原理（大白话拆解）

神经网络的训练，本质上就是"不断修正错误"的过程，就像我们学习做题一样：

1. **前向传播**: 把训练图片喂给模型，模型根据当前的参数，给出一个预测结果（比如把"猫"预测成"狗"）；

2. **计算损失**: 对比模型的预测结果和真实标签（比如真实标签是"猫"，模型预测是"狗"），计算两者的差异（损失值）--损失值越大，说明模型预测得越不准；

3. **反向传播**: 沿着模型的层级，反向计算"每个参数对损失值的影响"（梯度），相当于找到"哪里错了"；

4. **参数更新**: 根据梯度，调整模型的参数（比如调整卷积层的权重），让下次预测的损失值变小--相当于"修正错误"。

这个过程会重复很多次（比如25次，也就是25个epoch），直到模型的预测准确率不再提升，或者达到我们预期的效果。

### 损失函数 (Loss Function)--模型的"纠错指南针"

损失函数，就是用来"衡量模型预测错误程度"的工具，相当于模型的"指南针"，指导模型往"预测更准"的方向调整参数。

不同的任务，用不同的损失函数，我们做的是"多分类任务"（10个类别中选一个），最常用的就是「交叉熵损失」（CrossEntropyLoss）--它能很好地衡量"模型预测的概率分布"和"真实标签的概率分布"之间的差异。

#### 常用的损失函数（简单了解）

1. **交叉熵损失 (CrossEntropyLoss)**: 我们本次用的，适合多分类任务（比如识别10类物体）；

2. **均方误差损失 (MSELoss)**: 适合回归任务（比如预测房价、温度），不适合分类任务；

3. **二元交叉熵损失 (BCELoss)**: 适合二分类任务（比如识别"是猫"还是"不是猫"）。

下面的代码，就能定义我们需要的交叉熵损失函数，很简单：

```python
 # 定义交叉熵损失函数（多分类任务首选）
import torch.optim as optim

 # 损失函数: 交叉熵损失（PyTorch已经封装好，直接调用）
 # 补充：交叉熵损失已经结合了log_softmax和nll_loss，不用我们自己再处理输出
criterion = nn.CrossEntropyLoss()
```

### 优化器 (Optimizer)--模型的"参数调整工具"

损失函数告诉模型"哪里错了"，而优化器则负责"帮模型修正错误"--根据反向传播计算出的梯度，调整模型的参数，让损失值变小。

不同的优化器，调整参数的策略不同，新手最常用、最稳妥的就是「Adam优化器」--它结合了两种优化器的优点，收敛速度快，而且不容易陷入"局部最优"（相当于不会因为一点小进步就停止优化）。

#### 常用的优化器（简单了解）

1. **SGD (随机梯度下降)**: 最基础的优化器，计算简单，但收敛速度慢，容易震荡；

2. **Momentum**: 在SGD基础上增加"动量"，收敛速度比SGD快；

3. **Adam**: 我们本次用的，结合了动量和自适应学习率，新手首选；

4. **RMSprop**: 自适应学习率优化器，适合某些特定任务。

```python
 # 定义Adam优化器（新手首选，参数简单）
 # 优化器: Adam优化器
 # 参数说明：
 # model.parameters(): 需要优化的模型参数（所有需要训练的参数）
 # lr=0.001: 学习率，控制参数更新的步长（步长太大容易震荡，太小收敛太慢，0.001是常用经验值）
optimizer = optim.Adam(model.parameters(), lr=0.001)
```

补充说明：学习率（lr）是一个很重要的超参数，后续我们会讲如何动态调整它，新手先默认用0.001即可。

### 学习率调度器 (Learning Rate Scheduler)--让学习率"智能变化"

学习率是模型训练的"关键超参数"：如果学习率太大，模型会"震荡不收敛"（比如预测准确率忽高忽低）；如果学习率太小，模型收敛太慢（训练很久准确率也上不去）。

学习率调度器，就是用来"动态调整学习率"的工具--比如训练前期，用较大的学习率让模型快速收敛；训练后期，用较小的学习率让模型精细调整，从而获得更好的准确率。

#### 常用的学习率调度策略（简单了解）

1. **StepLR**: 每隔一定epoch数，把学习率乘以一个衰减因子（比如每7个epoch，学习率乘以0.1），我们本次用的就是这个；

2. **ExponentialLR**: 每个epoch，把学习率乘以一个衰减因子，收敛速度比StepLR慢；

3. **CosineAnnealingLR**: 学习率按照余弦函数周期性变化，适合需要精细训练的场景；

4. **ReduceLROnPlateau**: 当验证集性能不再提升时，自动降低学习率，更智能。

```python
 # 定义StepLR学习率调度器（简单好用）
 # 学习率调度器: StepLR
 # 参数说明：
 # optimizer: 需要调整学习率的优化器
 # step_size=7: 每7个epoch，调整一次学习率
 # gamma=0.1: 调整策略，学习率 = 原来的学习率 * 0.1（比如0.001变成0.0001）
scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.1)
```

### 训练循环（核心代码，新手可直接复制运行）

训练循环，就是把"前向传播→计算损失→反向传播→参数更新"这4步，重复很多次（比如25个epoch），同时加入"验证阶段"（用测试集检验模型学得好不好）和"模型保存"（保存表现最好的模型）。

下面的代码是完整的训练循环，加了详细注释，新手可以直接复制运行，运行后就能看到模型的训练过程（每一个epoch的损失值和准确率）：

```python
 # 完整训练循环（核心代码，可直接运行）
import time

def train_model(model, criterion, optimizer, scheduler, num_epochs=25):
    since = time.time()  # 记录训练开始时间，方便后续计算总训练时间

    # 保存最佳模型权重（训练过程中，保存验证准确率最高的模型）
    best_model_wts = model.state_dict()
    best_acc = 0.0  # 记录最佳验证准确率

    # 循环训练num_epochs次（默认25次，新手可以先设5次，快速看效果）
    for epoch in range(num_epochs):
        print(f'Epoch {epoch}/{num_epochs - 1}')  # 打印当前是第几个epoch
        print('-' * 10)

        # 每个epoch都有两个阶段：训练阶段（train）和验证阶段（val）
        for phase in ['train', 'val']:
            if phase == 'train':
                model.train()  # 设置模型为训练模式，启用Dropout和BatchNorm的训练模式
                dataloader = trainloader  # 训练阶段用训练集加载器
            else:
                model.eval()   # 设置模型为评估模式，禁用Dropout和BatchNorm的训练模式
                dataloader = testloader  # 验证阶段用测试集加载器

            running_loss = 0.0  # 记录当前阶段的总损失
            running_corrects = 0  # 记录当前阶段的正确预测数

            # 迭代数据：每次从加载器中取一个batch（64张图片）进行训练/验证
            for inputs, labels in dataloader:
                # 将数据移动到指定设备（GPU或CPU），和模型在同一个设备上才能计算
                inputs = inputs.to(device)
                labels = labels.to(device)

                # 清零参数梯度：非常重要！否则梯度会累积，导致模型更新错误
                optimizer.zero_grad()

                # 前向传播：计算模型的预测结果
                # with torch.set_grad_enabled(phase == 'train'): 只有训练阶段才跟踪梯度（节省内存）
                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)  # 前向传播，得到模型输出（10个类别的logits）
                    _, preds = torch.max(outputs, 1)  # 获取预测结果（概率最大的类别）
                    loss = criterion(outputs, labels)  # 计算损失值

                    # 后向传播 + 参数更新：只在训练阶段执行（验证阶段不更新模型）
                    if phase == 'train':
                        loss.backward()  # 反向传播，计算梯度
                        optimizer.step()  # 根据梯度，更新模型参数

                # 统计损失和准确率：running_loss累积损失，running_corrects累积正确预测数
                running_loss += loss.item() * inputs.size(0)  # 损失值乘以batch大小，避免受batch影响
                running_corrects += torch.sum(preds == labels.data)  # 统计正确预测的样本数

            # 更新学习率：只在训练阶段执行（验证阶段不调整学习率）
            if phase == 'train':
                scheduler.step()

            # 计算当前阶段的平均损失和准确率
            epoch_loss = running_loss / len(dataloader.dataset)  # 总损失 / 总样本数
            epoch_acc = running_corrects.double() / len(dataloader.dataset)  # 正确数 / 总样本数

            # 打印当前阶段的损失和准确率
            print(f'{phase} Loss: {epoch_loss:.4f} Acc: {epoch_acc:.4f}')

            # 保存最佳模型：如果验证阶段的准确率比当前最佳准确率高，就保存模型权重
            if phase == 'val' and epoch_acc > best_acc:
                best_acc = epoch_acc
                best_model_wts = model.state_dict()  # 深度拷贝模型权重
        print()  # 换行，让输出更清晰

    # 计算总训练时间
    time_elapsed = time.time() - since
    print(f'Training complete in {time_elapsed // 60:.0f}m {time_elapsed % 60:.0f}s')
    print(f'Best val Acc: {best_acc:.4f}')  # 打印最佳验证准确率

    # 加载最佳模型权重：训练结束后，加载表现最好的模型
    model.load_state_dict(best_model_wts)
    return model

 # 开始训练模型（num_epochs=25，新手可以改成5，快速测试）
model = train_model(model, criterion, optimizer, scheduler, num_epochs=25)
```

补充说明：训练过程中，大家可以关注两个指标：train Loss（训练损失）和val Acc（验证准确率）。正常情况下，train Loss会随着epoch增加而逐渐减小，val Acc会逐渐增加，直到趋于稳定--如果val Acc不再增加，甚至开始下降，说明模型可能过拟合了，后续我们会讲如何解决。

### 训练过程中的重要概念（新手必懂）

训练过程中，会遇到几个常用概念，这里用大白话解释清楚，避免大家看不懂：

1. **Epoch**: 模型遍历整个训练数据集一次，就是一个epoch。比如我们设置num_epochs=25，就是让模型把5万张训练图片，学习25遍；

2. **Batch**: 一次训练中使用的样本数量，我们设置的batch_size=64，就是每次让模型学习64张图片；

3. **Iteration**: 一次参数更新的过程，也就是处理一个batch的过程（比如5万张图片，batch_size=64，一个epoch就有50000/64≈781个iteration）；

4. **过拟合**: 模型在训练集上表现很好（准确率很高），但在测试集上表现很差（准确率很低），相当于"死记硬背"了训练图片，不会举一反三；

5. **欠拟合**: 模型在训练集和测试集上表现都很差（准确率很低），相当于"没学会"，没有掌握图片的特征；

6. **早停**: 当验证集准确率不再提升时，提前停止训练，防止模型过拟合（后续进阶技巧会详细讲）。

## 模型评估

模型训练完成后，不能直接用--我们需要通过"模型评估"，看看它在未见过的测试集上表现如何，判断它是否能满足我们的需求。

很多新手只关注"准确率"这一个指标，其实这不够全面。下面我们会介绍常用的评估指标，以及如何用代码实现评估，帮大家全面了解模型的性能。

### 为什么需要模型评估？（通俗解释）

模型评估就像"考试"--训练过程是"学习"，评估过程是"考试"，通过考试，我们能知道：

1. **了解模型性能**: 模型到底能准确识别多少张测试图片（准确率）；

2. **比较不同模型**: 比如简单CNN和ResNet18，哪个准确率更高，哪个更适合我们的需求；

3. **发现问题**: 模型在哪些类别上表现较差（比如容易把"猫"和"狗"搞混）；

4. **改进模型**: 根据评估结果，调整模型架构或训练策略（比如增加数据增强，解决过拟合）。

### 常用的评估指标（大白话解释）

评估模型不能只看准确率，下面4个指标是最常用的，用"识别猫和狗"的二分类例子，帮大家理解：

#### 1. 准确率 (Accuracy)

最直观的指标，定义为"正确预测的样本数 ÷ 总样本数"。比如100张测试图片，模型正确识别了80张，准确率就是80%。

优点：简单易懂；缺点：如果样本不均衡（比如90张猫，10张狗），模型只预测"猫"，准确率也能达到90%，但其实模型并没有学会识别狗。

#### 2. 精确率 (Precision)

关注"模型预测为正类的样本中，实际为正类的比例"。比如模型预测了10张"猫"，其中8张是真的猫，精确率就是80%。

通俗说：模型预测的"猫"，到底有多少是真的猫？精确率越高，"误判"越少。

#### 3. 召回率 (Recall)

关注"实际为正类的样本中，被模型正确预测为正类的比例"。比如实际有10张猫，模型只识别出8张，召回率就是80%。

通俗说：所有
PyTorch图像分类神经网络模型搭建教程（通俗版-剩余部分）

的猫，模型能识别出多少张？召回率越高，"漏判"越少。

4. F1分数 (F1-Score)

精确率和召回率往往是"矛盾"的：比如想让模型少误判（提高精确率），就可能会漏判（降低召回率）；想让模型少漏判（提高召回率），就可能会误判（降低精确率）。

F1分数就是精确率和召回率的"调和平均数"，能综合反映两者的水平，避免单一指标的片面性。计算公式很简单（不用记，代码会自动计算）：F1 = 2 × (精确率 × 召回率) ÷ (精确率 + 召回率)，取值范围0-1，越接近1越好。

补充说明：我们做的CIFAR-10是多分类任务，上述4个指标会针对每个类别单独计算，最后取"平均值"（常用宏平均、微平均），代码中会自动实现，新手不用手动计算。

模型评估代码实现（新手可直接复制运行）
```python

前面的训练循环中，我们已经计算了验证准确率（val Acc），但这不够全面。下面的代码，会帮我们计算每个类别的精确率、召回率、F1分数，还会打印混淆矩阵（直观看到模型在每个类别上的误判情况），大家直接复制运行即可：


import torch
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np

 # 1. 准备测试数据的预测结果和真实标签
y_true = []  # 存储所有测试样本的真实标签
y_pred = []  # 存储所有测试样本的预测标签

 # 切换模型为评估模式（禁用Dropout）
model.eval()

 # 迭代测试集，获取预测结果
with torch.no_grad():  # 禁用梯度计算，节省内存，加快速度
    for inputs, labels in testloader:
        inputs = inputs.to(device)
        labels = labels.to(device)

        # 前向传播，获取预测结果
        outputs = model(inputs)
        _, preds = torch.max(outputs, 1)  # 取概率最大的类别作为预测结果

        # 将标签和预测结果转换为CPU格式，并存入列表
        y_true.extend(labels.cpu().numpy())
        y_pred.extend(preds.cpu().numpy())

 # 2. 计算并打印分类报告（精确率、召回率、F1分数）
print("=" * 50)
print("分类报告（每个类别详细指标）:")
print("=" * 50)
 # target_names：类别名称，和我们之前定义的classes对应
print(classification_report(
    y_true, y_pred, target_names=classes, digits=4  # digits=4：保留4位小数，更清晰
))

 # 3. 计算并打印混淆矩阵（直观查看误判情况）
print("=" * 50)
print("混淆矩阵（行=真实类别，列=预测类别）:")
print("=" * 50)
cm = confusion_matrix(y_true, y_pred)
print(cm)

 # 4. 计算每个类别的准确率（方便查看模型在哪些类别上表现差）
class_correct = list(0. for i in range(10))  # 每个类别正确预测的数量
class_total = list(0. for i in range(10))    # 每个类别的总样本数

with torch.no_grad():
    for inputs, labels in testloader:
        inputs = inputs.to(device)
        labels = labels.to(device)
        outputs = model(inputs)
        _, preds = torch.max(outputs, 1)
        c = (preds == labels).squeeze()  # 筛选出预测正确的样本

        # 统计每个类别的正确数和总数
        for label, correct in zip(labels, c):
            class_correct[label] += correct.item()
            class_total[label] += 1

 # 打印每个类别的准确率
print("=" * 50)
print("每个类别的准确率:")
print("=" * 50)
for i in range(10):
    print(f"类别 {classes[i]}: {class_correct[i] / class_total[i]:.4f} ({int(class_correct[i])}/{int(class_total[i])})")


```
评估结果解读（新手必看）

运行上面的代码后，会输出3部分内容，我们用通俗的语言解读，帮大家快速找到模型的问题：

1. 分类报告：重点看"macro avg"（宏平均）的精确率、召回率、F1分数--这三个指标越接近1，说明模型整体性能越好。如果某个类别（比如cat）的F1分数很低，说明模型在这个类别上表现较差，容易和其他类别（比如dog）搞混；

2. 混淆矩阵：矩阵的"对角线"表示预测正确的样本数，对角线以外的数值表示误判的样本数。比如第3行（cat）第4列（dog）的数值很大，说明很多猫的图片被误判成了狗；

3. 每个类别的准确率：直接看出哪个类别最难识别（准确率最低），比如如果cat的准确率只有60%，而plane的准确率有90%，说明模型对猫的特征提取不够到位，后续可以针对性优化。

补充说明：新手搭建的简单CNN模型，整体F1分数能达到70%-80%就很正常；用ResNet18且优化后，F1分数能达到90%以上，大家可以对照这个标准，判断自己的模型表现。

## 完整代码示例

很多新手会觉得"代码分散在各个章节，复制起来麻烦"，这里整理了完整的代码示例——把前面的环境准备、数据加载、模型搭建、训练、评估代码整合到一起，大家直接复制到Python文件（比如train.py），运行就能完成整个图像分类任务，每一步都保留了详细注释：


```python
 # 导入所需库
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
import time
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np

 # -------------------------- 1. 环境准备与设备设置 --------------------------
 # 检测GPU是否可用，优先使用GPU
device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
print(f"使用设备: {device}")  # 打印当前使用的设备（CPU/GPU）

 # -------------------------- 2. 数据加载与预处理 --------------------------
 # 数据预处理：统一格式+数据增强
transform = transforms.Compose([
    transforms.RandomHorizontalFlip(p=0.5),  # 随机水平翻转
    transforms.RandomCrop(32, padding=4),    # 随机裁剪
    transforms.ToTensor(),                   # 转换为张量
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))  # 归一化
])

 # 加载CIFAR-10数据集
trainset = torchvision.datasets.CIFAR10(
    root='./data', train=True, download=True, transform=transform
)
testset = torchvision.datasets.CIFAR10(
    root='./data', train=False, download=True, transform=transform
)

 # 创建数据加载器
trainloader = torch.utils.data.DataLoader(
    trainset, batch_size=64, shuffle=True, num_workers=2
)
testloader = torch.utils.data.DataLoader(
    testset, batch_size=64, shuffle=False, num_workers=2
)

 # 类别标签
classes = ('plane', 'car', 'bird', 'cat', 'deer',
           'dog', 'frog', 'horse', 'ship', 'truck')

 # -------------------------- 3. 模型搭建（二选一，新手先试SimpleCNN） --------------------------
 # 选项1：简单CNN模型（新手入门首选）
class SimpleCNN(nn.Module):
    def __init__(self):
        super(SimpleCNN, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)
        self.conv3 = nn.Conv2d(32, 64, 3, padding=1)
        self.fc1 = nn.Linear(64 * 4 * 4, 512)
        self.fc2 = nn.Linear(512, 10)
        self.dropout = nn.Dropout(0.5)

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = self.pool(F.relu(self.conv3(x)))
        x = x.view(-1, 64 * 4 * 4)
        x = F.relu(self.dropout(self.fc1(x)))
        x = self.fc2(x)
        return x

 # 选项2：ResNet18模型（实际应用首选，需注释掉上面的SimpleCNN）
 # import torchvision.models as models
 # model = models.resnet18(pretrained=True)
 # num_ftrs = model.fc.in_features
 # model.fc = nn.Linear(num_ftrs, 10)

 # 创建模型并移动到指定设备
model = SimpleCNN()  # 新手用这个
 # model = models.resnet18(pretrained=True)  # 实际应用用这个（需先注释上面的SimpleCNN）
model.to(device)
print("\n模型结构:")
print(model)

 # -------------------------- 4. 定义损失函数、优化器、学习率调度器 --------------------------
criterion = nn.CrossEntropyLoss()  # 交叉熵损失（多分类首选）
optimizer = optim.Adam(model.parameters(), lr=0.001)  # Adam优化器
scheduler = optim.lr_scheduler.StepLR(optimizer, step_size=7, gamma=0.1)  # 学习率调度器

 # -------------------------- 5. 训练循环 --------------------------
def train_model(model, criterion, optimizer, scheduler, num_epochs=25):
    since = time.time()
    best_model_wts = model.state_dict()
    best_acc = 0.0

    for epoch in range(num_epochs):
        print(f'\nEpoch {epoch}/{num_epochs - 1}')
        print('-' * 10)

        for phase in ['train', 'val']:
            if phase == 'train':
                model.train()
                dataloader = trainloader
            else:
                model.eval()
                dataloader = testloader

            running_loss = 0.0
            running_corrects = 0

            for inputs, labels in dataloader:
                inputs = inputs.to(device)
                labels = labels.to(device)

                optimizer.zero_grad()

                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)
                    _, preds = torch.max(outputs, 1)
                    loss = criterion(outputs, labels)

                    if phase == 'train':
                        loss.backward()
                        optimizer.step()

                running_loss += loss.item() * inputs.size(0)
                running_corrects += torch.sum(preds == labels.data)

            if phase == 'train':
                scheduler.step()

            epoch_loss = running_loss / len(dataloader.dataset)
            epoch_acc = running_corrects.double() / len(dataloader.dataset)

            print(f'{phase} Loss: {epoch_loss:.4f} Acc: {epoch_acc:.4f}')

            if phase == 'val' and epoch_acc > best_acc:
                best_acc = epoch_acc
                best_model_wts = model.state_dict()

    time_elapsed = time.time() - since
    print(f'\n训练完成！耗时: {time_elapsed // 60:.0f}m {time_elapsed % 60:.0f}s')
    print(f'最佳验证准确率: {best_acc:.4f}')

    model.load_state_dict(best_model_wts)
    return model

 # 开始训练（新手可将num_epochs改为5，快速测试）
model = train_model(model, criterion, optimizer, scheduler, num_epochs=25)

 # -------------------------- 6. 模型评估 --------------------------
print("\n" + "="*60)
print("模型评估结果")
print("="*60)

 # 收集预测结果和真实标签
y_true = []
y_pred = []
model.eval()
with torch.no_grad():
    for inputs, labels in testloader:
        inputs = inputs.to(device)
        labels = labels.to(device)
        outputs = model(inputs)
        _, preds = torch.max(outputs, 1)
        y_true.extend(labels.cpu().numpy())
        y_pred.extend(preds.cpu().numpy())

 # 打印分类报告
print("\n分类报告:")
print(classification_report(y_true, y_pred, target_names=classes, digits=4))

 # 打印每个类别的准确率
class_correct = list(0. for i in range(10))
class_total = list(0. for i in range(10))
with torch.no_grad():
    for inputs, labels in testloader:
        inputs = inputs.to(device)
        labels = labels.to(device)
        outputs = model(inputs)
        _, preds = torch.max(outputs, 1)
        c = (preds == labels).squeeze()
        for label, correct in zip(labels, c):
            class_correct[label] += correct.item()
            class_total[label] += 1

print("\n每个类别的准确率:")
for i in range(10):
    print(f"{classes[i]}: {class_correct[i]/class_total[i]:.4f} ({int(class_correct[i])}/{int(class_total[i])})")

 # -------------------------- 7. 模型保存（可选） --------------------------
 # 保存训练好的模型权重，后续可直接加载使用，不用重新训练
torch.save(model.state_dict(), 'cifar10_model.pth')
print("\n模型已保存为: cifar10_model.pth")

 # 加载模型的方法（后续使用时）
 # model = SimpleCNN()  # 先创建模型结构
 # model.load_state_dict(torch.load('cifar10_model.pth'))  # 加载权重
 # model.to(device)
 # model.eval()  # 切换为评估模式


```
补充说明：代码中提供了"SimpleCNN"和"ResNet18"两种模型，新手可以先运行SimpleCNN（默认启用），熟悉流程后，再注释掉SimpleCNN，启用ResNet18，对比两者的性能差异。

## 进阶技巧

新手搭建的模型，可能会遇到"准确率上不去""过拟合""训练速度慢"等问题，这里分享5个实用的进阶技巧，都是新手能轻松实现的，不用复杂的理论知识：

技巧1：增加数据增强，解决过拟合

过拟合是新手最常遇到的问题--模型在训练集上准确率很高，在测试集上准确率很低。增加数据增强，能让模型看到更多"多样化"的图片，避免"死记硬背"，具体修改代码如下（在数据预处理部分添加）：

```python

transform = transforms.Compose([
    transforms.RandomCrop(32, padding=4),  # 随机裁剪
    transforms.RandomHorizontalFlip(p=0.5),  # 随机水平翻转
    transforms.RandomRotation(15),  # 随机旋转（-15°到15°），新增
    transforms.ColorJitter(brightness=0.2, contrast=0.2, saturation=0.2),  # 随机调整亮度、对比度、饱和度，新增
    transforms.ToTensor(),
```
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
])


原理：通过随机旋转、调整颜色等操作，让同一张图片产生多种"变体"，模型学习到的是"类别特征"，而不是"具体图片的细节"，从而减少过拟合。

技巧2：使用早停（Early Stopping），防止过拟合

即使增加了数据增强，训练次数太多（epoch太多），模型还是可能过拟合。早停的原理是：当验证集准确率连续几次不再提升时，提前停止训练，避免模型"学偏"，修改训练循环代码如下：

```python

def train_model(model, criterion, optimizer, scheduler, num_epochs=25, patience=5):
    since = time.time()
    best_model_wts = model.state_dict()
    best_acc = 0.0
    early_stop_count = 0  # 记录验证准确率连续不提升的次数

    for epoch in range(num_epochs):
        print(f'\nEpoch {epoch}/{num_epochs - 1}')
        print('-' * 10)

        for phase in ['train', 'val']:
            if phase == 'train':
                model.train()
                dataloader = trainloader
            else:
                model.eval()
                dataloader = testloader

            running_loss = 0.0
            running_corrects = 0

            for inputs, labels in dataloader:
                inputs = inputs.to(device)
                labels = labels.to(device)
                optimizer.zero_grad()

                with torch.set_grad_enabled(phase == 'train'):
                    outputs = model(inputs)
                    _, preds = torch.max(outputs, 1)
                    loss = criterion(outputs, labels)

                    if phase == 'train':
                        loss.backward()
                        optimizer.step()

                running_loss += loss.item() * inputs.size(0)
                running_corrects += torch.sum(preds == labels.data)

            if phase == 'train':
                scheduler.step()

            epoch_loss = running_loss / len(dataloader.dataset)
            epoch_acc = running_corrects.double() / len(dataloader.dataset)

            print(f'{phase} Loss: {epoch_loss:.4f} Acc: {epoch_acc:.4f}')

            # 早停逻辑
            if phase == 'val':
                if epoch_acc > best_acc:
                    best_acc = epoch_acc
                    best_model_wts = model.state_dict()
                    early_stop_count = 0  # 准确率提升，重置计数
                else:
                    early_stop_count += 1  # 准确率未提升，计数+1
                    if early_stop_count >= patience:
                        print(f"\n验证准确率连续{patience}次未提升，触发早停！")
                        model.load_state_dict(best_model_wts)
                        time_elapsed = time.time() - since
                        print(f'训练完成！耗时: {time_elapsed // 60:.0f}m {time_elapsed % 60:.0f}s')
                        print(f'最佳验证准确率: {best_acc:.4f}')
                        return model

    time_elapsed = time.time() - since
    print(f'\n训练完成！耗时: {time_elapsed // 60:.0f}m {time_elapsed % 60:.0f}s')
    print(f'最佳验证准确率: {best_acc:.4f}')

    model.load_state_dict(best_model_wts)
    return model

```
model = train_model(model, criterion, optimizer, scheduler, num_epochs=25, patience=5)


技巧3：调整学习率，加快收敛速度

学习率（lr）是影响训练速度的关键参数：太大容易震荡不收敛，太小收敛太慢。除了StepLR，新手还可以用"ReduceLROnPlateau"（更智能，根据验证损失调整）：
```python


 # 替换原来的StepLR，当验证损失连续3次不下降，学习率乘以0.1
scheduler = optim.lr_scheduler.ReduceLROnPlateau(
    optimizer, mode='min', patience=3, factor=0.1, verbose=True
)

 # 注意：使用这个调度器，需要在训练循环中修改scheduler.step()的位置
 # 在每个epoch的val阶段结束后，调用scheduler.step(epoch_loss)
 # 具体修改：在训练循环的phase == 'val'分支下，添加：
```
if phase == 'val':
    scheduler.step(epoch_loss)  # 根据验证损失调整学习率


技巧4：使用批量归一化（BatchNorm），稳定训练

批量归一化（BatchNorm）是一种能让模型训练更稳定、收敛更快的技术，相当于"给模型的训练过程做'标准化'"，减少梯度消失的问题。在简单CNN中添加BatchNorm，修改模型代码如下：

```python

class SimpleCNN(nn.Module):
    def __init__(self):
        super(SimpleCNN, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)
        self.bn1 = nn.BatchNorm2d(16)  # 批量归一化层，和卷积层对应
        self.pool = nn.MaxPool2d(2, 2)

        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)
        self.bn2 = nn.BatchNorm2d(32)  # 批量归一化层

        self.conv3 = nn.Conv2d(32, 64, 3, padding=1)
        self.bn3 = nn.BatchNorm2d(64)  # 批量归一化层

        self.fc1 = nn.Linear(64 * 4 * 4, 512)
        self.bn4 = nn.BatchNorm1d(512)  # 全连接层对应的批量归一化层
        self.dropout = nn.Dropout(0.5)
        self.fc2 = nn.Linear(512, 10)

    def forward(self, x):
        # 卷积 -> 批量归一化 -> ReLU -> 池化
        x = self.pool(F.relu(self.bn1(self.conv1(x))))
        x = self.pool(F.relu(self.bn2(self.conv2(x))))
        x = self.pool(F.relu(self.bn3(self.conv3(x))))
        x = x.view(-1, 64 * 4 * 4)
        x = F.relu(self.bn4(self.dropout(self.fc1(x))))
        x = self.fc2(x)
        return x
```


原理：批量归一化能让每一层的输入数据分布更稳定，避免某些层的输入值过大或过小，从而加快模型收敛，还能在一定程度上减少过拟合。

技巧5：迁移学习（站在巨人的肩膀上）

如果觉得自己搭建的模型准确率不够高，最省力的方法就是"迁移学习"--使用别人已经训练好的大型模型（比如ResNet、VGG），在我们的CIFAR-10数据集上"微调"，不用从零训练，就能获得很高的准确率。

前面我们已经介绍了ResNet18的调用方法，这里再补充一个关键技巧："冻结部分层"，只训练最后几层，既能节省训练时间，又能提高准确率：

```python

import torchvision.models as models

 # 加载预训练的ResNet18
model = models.resnet18(pretrained=True)

 # 冻结前面的卷积层（只训练最后几层），节省训练时间
for param in list(model.parameters())[:-10]:  # 冻结前除了最后10个参数外的所有参数
    param.requires_grad = False

 # 修改最后一层，适配CIFAR-10的10个类别
num_ftrs = model.fc.in_features
model.fc = nn.Linear(num_ftrs, 10)

 # 移动模型到设备
model.to(device)

```
optimizer = optim.Adam(filter(lambda p: p.requires_grad, model.parameters()), lr=0.001)


原理：预训练模型已经在百万张图片上学习到了通用的图像特征（比如边缘、纹理），我们只需要微调最后几层，让模型适应CIFAR-10的10个类别，就能快速获得高准确率（通常能达到90%以上）。

## 总结与后续学习

### 本次教程总结

到这里，我们已经完成了"从0到1搭建PyTorch图像分类模型"的全部流程，核心要点总结如下，方便大家回顾：

1. 核心任务：用PyTorch搭建模型，识别CIFAR-10数据集的10类物体，掌握图像分类的完整流程；

2. 核心流程：环境准备 → 数据加载与预处理 → 模型搭建 → 训练过程 → 模型评估；

3. 核心知识点：PyTorch核心组件（nn、optim等）、张量、CNN原理、损失函数、优化器、过拟合解决方法；

4. 新手重点：先掌握简单CNN的搭建和训练，再尝试ResNet和迁移学习，遇到问题先看报错信息，再逐步排查（比如GPU不可用、数据路径错误等）。

补充：新手不用追求"一次性达到90%以上的准确率"，先确保代码能正常运行，理解每个步骤的原理，再逐步优化，循序渐进才是最快的学习方式。

后续学习方向（进阶路径）

学会本次教程后，你已经入门了计算机视觉，后续可以按照以下路径进阶，逐步提升自己的能力：

1. 基础进阶：深入学习CNN原理（比如卷积核的作用、池化的种类）、PyTorch高级用法（比如自定义数据集、自定义损失函数）；

2. 模型进阶：学习更复杂的模型（ResNet50、VGG16、MobileNet），了解模型轻量化（适合部署到手机等设备）；

3. 任务进阶：从图像分类，延伸到其他计算机视觉任务（目标检测、图像分割、图像生成）；

4. 实战进阶：用真实数据集做实战（比如自己收集图片，训练一个识别"水果""动物"的模型），尝试模型部署（比如用PyTorch Lightning、ONNX部署）。

常见问题解答（新手必看）

整理了新手最常遇到的5个问题，帮大家快速排查错误：

1. 问题1：安装PyTorch报错？ → 解决方案：先更新pip（pip install --upgrade pip），再根据自己的系统选择对应的安装命令，避免用错CUDA版本；

2. 问题2：GPU不可用？ → 解决方案：检查电脑是否有独立显卡，是否安装了CUDA驱动；如果没有GPU，直接用CPU训练（代码会自动适配），只是速度慢一点；

3. 问题3：训练时内存溢出（报错out of memory）？ → 解决方案：减小batch_size（比如从64改成32、16），关闭不必要的程序，释放内存；

4. 问题4：模型过拟合（训练准确率高，测试准确率低）？ → 解决方案：增加数据增强、添加Dropout层、使用早停、减少模型参数；

5. 问题5：训练准确率一直不提升？ → 解决方案：调整学习率（比如从0.001改成0.0001或0.005）、增加训练epoch、使用迁移学习、检查数据预处理是否正确。

最后，希望本次教程能帮大家轻松入门PyTorch图像分类--深度学习的核心是"实践"，多运行代码、多修改参数、多排查错误，才能真正掌握！祝大家学习顺利，早日实现自己的计算机视觉项目～
