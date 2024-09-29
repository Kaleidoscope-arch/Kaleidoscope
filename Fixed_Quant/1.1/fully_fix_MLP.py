import math
import torch
import torch.nn as nn

from preprocess_11 import PREFIX_TO_TRAFFIC_ID, PREFIX_TO_APP_ID, AUX_ID
from train_MLP_fix import fixed_fwd_op, fix_train_op
import pdb
from dataset_11 import get_dataset, load_data
import numpy as np
import scipy.sparse
from torch.utils.data import DataLoader, TensorDataset

import torch.nn.functional as F
from torcheval.metrics import MulticlassPrecision, MulticlassRecall, MulticlassAccuracy, MulticlassF1Score
from tqdm import tqdm
from typing import Tuple, List, Any

from utils import tensor_to_txt
from fully_fix_linear import fix_x, fully_fix_linear


class NonBN_MLP_Fullfix(torch.nn.Module):
    """ 
    This module operates fixlization on several critical computations:
    * fixed model parameter
    * fixed activation after linear/relu
    * upper overflow and underflow of weights and activation are supported
    
    However, the data format computed in linear operations remains fp32, which
    is different from hardware fix8 computation.

    The improved version is in fully_fix_MLP.py
    
    """
    def __init__(self):
        super(NonBN_MLP_Fullfix, self).__init__()

        self.linear1 = torch.nn.Linear(32, 64)
        self.relu = torch.nn.ReLU()
        
        self.linear2 = torch.nn.Linear(64, 32)
        self.relu2 = torch.nn.ReLU()
       
      
        self.output = nn.Linear(32, len(AUX_ID))
        self.softmax = nn.Softmax(dim=1)

        # param = torch.load('./winter_weights/InputFixFused6ClassMLP_32_64_32.pt')
        # self.linear1.weight.data = param[0]
        # self.linear1.bias.data = param[1]
        # self.linear2.weight.data = param[2]
        # self.linear2.bias.data = param[3]
        # self.output.weight.data = param[4]
        # self.output.bias.data = param[5]
        # pdb.set_trace()
        # self.load_state_dict(param)


    def fp_forward(self, x):
        x = x[:, :, 0:32]

        x = self.linear1(x)
        x = self.relu(x) 

        x = self.linear2(x)
        x = self.relu2(x)

        x= self.output(x)
        da, db, dc = x.shape
        x = x.view(da, dc)
        
        # x = self.softmax(x)  
        return x


    def load_fullfix_model(self):
        self.linear1 = fully_fix_linear(self.linear1)
        self.linear2 = fully_fix_linear(self.linear2)
        self.output = fully_fix_linear(self.output)
        param = torch.load('./winter_weights/FullFloorWFix_8_32_64_32.pt')
        # param = torch.load('./AllFullFix8_32_64_32.pt')
        # param = torch.load('./FullFix8_32_64_32.pt')
        self.load_state_dict(param)
        self.fullfix_model()
    


    def fixed_model(self):
        # fix for non-fully-fix version
        tmp = torch.round(self.linear1.weight.data*32)
        self.linear1.weight.data = tmp / 32
        tmp = torch.round(self.linear1.bias.data*32)
        self.linear1.bias.data = tmp / 32


        tmp = torch.round(self.linear2.weight.data*32)
        self.linear2.weight.data = tmp / 32
        tmp = torch.round(self.linear2.bias.data*32)
        self.linear2.bias.data = tmp / 32


        tmp = torch.round(self.output.weight.data*32)
        self.output.weight.data = tmp / 32
        tmp = torch.round(self.output.bias.data*32)
        self.output.bias.data = tmp / 32

        dim_i, dim_j = self.linear1.weight.data.shape
        for i in range(dim_i):
            for j in range(dim_j):
                if(self.linear1.weight.data[i, j] > 3.96875):
                    self.linear1.weight.data[i, j] = 3.96875
                elif(self.linear1.weight.data[i, j] < -3.96875):
                    self.linear1.weight.data[i, j] = -3.96875
        
        dim_i, dim_j = self.linear2.weight.data.shape
        for i in range(dim_i):
            for j in range(dim_j):
                if(self.linear2.weight.data[i, j] > 3.96875):
                    self.linear2.weight.data[i, j] = 3.96875
                elif(self.linear2.weight.data[i, j] < -3.96875):
                    self.linear2.weight.data[i, j] = -3.96875

        dim_i, dim_j = self.output.weight.data.shape
        for i in range(dim_i):
            for j in range(dim_j):
                if(self.output.weight.data[i, j] > 3.96875):
                    self.output.weight.data[i, j] = 3.96875
                elif(self.output.weight.data[i, j] < -3.96875):
                    self.output.weight.data[i, j] = -3.96875

        dim_i = self.linear1.bias.data.shape[0]
        for i in range(dim_i):
            if(self.linear1.bias.data[i] > 3.96875):
                    self.linear1.bias.data[i] = 3.96875
            elif(self.linear1.bias.data[i] < -3.96875):
                self.linear1.bias.data[i] = -3.96875

        dim_i = self.linear2.bias.data.shape[0]
        for i in range(dim_i):
            if(self.linear2.bias.data[i] > 3.96875):
                    self.linear2.bias.data[i] = 3.96875
            elif(self.linear2.bias.data[i] < -3.96875):
                self.linear2.bias.data[i] = -3.96875

        dim_i = self.output.bias.data.shape[0]
        for i in range(dim_i):
            if(self.output.bias.data[i] > 3.96875):
                    self.output.bias.data[i] = 3.96875
            elif(self.output.bias.data[i] < -3.96875):
                self.output.bias.data[i] = -3.96875
        
        # pdb.set_trace()

    


    def fullfix_model(self):
        tmp = torch.round(self.linear1.linear.weight.data*32)
        self.linear1.linear.weight.data = tmp / 32
        tmp = torch.round(self.linear1.linear.bias.data*32)
        self.linear1.linear.bias.data = tmp / 32


        tmp = torch.round(self.linear2.linear.weight.data*32)
        self.linear2.linear.weight.data = tmp / 32
        tmp = torch.round(self.linear2.linear.bias.data*32)
        self.linear2.linear.bias.data = tmp / 32


        tmp = torch.round(self.output.linear.weight.data*32)
        self.output.linear.weight.data = tmp / 32
        tmp = torch.round(self.output.linear.bias.data*32)
        self.output.linear.bias.data = tmp / 32

        dim_i, dim_j = self.linear1.linear.weight.data.shape
        for i in range(dim_i):
            for j in range(dim_j):
                if(self.linear1.linear.weight.data[i, j] > 3.96875):
                    self.linear1.linear.weight.data[i, j] = 3.96875
                elif(self.linear1.linear.weight.data[i, j] < -3.96875):
                    self.linear1.linear.weight.data[i, j] = -3.96875
        
        dim_i, dim_j = self.linear2.linear.weight.data.shape
        for i in range(dim_i):
            for j in range(dim_j):
                if(self.linear2.linear.weight.data[i, j] > 3.96875):
                    self.linear2.linear.weight.data[i, j] = 3.96875
                elif(self.linear2.linear.weight.data[i, j] < -3.96875):
                    self.linear2.linear.weight.data[i, j] = -3.96875

        dim_i, dim_j = self.output.linear.weight.data.shape
        for i in range(dim_i):
            for j in range(dim_j):
                if(self.output.linear.weight.data[i, j] > 3.96875):
                    self.output.linear.weight.data[i, j] = 3.96875
                elif(self.output.linear.weight.data[i, j] < -3.96875):
                    self.output.linear.weight.data[i, j] = -3.96875

        dim_i = self.linear1.linear.bias.data.shape[0]
        for i in range(dim_i):
            if(self.linear1.linear.bias.data[i] > 3.96875):
                    self.linear1.linear.bias.data[i] = 3.96875
            elif(self.linear1.linear.bias.data[i] < -3.96875):
                self.linear1.linear.bias.data[i] = -3.96875

        dim_i = self.linear2.linear.bias.data.shape[0]
        for i in range(dim_i):
            if(self.linear2.linear.bias.data[i] > 3.96875):
                    self.linear2.linear.bias.data[i] = 3.96875
            elif(self.linear2.linear.bias.data[i] < -3.96875):
                self.linear2.linear.bias.data[i] = -3.96875

        dim_i = self.output.linear.bias.data.shape[0]
        for i in range(dim_i):
            if(self.output.linear.bias.data[i] > 3.96875):
                    self.output.linear.bias.data[i] = 3.96875
            elif(self.output.linear.bias.data[i] < -3.96875):
                self.output.linear.bias.data[i] = -3.96875


    
    def fixed_fwd(self, x):
        x = torch.tensor(x[:, :, 0:32])
        M = 3.96875
        with torch.no_grad():
            x = fix_x(x)

        x = self.linear1(x)
        # x = fix_x(x, M=M)
        x = self.relu(x) 
        # tensor_to_txt(x, './MLP_activation/layer1_x.txt', n_dim=3)
        
                    
        x = self.linear2(x)
        # x = fix_x(x, M=M)
        x = self.relu2(x)
        # tensor_to_txt(x, './MLP_activation/layer2_x.txt', n_dim=3)
        
        
        x= self.output(x)
        # x = fix_x(x, M=M)
        # tensor_to_txt(x, './MLP_activation/output_x.txt', n_dim=3)

        da, db, dc = x.shape
        x = x.view(da, dc)
        # x = self.softmax(x)  

        # pdb.set_trace()

        return x


    def weight_split(self):
        # self.fixed_model(overflow=True)
        layer1_wchunk_1 = self.linear1.linear.weight.T[0:8]
        layer1_wchunk_2 = self.linear1.linear.weight.T[8:16]
        layer1_wchunk_3 = self.linear1.linear.weight.T[16:24]
        layer1_wchunk_4 = self.linear1.linear.weight.T[24:32]

        layer2_wchunk_1 = self.linear2.linear.weight.T[0:8]
        layer2_wchunk_2 = self.linear2.linear.weight.T[8:16]
        layer2_wchunk_3 = self.linear2.linear.weight.T[16:24]
        layer2_wchunk_4 = self.linear2.linear.weight.T[24:32]
        layer2_wchunk_1 = torch.cat((layer2_wchunk_1, self.linear2.linear.weight.T[32:40]), dim=0)
        layer2_wchunk_2 = torch.cat((layer2_wchunk_2, self.linear2.linear.weight.T[40:48]), dim=0)
        layer2_wchunk_3 = torch.cat((layer2_wchunk_3, self.linear2.linear.weight.T[48:56]), dim=0)
        layer2_wchunk_4 = torch.cat((layer2_wchunk_4, self.linear2.linear.weight.T[56:64]), dim=0)

        output_wchunk_1 = self.output.linear.weight.T[0:8]
        output_wchunk_2 = self.output.linear.weight.T[8:16]
        output_wchunk_3 = self.output.linear.weight.T[16:24]
        output_wchunk_4 = self.output.linear.weight.T[24:32]
        output_wchunk_1 = torch.cat((output_wchunk_1, self.output.linear.weight.T[32:40]), dim=0)
        output_wchunk_2 = torch.cat((output_wchunk_2, self.output.linear.weight.T[40:48]), dim=0)
        output_wchunk_3 = torch.cat((output_wchunk_3, self.output.linear.weight.T[48:56]), dim=0)
        output_wchunk_4 = torch.cat((output_wchunk_4, self.output.linear.weight.T[56:64]), dim=0)
        
        pad_tensor = torch.zeros(8, 5)
        output_wchunk_1 = torch.cat((output_wchunk_1, pad_tensor), dim=1)
        output_wchunk_2 = torch.cat((output_wchunk_2, pad_tensor), dim=1)
        output_wchunk_3 = torch.cat((output_wchunk_3, pad_tensor), dim=1)
        output_wchunk_4 = torch.cat((output_wchunk_4, pad_tensor), dim=1)

        tensor_to_txt(layer1_wchunk_1, './MLP_weight_chunk/layer1_wchunk_1.txt', n_dim=2)
        tensor_to_txt(layer1_wchunk_2, './MLP_weight_chunk/layer1_wchunk_2.txt', n_dim=2)
        tensor_to_txt(layer1_wchunk_3, './MLP_weight_chunk/layer1_wchunk_3.txt', n_dim=2)
        tensor_to_txt(layer1_wchunk_4, './MLP_weight_chunk/layer1_wchunk_4.txt', n_dim=2)
        tensor_to_txt(layer2_wchunk_1, './MLP_weight_chunk/layer2_wchunk_1.txt', n_dim=2)
        tensor_to_txt(layer2_wchunk_2, './MLP_weight_chunk/layer2_wchunk_2.txt', n_dim=2)
        tensor_to_txt(layer2_wchunk_3, './MLP_weight_chunk/layer2_wchunk_3.txt', n_dim=2)
        tensor_to_txt(layer2_wchunk_4, './MLP_weight_chunk/layer2_wchunk_4.txt', n_dim=2)
        tensor_to_txt(output_wchunk_1, './MLP_weight_chunk/output_wchunk_1.txt', n_dim=2)
        tensor_to_txt(output_wchunk_2, './MLP_weight_chunk/output_wchunk_2.txt', n_dim=2)
        tensor_to_txt(output_wchunk_3, './MLP_weight_chunk/output_wchunk_3.txt', n_dim=2)
        tensor_to_txt(output_wchunk_4, './MLP_weight_chunk/output_wchunk_4.txt', n_dim=2)


    def bias_extract(self):
        # self.fixed_model(overflow=True)
        layer1_bias = self.linear1.linear.bias
        layer2_bias = self.linear2.linear.bias
        output_bias = self.output.linear.bias

        tensor_to_txt(layer1_bias, './MLP_weight_chunk/layer1_bias.txt', n_dim=1)
        tensor_to_txt(layer2_bias, './MLP_weight_chunk/layer2_bias.txt', n_dim=1)
        tensor_to_txt(output_bias, './MLP_weight_chunk/output_bias.txt', n_dim=1)




if (__name__ == '__main__'):
    model_fix8 = NonBN_MLP_Fullfix()
    model_fix8.load_fullfix_model()
    # model_fix8.fixed_model()

    # _, val_data_rows, _ = load_data()
    # val_dataset = get_dataset(val_data_rows)
    # val_data_loader = DataLoader(
    #     val_dataset, 
    #     # batch_size=1, 
    #     batch_size=102400, 
    #     shuffle=False, 
    #     drop_last=True
    # )
    # fixed_fwd_op(model=model_fix8, data_loader=val_data_loader)
    
    # fix_train_op(model=model_fix8, n_epochs=25)

    model_fix8.weight_split()
    model_fix8.bias_extract()


