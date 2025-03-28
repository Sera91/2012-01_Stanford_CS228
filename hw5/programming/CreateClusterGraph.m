%CREATECLUSTERGRAPH Takes in a list of factors and returns a Bethe cluster
%   graph. It also returns an assignment of factors to cliques.
%
%   C = CREATECLUSTERGRAPH(F) Takes a list of factors and creates a Bethe
%   cluster graph with nodes representing single variable clusters and
%   pairwise clusters. The value of the clusters should be initialized to 
%   the initial potential. 
%   It returns a cluster graph that has the following fields:
%   - .clusterList: a list of the cluster beliefs in this graph. These entries
%                   have the following subfields:
%     - .var:  indices of variables in the specified cluster
%     - .card: cardinality of variables in the specified cluster
%     - .val:  the cluster's beliefs about these variables
%   - .edges: A cluster adjacency matrix where edges(i,j)=1 implies clusters i
%             and j share an edge.
%  
%   NOTE: The index of the cluster for each factor should be the same within the
%   clusterList as it is within the initial list of factors.  Thus, the cluster
%   for factor F(i) should be found in P.clusterList(i) 

% CS228 Probabilistic Graphical Models(Winter 2012)
% Copyright (C) 2012, Stanford University

function P = CreateClusterGraph(F, Evidence)

for j = 1:length(Evidence),
    if (Evidence(j) > 0),
        F = ObserveEvidence(F, [j, Evidence(j)]);
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=length(F);
Variable=[];
for i=1:N
    Variable=union(Variable,F(i).var);
end
Nv=length(Variable);
Variable=zeros(Nv,1);
for i=1:Nv
    Variable(i)=F(i).var;
end
P.clusterList = repmat(struct('var', [], 'card', [], 'val', []), 1, N);
P.edges=zeros(N,N);
for i=1:N
    P.clusterList(i)=F(i);    
    if(i>Nv)
        [dummy, dummy, indx] = intersect(F(i).var, Variable);
        for j=1:length(indx)        
                P.edges(i,indx(j))=1;
                P.edges(indx(j),i)=1;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

