#!/bin/sh

#SBATCH --job-name=mapping_single_star        # 作业名
#SBATCH --partition=64c512g      # small 队列
#SBATCH -n 16                # 总核数需 <=20
#SBATCH --ntasks-per-node=16   # 每节点核数
#SBATCH --output=%x_%j.out
#SBATCH --error=%x_%j.err



############################################################## 
# 参数传递
############################################################## 

# TODO 单端测序脚本
help()
{
  Usage="Usage: bash step1_qc_trimed.sh  [OPTION]  \n \
  这里用的是 STAR 进行比对，所以 -r 是 STAR index所在的文件夹而不是文件，例如 ls ./reference/ \n \
  out: Genome      SA       sjdbList.fromGTF.out.tab  transcriptInfo.tab ... \n \
  则此时应该填 -r ./reference/
  !! 特别注意 STAR 输入的是 fastq 文件，必须解压
  Options:\n\
        [ -i | --input_forward ]  trimed 后的 forward fastq 文件 \n \
        [ -t | --thread ]  线程数 \n \
        [ -n | --sample_name ] 样品名称 \n \
        [ -r | --reference_genome ] 参考基因组 index 路径 \n \
        [ -h | --help ]   帮助信息  \n \
        "
  echo -e $Usage
  exit 2
}

ARGS=$(getopt  -o  i:t:n:r:h --long input_forward:,thread:,sample_name:,reference_genome:,help -- "$@")

# 脚本开始
echo -e "\033[32m 
############################################################## 
Begin mapping
args = step2_mapping.sh  $ARGS 
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
    -r | --reference_genome)  reference_genome="$2" ; shift 2 ;;
    -n | --sample_name)    sample_name="$2"    ; shift 2  ;;
    -h | --help)             help; exit 0 ; shift    ;;    
    --) shift; break ;;
  esac
done

############################################################## 
## 启动环境
############################################################## 

# 软件在 riboseq 环境
source ./utils.sh
source activate riboseq

# 文件夹不存在则创建文件夹
batch_test_folder ../mapping ../log/mapping


# 检查软件
batch_test_software  samtools STAR

############################################################## 
# 处理数据 
############################################################## 

# 单端测序输入是 -U
echo mapping $sample_name , input: $input_forward 

# --outFileNamePrefix 是 output 名字的前缀，这里也可以指定路径
# STAR 的输出似乎会自动 sort 和 index，所以后面的 samtools 代码先注释了


STAR --outFilterType BySJout --runThreadN $thread --outFilterMismatchNmax 2 --genomeDir $reference_genome  \
  --readFilesIn $input_forward  --outFileNamePrefix ../mapping/${sample_name}  --outSAMtype BAM \
  SortedByCoordinate --quantMode TranscriptomeSAM GeneCounts --outFilterMultimapNmax 1 \
  --outFilterMatchNmin 16 --alignEndsType EndToEnd

## samtools index ,如果报错是因为版本太低了
# samtools sort -@ $thread -O bam -o  ../mapping/${sample_name}.sorted.bam ../mapping/${sample_name}.fixmate.bam
# samtools index -@ $thread  ../mapping/${sample_name}.bam


echo -e "\033[32m 
############################################################## 
End mapping  $sample_name 
############################################################## 
\033[0m" 

# 移动一下 log 到文件夹
mv  ./${SLURM_JOB_NAME}_${SLURM_JOB_ID}.err ../log/mapping/${SLURM_JOB_NAME}_${sample_name}_${SLURM_JOB_ID}.err
mv  ./${SLURM_JOB_NAME}_${SLURM_JOB_ID}.out ../log/mapping/${SLURM_JOB_NAME}_${sample_name}_${SLURM_JOB_ID}.out

