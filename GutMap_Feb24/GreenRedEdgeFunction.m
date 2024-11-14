%#################################
% GutMap 2014-2024
%#################################

function[outedges,xtp_top,ztp_top,xtp_bot,ztp_bot] = GreenRedEdgeFunction(edges,pFrame,esmooth)

[M,N] = size(edges);

% Find the topedge mask and botedge mask:
topedge = edges;
botedge = edges;
bord = zeros(N,1);

for k = 1:1:N
    maxpFrame = max(pFrame(:,k));
    bord(k) = round(mean(find(pFrame(:,k)>0.5*maxpFrame)));
end;

bord = round(movmean(bord,round(M/3),'omitnan'));

if (sum(isnan(bord))>0)
    errordlg(['Error with edge detection: try adjusting brightness and contrast.'],...
                'Edge detection error');
    return;
end;

for k = 1:1:N
    topedge(bord(k):end,k) = 0;
    botedge(1:bord(k)-1,k) = 0;
end;

if ~sum(botedge(:))
    botedge(end,:) = 1;
end;

[sp_top,xtp_top,ztp_top] = GRfunc(topedge,N,esmooth);
[sp_bot,xtp_bot,ztp_bot] = GRfunc(botedge,N,esmooth);

if ~isempty(sp_top) & ~isempty(sp_bot)

    outedges = zeros(size(edges));
    topk = sub2ind(size(outedges),...
                min(max(1,round(ztp_top)),size(outedges,1)),xtp_top);
    botk = sub2ind(size(outedges),...
                min(max(1,round(ztp_bot)),size(outedges,1)),xtp_bot);
    outedges(topk) = 1;
    outedges(botk) = 2;

else
    outedges = [];
end;
