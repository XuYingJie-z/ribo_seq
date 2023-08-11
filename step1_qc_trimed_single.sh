#!/bin/bash

#SBATCH --job-name=qc_trimed        # 作业名
#SBATCH --partition=64c512g      # small 队列
#SBATCH -n 16                # 总核数需 <=20
#SBATCH --ntasks-per-node=16   # 每节点核数
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err

# 软件在 riboseq 环境 ， 导入工具函数
source ./utils.sh
source activate riboseq



# 文件夹不存在则创建文件夹
batch_test_folder ../trimmed ../trimmed_fastqc ../origin_fastqc ../log/trimmed/


# 检查软件
batch_test_software fastp fastqc multiqc


############################################################## 
# 参数传递
############################################################## 


help()
{
  Usage="Usage: bash step1_qc_trimed.sh  [OPTION]  \n \
  Options:\n\
        [ -i | --input_forward ]  双端测序的 forward fastq 文件 \n \
        [ -I | --input_reverse ] 双端测序的 reverse fastq 文件 \n \
        [ -t | --thread ]  线程数 \n \
        [ -n | --sample_name ] 样品名称 \n \
        [ -h | --help ]   帮助信息  \n \
        "
  echo -e $Usage
  exit 2
}

ARGS=$(getopt  -o  i:t:n:h --long input_forward:,thread:,sample_name:,help -- "$@")


# 脚本开始
echo -e "\033[32m 
############################################################## 
Begin qc and trimed  $sample_name 
args = step1_qc_trimed.sh  $ARGS 
############################################################## 
\033[0m" 


if [  "$ARGS" == " --" ]; then  
  help  
fi

eval set -- "$ARGS"
while :
do
  case "$1" in
    -i | --input_forward)  input_forward="$2"   ; shift 2  ;;
    -t | --thread)          thread="$2"    ; shift 2  ;;
    -n | --sample_name)    sample_name="$2"    ; shift 2  ;;
    -h | --help)             help; exit 0 ; shift    ;;    
    --) shift; break ;;
  esac
done


############################################################## 
# 处理数据 
############################################################## 


# fastqc 每个线程需要 250mb 内存
fastqc --threads $thread  -o ../origin_fastqc $input_forward 

fastp --detect_adapter_for_pe \
        --overrepresentation_analysis \
        --correction --cut_right --thread $thread \
        --html ../trimmed/anc.fastp.html --json ../trimmed/anc.fastp.json \
        -i $input_forward  \
        -o ../trimmed/${sample_name}_trimed.fastq.gz 


fastqc --threads $thread  -o ../trimmed_fastqc  ../trimmed/${sample_name}_trimed.fastq.gz  
# multiqc trimmed-fastqc trimmed


echo -e "\033[32m 
############################################################## 
End qc and trimed  $sample_name 
############################################################## 
\033[0m" 

# 移动一下 log 文件

mv  ./${SLURM_JOB_NAME}_${SLURM_JOB_ID}.err ../log/trimmed/${SLURM_JOB_NAME}_${sample_name}_${SLURM_JOB_ID}.err
mv  ./${SLURM_JOB_NAME}_${SLURM_JOB_ID}.out ../log/trimmed/${SLURM_JOB_NAME}_${sample_name}_${SLURM_JOB_ID}.out

