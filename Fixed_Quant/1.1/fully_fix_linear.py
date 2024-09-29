import math
import torch
import torch.nn as nn

from preprocess_11 import PREFIX_TO_TRAFFIC_ID, PREFIX_TO_APP_ID, AUX_ID
from train_MLP import train_op, evaluate_op, fixed_fwd_op, fix_train_op
import pdb
from dataset_11 import get_dataset, load_data
import numpy as np
import scipy.sparse
from torch.utils.data import DataLoader, TensorDataset
from Quant_MLP import Qevaluate, Qvalidate


import torch.nn.functional as F
from torcheval.metrics import MulticlassPrecision, MulticlassRecall, MulticlassAccuracy, MulticlassF1Score
from tqdm import tqdm
from typing import Tuple, List, Any

from utils import tensor_to_txt




def fix_x(x, M=3.96875):
    relu = torch.nn.ReLU()
    
    x = x*32
    pos_x = relu(x)
    pos_x = pos_x - pos_x.detach() + torch.floor(pos_x)
    neg_x = relu(x*(-1))
    neg_x = neg_x - neg_x.detach() + torch.ceil(neg_x)
    x = pos_x - neg_x
    x = x/32
    # pdb.set_trace()
    
    pos_x = relu(x) * (-1) + M
    pos_x = M - relu(pos_x)
    
    neg_x = x * (-1)
    neg_x = relu(neg_x) * (-1) + M
    neg_x = M - relu(neg_x)

    x = pos_x - neg_x
    return x



class fully_fix_linear(torch.nn.Module):
    def __init__(self, linear):
        super(fully_fix_linear, self).__init__()
        self.linear = linear

    def forward(self, x):
        # tensor_to_txt(x, './MLP_activation/input.txt', n_dim=3)
        pdb.set_trace()
        x = torch.mul(x, self.linear.weight)
        x = fix_x(x)
        # pdb.set_trace()

        # x = torch.sum(x, dim=2)
        dim_3 = x.shape[2]
        for i in range(dim_3-1):
            x[:, :, dim_3-i-2] += x[:, :, dim_3-i-1]
            x[:, :, dim_3-i-2] = fix_x(x[:, :, dim_3-i-2])
        x = x[:, :, 0]
        # pdb.set_trace()
        x = torch.reshape(x, (x.shape[0], 1, x.shape[1]))
        x = fix_x(x)
        
        x = x + self.linear.bias
        x = fix_x(x)
        pdb.set_trace()
        return x



if (__name__ == '__main__'):
    # model_fix8 = fully_fix_linear()
    a = [4.8, 0.76, 1.2, -0.6, -5, -0.251, -0.249, -0.22, -3.96875]
    a = torch.tensor(a)
    a = fix_x(a)
    print(a)
    

        