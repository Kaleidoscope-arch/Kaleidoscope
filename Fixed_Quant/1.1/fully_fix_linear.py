import torch
import torch.nn as nn
import numpy as np
import torch.nn.functional as F


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
        x = torch.mul(x, self.linear.weight)
        x = fix_x(x)

        dim_3 = x.shape[2]
        for i in range(dim_3-1):
            x[:, :, dim_3-i-2] += x[:, :, dim_3-i-1]
            x[:, :, dim_3-i-2] = fix_x(x[:, :, dim_3-i-2])
        x = x[:, :, 0]

        x = torch.reshape(x, (x.shape[0], 1, x.shape[1]))
        x = fix_x(x)
        
        x = x + self.linear.bias
        x = fix_x(x)
        return x



if (__name__ == '__main__'):
    a = [4.8, 0.76, 1.2, -0.6, -5, -0.251, -0.249, -0.22, -3.96875]
    a = torch.tensor(a)
    a = fix_x(a)
    print(a)
    

        