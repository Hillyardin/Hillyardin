%#################################
% GutMap 2014-2024
%#################################

function [out,xtop,ztop,xbot,zbot] = edge_contours(pFrame,edgesmooth)

N = size(pFrame, 2);
M = size(pFrame, 1);

% Obtain edges for the pFrame:
edges = edge(pFrame);

% Output selected edges
[out,xtop,ztop,xbot,zbot] = GreenRedEdgeFunction(edges,pFrame,edgesmooth);
