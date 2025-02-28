import torch
import torch.nn as nn

from train_MLP_fix import fixed_fwd_op, fix_train_op
from dataset_11 import get_dataset, load_data
import numpy as np
from torch.utils.data import DataLoader, TensorDataset

import torch.nn.functional as F
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
    def __init__(self, n_class=2):
        super(NonBN_MLP_Fullfix, self).__init__()

        self.linear1 = torch.nn.Linear(32, 64)
        self.relu = torch.nn.ReLU()
        
        self.linear2 = torch.nn.Linear(64, 32)
        self.relu2 = torch.nn.ReLU()
       
        self.output = nn.Linear(32, n_class)
        self.softmax = nn.Softmax(dim=1)


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


    def load_fullfix_model(self, param_path):
        self.linear1 = fully_fix_linear(self.linear1)
        self.linear2 = fully_fix_linear(self.linear2)
        self.output = fully_fix_linear(self.output)
        param = torch.load(param_path)
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
        x = self.relu(x) 
                    
        x = self.linear2(x)
        x = self.relu2(x)
        
        x= self.output(x)

        da, db, dc = x.shape
        x = x.view(da, dc)

        return x


if (__name__ == '__main__'):
    model_fix8 = NonBN_MLP_Fullfix()
    model_fix8.load_fullfix_model()
    model_fix8.fixed_model()

    _, val_data_rows, _ = load_data()
    val_dataset = get_dataset(val_data_rows)
    val_data_loader = DataLoader(
        val_dataset, 
        batch_size=512, 
        shuffle=False, 
        drop_last=True
    )
    fixed_fwd_op(model=model_fix8, data_loader=val_data_loader)
    
    fix_train_op(model=model_fix8, n_epochs=25)



