# # Retrain the models used for CI.
# # Should be done rarely, indicates a major breaking change. 
my_python=python3.6
export CUDA_VISIBLE_DEVICES=0,1
############### TEST regular RNN choose either -rnn_type LSTM / GRU / SRU and set input_feed 0 for SRU
if false; then
rm data/*.pt
$my_python preprocess.py -train_src data/src-train.txt -train_tgt data/tgt-train.txt -valid_src data/src-val.txt -valid_tgt data/tgt-val.txt -save_data data/data -src_vocab_size 1000 -tgt_vocab_size 1000 

$my_python train.py -data data/data -save_model /tmp/tmp -gpuid 0 -rnn_size 256 -word_vec_size 256 -layers 1 -epochs 10 -optim adam  -learning_rate 0.001 -rnn_type LSTM -input_feed 0
#-truncated_decoder 5 
#-label_smoothing 0.1

mv /tmp/tmp*e10.pt onmt/tests/test_model.pt
rm /tmp/tmp*.pt
fi
#
# 2.28M Param - Epoch10: PPL 15.37 ACC 45.87
# 
############### TEST CNN 
if false; then
rm data/*.pt
$my_python preprocess.py -train_src data/src-train.txt -train_tgt data/tgt-train.txt -valid_src data/src-val.txt -valid_tgt data/tgt-val.txt -save_data data/data -src_vocab_size 1000 -tgt_vocab_size 1000 

$my_python train.py -data data/data -save_model /tmp/tmp -gpuid 0 -rnn_size 256 -word_vec_size 256 -layers 2 -epochs 10 -optim adam  -learning_rate 0.001 -encoder_type cnn -decoder_type cnn


mv /tmp/tmp*e10.pt onmt/tests/test_model.pt

rm /tmp/tmp*.pt
fi
#
# size256 - 1.76M Param - Epoch10: PPL 24.34 ACC 40.08
# 2x256 - 2.61M Param   - Epoch10: PPL 22.91 ACC 39.14
################# MORPH DATA
if false; then
rm data/morph/*.pt
$my_python preprocess.py -train_src data/morph/src.train -train_tgt data/morph/tgt.train -valid_src data/morph/src.valid -valid_tgt data/morph/tgt.valid -save_data data/morph/data 

$my_python train.py -data data/morph/data -save_model /tmp/tmp -gpuid 0 -rnn_size 400 -word_vec_size 100 -layers 1 -epochs 8 -optim adam  -learning_rate 0.001


mv /tmp/tmp*e8.pt onmt/tests/test_model2.pt

rm /tmp/tmp*.pt
fi
############### TEST TRANSFORMER
if true; then
rm data/*.pt
$my_python preprocess.py -train_src data/src-train.txt -train_tgt data/tgt-train.txt -valid_src data/src-val.txt -valid_tgt data/tgt-val.txt -save_data data/data -src_vocab_size 1000 -tgt_vocab_size 1000 -share_vocab

$my_python train.py -data data/data -save_model /tmp/tmp -batch_type tokens -batch_size 1024 -accum_count 1 \
 -layers 2 -rnn_size 256 -word_vec_size 256 -encoder_type transformer -decoder_type transformer -share_embedding \
 -epochs 10 -gpuid 0 1 -max_generator_batches 4 -dropout 0.1 -normalization tokens \
 -max_grad_norm 0 -optim adam -decay_method noam -learning_rate 2 -label_smoothing 0.1 \
 -position_encoding -param_init 0 -warmup_steps 100 -param_init_glorot -adam_beta2 0.998 -seed 1111
#
mv /tmp/tmp*e10.pt onmt/tests/test_model.pt
rm /tmp/tmp*.pt
fi
#
# 3.41M Param - Epoch10: PPL 15.50 ACC 45.67
#
#python train.py -data data/data -save_model /tmp/tmp -batch_type tokens -batch_size 128 -accum_count 4 \
# -layers 4 -rnn_size 128 -word_vec_size 128  -encoder_type transformer -decoder_type transformer \
# -epochs 10 -gpuid 0 -max_generator_batches 4 -dropout 0.1 -normalization tokens \
# -max_grad_norm 0 -optim sparseadam -decay_method noam -learning_rate 2 \
# -position_encoding -param_init 0 -warmup_steps 8000 -param_init_glorot -adam_beta2 0.998
if false; then
$my_python translate.py -gpu 0 -model onmt/tests/test_model.pt \
  -src data/src-val.txt -output onmt/tests/output_hyp.txt -beam 5 -batch_size 16

fi


