# Ribo-seq 


> 注意，文件夹下所有的 single 结尾的脚本都是处理单端测序的样本。本质 ribo seq 需要短读长的测序，看文章里很多都是用单端 50bp 的短读长测序，问了华大测序公司，这种测序方法现在用户比较少，所以很贵


## 准备

* 这里的文件全部是脚本文件，文件夹结构如下
```
# 脚本在script下面，数据在 data 下面
riboseq_star/
├── data
└── script 

# 看一下数据的储存方法，必须在一个文件夹下面，文件夹名字就是样品名
./riboseq_star/data/
├── smmc-siYB1-2-RP
│   ├── smmc-siYB1-2-RP_S15_L001_R1_001.fastq.gz
│   └── smmc-siYB1-2-RP_S15_L001_R2_001.fastq.gz
└── SRR1630831
    └── SRR1630831.fastq.gz
```
* SRA 数据库的这个数据可以用作实例分析， 但是注意这个是单端测序样品SRR1630831

## 比对


* ribo-seq 和 RNA seq 最主要的区别是 riboseq 的比对是先把测序数据去除掉 tRNA 和 rRNA 的部分，然后比对到转录组，下载 tRNA 和 rRNA 的数据的方法在笔记 ‘基因组索引、文件格式、教程’ 中
* 下面的代码就是用 botiew 去掉 rRNA 和 tRNA 的数据，然后下面用 star 进行比对。
* 输出文件 ../mapping/${sample_name}_rm_rRNA.fq.gz 就可以用 star 进行比对了，star 还挺好用，会自动输出比对到转录组上的文件
* 注意这是双端测序的写法，但是理论上 riboseq 用单端50bp或者 75bp 就足够了，单端测序输入是 -U

```bash
# tmp.sam 是完全没用的文件
bowtie2 -p $thread  -x $rRNA_refernce -1 $input_forward -2 $input_reverse  --un-conc-gz ../mapping/${sample_name}_rm_rRNA.fq.gz -S ../mapping/${sample_name}_tmp.sam 

```

## call orf

* call orf 是比较通用的访谈法，不必在区分单端测序和双端测序

## 后续翻译速率的分析

* 没有进行后续分析，，后面还可以继续分析

## 几个 tutorial

[RIBO-Seq Workflow Template (bioconductor.org)](http://www.bioconductor.org/packages/devel/data/experiment/vignettes/systemPipeRdata/inst/doc/systemPipeRIBOseq.html)

[Analysis of translatome by Ribo-Seq (Ribosome Profiling) (unige.ch)](https://www.unige.ch/medecine/ppr2p-platforms/biocode-rna-proteins/services/analysis-translatome-ribosome-profiling-ribo-seq/#:~:text=Ribosome%20profiling%2C%20or%20Ribo%2DSeq,translated%20(1%2C2).)

[RiboDoc: A Docker-based package for ribosome profiling analysis - ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2001037021001951)

[Cells | Free Full-Text | Tracing Translational Footprint by Ribo-Seq: Principle, Workflow, and Applications to Understand the Mechanism of Human Diseases (mdpi.com)](https://www.mdpi.com/2073-4409/11/19/2966)

[2.2.Ribo-seq Analysis - Bioinformatics Tutorial (ncrnalab.org)](https://book.ncrnalab.org/teaching/part-v.-quiz/2.quiz_rna-regulation/2.ribo-seq)

[国内的教程，也不错，但是这个人写的 R 包用不了](https://mp.weixin.qq.com/mp/appmsgalbum?action=getalbum&__biz=MzkyMTI1MTYxNA==&scene=1&album_id=1948302223269068804&count=3#wechat_redirect)
