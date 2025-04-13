
import torch
import torch.nn as nn
import torch.nn.functional as F
from GCN import GraphConvolution

DEVICE = 'cuda' 



class PowerLayer(nn.Module):

    def __init__(self, dim, length, step):
        super(PowerLayer, self).__init__()
        self.dim = dim
        self.pooling = nn.AvgPool2d(kernel_size=(1, length), stride=(1, step))

    def forward(self, x):
        eps = 1e-7
        return torch.log(self.pooling(x.pow(2))+eps)


class ModelNet(nn.Module):
    def temporal_learner(self, in_chan, out_chan, kernel, pool, pool_step_rate):
        return nn.Sequential(
            nn.Conv2d(in_chan, out_chan, kernel_size=kernel, stride=(1, 1)),
            PowerLayer(dim=-1, length=pool, step=int(pool_step_rate*pool))
        )

    def __init__(self, num_classes = 2, dropout_rate = 0.2):
        super(ModelNet, self).__init__()

        self.window = [0.5, 0.25, 0.125]
        self.pool = 64
        self.Tout = 16
        self.sampling_rate = 64
        self.pool_step_rate = 0.25
        self.channel = 66
        self.brainarea = 66
        self.datasize = [1,66,1000]
        self.gcnout = 32


        



        self.Tception1 = self.temporal_learner(self.datasize[0], self.Tout,
                                               (1, int(self.window[0] * self.sampling_rate)),
                                               self.pool, self.pool_step_rate)
        self.Tception2 = self.temporal_learner(self.datasize[0], self.Tout,
                                               (1, int(self.window[1] * self.sampling_rate)),
                                               self.pool, self.pool_step_rate)
        self.Tception3 = self.temporal_learner(self.datasize[0],    self.Tout,
                                               (1, int(self.window[2] * self.sampling_rate)),
                                               self.pool, self.pool_step_rate)
        
        self.BN_t = nn.BatchNorm2d(self.Tout)
        self.BN_t_ = nn.BatchNorm2d(self.Tout)

        self.OneXOneConv = nn.Sequential(
            nn.Conv2d(self.Tout, self.Tout, kernel_size=(1, 1), stride=(1, 1)),
            nn.LeakyReLU(),
            nn.AvgPool2d((1, 2)),
            nn.Dropout(p=dropout_rate))
        

        size = self.get_size_temporal(self.datasize)


        self.local_filter_weight = nn.Parameter(torch.FloatTensor(self.channel, size[-1]),
                                                requires_grad=True)
        nn.init.xavier_uniform_(self.local_filter_weight)
        self.local_filter_bias = nn.Parameter(torch.zeros((1, self.channel, 1), dtype=torch.float32),
                                              requires_grad=True)



        self.global_adj = nn.Parameter(torch.FloatTensor(self.brainarea, self.brainarea), requires_grad=True)
        nn.init.xavier_uniform_(self.global_adj)

   
        self.bn = nn.BatchNorm1d(self.brainarea)
        self.bn_ = nn.BatchNorm1d(self.brainarea)


        self.GCN = GraphConvolution(size[-1], self.gcnout)


        self.fc = nn.Sequential(
            nn.Dropout(p=dropout_rate),
            nn.Linear(int(self.brainarea * self.gcnout), num_classes))
        

        self.prelu = nn.PReLU()




    def forward(self, x):


        x = torch.unsqueeze(x,dim = 1)
        
        y = self.Tception1(x)
        out = y
        y = self.Tception2(x)
        out = torch.cat((out, y), dim=-1)
        y = self.Tception3(x)
        out = torch.cat((out, y), dim=-1)
        out = self.BN_t(out)
        out = self.OneXOneConv(out)
        out = self.BN_t_(out)
        out = out.permute(0, 2, 1, 3)
        out = torch.reshape(out, (out.size(0), out.size(1), -1))
        out = self.local_filter_fun(out, self.local_filter_weight)

        adj = self.get_adj(out)
        out = self.bn(out)

        
        out = self.GCN(out, adj)
        out = self.bn_(out)
        out = out.view(out.size()[0], -1)
        out = self.fc(out)
        return out
       
      
    
 
    def corrcoef(self,x):
        x_reducemean = x - torch.mean(x, dim=1, keepdim=True)
        numerator = torch.matmul(x_reducemean, x_reducemean.T)
        no = torch.norm(x_reducemean, p=2, dim=1).unsqueeze(1)
        denominator = torch.matmul(no, no.T)
        corrcoef = numerator / denominator
        return corrcoef

    

    
    def local_filter_fun(self, x, w):
        w = w.unsqueeze(0).repeat(x.size()[0], 1, 1)
        x = self.prelu(torch.mul(x, w) - self.local_filter_bias)
        return x

    def get_size_temporal(self, input_size):
        data = torch.ones((1, input_size[0], input_size[1], int(input_size[2])))
        z = self.Tception1(data)
        out = z
        z = self.Tception2(data)
        out = torch.cat((out, z), dim=-1)
        z = self.Tception3(data)
        out = torch.cat((out, z), dim=-1)
        out = self.BN_t(out)
        out = self.OneXOneConv(out)
        out = self.BN_t_(out)
        out = out.permute(0, 2, 1, 3)
        out = torch.reshape(out, (out.size(0), out.size(1), -1))
        size = out.size()
        return size



    def get_adj(self, x, self_loop=True):
        adj = self.self_similarity(x)   # b, n, n
        num_nodes = adj.shape[-1]
        adj = (adj * (self.global_adj + self.global_adj.transpose(1, 0))).to(DEVICE)
        adj = F.relu(adj)
        if self_loop:
            adj = adj + torch.eye(num_nodes).to(DEVICE)
        rowsum = torch.sum(adj, dim=-1)
        mask = torch.zeros_like(rowsum)
        mask[rowsum == 0] = 1
        rowsum += mask
        d_inv_sqrt = torch.pow(rowsum, -0.5)
        d_mat_inv_sqrt = torch.diag_embed(d_inv_sqrt)
        adj = torch.bmm(torch.bmm(d_mat_inv_sqrt, adj), d_mat_inv_sqrt)
        return adj

    def self_similarity(self, x):
        x_ = x.permute(0, 2, 1)
        s = torch.bmm(x, x_)
        return s

